//
//  PlayerViewController.swift
//  YouPlayer
//
//  Created by Ilya Kuznetsov on 4/19/18.
//  Copyright © 2018 Ilya Kuznetsov. All rights reserved.
//

import Foundation
import MediaPlayer
import AVKit
import Combine
import Loader
import Kingfisher
import DependencyContainer
import CommonUtils

public enum PlayerOwner: Equatable {
    case inline(Int)
    case floating
    
    public func isEqualType(_ owner: PlayerOwner) -> Bool {
        switch (self, owner) {
        case (.inline(_), .inline(_)): return true
        case (.floating, .floating): return true
        default: return false
        }
    }
}

@MainActor
public final class Player: NSObject, ObservableObject {
    
    @DI.Static(DI.settings) private var settings
    @DI.Static(DI.data) private var data
    
    public let loader = Loader()
    public let didFinish = VoidPublisher()
    
    @Published public private(set) var streams: [VideoStream] = []
    @Published public var stream: VideoStream?
    @Published private var backupStreams: [VideoStream] = []
    
    @Published public private(set) var presentingInPIP: Bool = false
    @Published public var owner: PlayerOwner = .floating
    @Published public private(set) var video: Video?
    
    private var artwork: UIImage?
    
    public func set(video: Video?, streams: [VideoStream] = []) {
        self.video = video
        if backupStreams.isEmpty && self.streams.isEmpty {
            self.streams = streams
        }
    }
    
    public var currentTime: TimeInterval { player.currentTime().seconds }
    
    public let controller = PlayerViewController()
    
    private var isSavePositionAllowed: Bool = false
    private let player = CustomPlayer()
    
    public nonisolated override init() {
        super.init()
        Task { await setup() }
    }
    
    private func setup() {
        controller.delegate = self
        controller.updatesNowPlayingInfoCenter = false
        controller.player = player
        controller.view.backgroundColor = .clear
        
        controller.removeLogo()
        setupNotifications()
        
        player.actionAtItemEnd = .pause
        player.publisher(for: \.rate, options: .new).removeDuplicates().sink { [weak self] rate in
            guard let wSelf = self else { return }
            
            Task { @MainActor in
                if rate == 0 &&
                    !wSelf.player.stopped &&
                    !wSelf.player.interrupted &&
                    UIApplication.shared.applicationState == .active,
                   wSelf.player.currentTime() < (wSelf.player.currentItem?.duration ?? .zero) {
                    
                    wSelf.player.play()
                }
                wSelf.setupCommandCenter()
                wSelf.updateInfoCenter()
                wSelf.saveCurrentTime()
            }
        }.retained(by: self)
        
        player.publisher(for: \.isExternalPlaybackActive, options: .new).sink { [weak self] active in
            if active == true {
                self?.player.setVideo(enabled: true)
            }
        }.retained(by: self)
        
        $video.removeDuplicates().sink { [weak self] newVideo in
            self?.saveCurrentTime()
            self?.loader.cancelOperations()
            self?.controller.showsPlaybackControls = false
            
            if UIApplication.shared.applicationState == .active {
                self?.player.replaceCurrentItem(with: nil)
            }
            self?.player.pause()
            self?.player.currentItem?.asset.cancelLoading()
            self?.backupStreams = []
            self?.streams = []
            self?.stream = nil
            self?.artwork = nil
            self?.updateArtwork(video: newVideo)
            self?.updateInfoCenter()
        }.retained(by: self)
        
        $stream.removeDuplicates().sink { [weak self] stream in
            guard let wSelf = self, let stream = stream else {
                UIApplication.shared.endReceivingRemoteControlEvents()
                return
            }
            
            let hadStreamBefore = wSelf.stream != nil
            
            wSelf.isSavePositionAllowed = false
            let videoAsset = AVURLAsset(url: stream.url)
            let video = wSelf.video
            wSelf.loader.run(hadStreamBefore ? .none(fail: .opaque) : .opaque(), id: "tracks") { [weak self] _ in
                
                do {
                    _ = try await videoAsset.load(.tracks)
                } catch {
                    print("Cannot playback video: \(error)")
                    
                    if let video = video,
                       let wSelf = self,
                        wSelf.backupStreams.isEmpty {
                        
                        wSelf.backupStreams = try await wSelf.data.videos.extractLocalStreams(video)
                        return
                    } else {
                        throw error
                    }
                }
                
                if let wSelf = self, let video = wSelf.video, wSelf.stream == stream {
                    let item = AVPlayerItem(asset: videoAsset)
                    let oldTime = wSelf.player.currentTime()
                    let isPlaying = wSelf.player.isPlaying
                    wSelf.replacePlayback(item: item)
                    
                    if hadStreamBefore {
                        if oldTime.value > 0 {
                            await item.seek(to: oldTime, toleranceBefore: .zero, toleranceAfter: .zero)
                        }
                        wSelf.player.isPlaying = isPlaying
                    } else {
                        try? await wSelf.data.history.add(video)
                        let lastPosition = wSelf.data.history.position(video: video)
                        
                        if lastPosition > 0,
                           lastPosition < video.durationInterval * 0.9 {
                            _ = await item.seek(to: CMTime(seconds: lastPosition, preferredTimescale: 60), toleranceBefore: .zero, toleranceAfter: .zero)
                            wSelf.updateInfoCenter()
                        } else {
                            wSelf.saveCurrentTime()
                        }
                        if wSelf.settings.autoStartVideo {
                            wSelf.player.isPlaying = true
                        }
                    }
                }
            }
        }.retained(by: self)
        
        $streams.removeDuplicates().sink { [weak self] in
            if let wSelf = self, $0.count > 0, wSelf.stream == nil {
                wSelf.stream = $0.first(where: { $0.quality == wSelf.settings.quality }) ?? $0.last
            }
        }.retained(by: self)
        
        $backupStreams.removeDuplicates().sink { [weak self] in
            if let wSelf = self, $0.count > 0 {
                wSelf.stream = nil
                wSelf.stream = $0.first { $0.quality == wSelf.stream?.quality ?? wSelf.settings.quality } ?? $0.last
                wSelf.streams = $0
            }
        }.retained(by: self)
    }
    
    private func updateArtwork(video: Video?) {
        if let video = video, let url = video.thumbnailURL {
            KingfisherManager.shared.retrieveImage(with: .network(url)) { [weak self] result in
                DispatchQueue.main.async {
                    if let image = try? result.get().image, self?.video == video {
                        self?.artwork = image
                        self?.updateInfoCenter()
                    }
                }
            }
        }
    }
    
    private func replacePlayback(item: AVPlayerItem) {
        item.canUseNetworkResourcesForLiveStreamingWhilePaused = true
        item.preferredForwardBufferDuration = 10
        UIApplication.shared.beginReceivingRemoteControlEvents()
        player.replaceCurrentItem(with: item)
        isSavePositionAllowed = true
        
        let session = AVAudioSession.sharedInstance()
        try? session.setCategory(.playback)
        try? session.setActive(true)
        
        updateInfoCenter()
        controller.exitsFullScreenWhenPlaybackEnds = true
        controller.showsPlaybackControls = true
        if settings.forceFullscreen {
            controller.goFullScreen()
        }
    }
    
    private func setupNotifications() {
        let nc = NotificationCenter.default
        nc.publisher(for: Notification.Name.AVPlayerItemDidPlayToEndTime).sink { [weak self] notification in
            if let wSelf = self, wSelf.player.currentItem == notification.object as? AVPlayerItem {
                wSelf.saveCurrentTime()
                
                if wSelf.owner == .floating, !wSelf.controller.isFullScreen {
                    wSelf.video = nil
                }
                wSelf.didFinish.send()
            }
        }.retained(by: self)
        
        nc.publisher(for: UIApplication.didEnterBackgroundNotification).sink { [weak self] _ in
            if let wSelf = self,
               wSelf.settings.backgroundPlayback,
               wSelf.presentingInPIP == false,
               wSelf.player.isExternalPlaybackActive == false,
               wSelf.player.isPlaying == true {
                wSelf.player.setVideo(enabled: false)
            }
        }.retained(by: self)
        
        nc.publisher(for: UIApplication.willResignActiveNotification).sink { [weak self] _ in
            self?.saveCurrentTime()
        }.retained(by: self)
        
        [UIApplication.willEnterForegroundNotification,
         UIApplication.didBecomeActiveNotification].forEach {
            nc.publisher(for: $0).sink { [weak self] _ in
                self?.player.setVideo(enabled: true)
            }.retained(by: self)
        }
        
        nc.publisher(for: AVAudioSession.interruptionNotification).sink { [weak self] notification in
            if let userInfo = notification.userInfo,
               let typeInt = userInfo[AVAudioSessionInterruptionTypeKey] as? UInt,
               let type = AVAudioSession.InterruptionType(rawValue: typeInt) {
                
                if type == .began {
                    self?.player.interrupted = true
                } else {
                    if let optionsInt = userInfo[AVAudioSessionInterruptionOptionKey] as? UInt {
                        let options = AVAudioSession.InterruptionOptions(rawValue: optionsInt)
                        
                        if options == .shouldResume, self?.player.stopped == false {
                            self?.player.play()
                        }
                    }
                }
            }
        }.retained(by: self)
    }
    
    private func saveCurrentTime() {
        if isSavePositionAllowed, let video = video, player.currentItem != nil, video.durationInterval > 0 {
            var duration = player.currentTime().seconds
            if duration / video.durationInterval > 0.9 {
                duration = video.durationInterval
            }
            data.history.save(position: duration, video: video)
        }
    }
    
    @objc private func playAction() -> MPRemoteCommandHandlerStatus {
        player.play()
        return .success
    }
    
    @objc private func pauseAction() -> MPRemoteCommandHandlerStatus {
        player.pause()
        return .success
    }
    
    private func setupCommandCenter() {
        let center = MPRemoteCommandCenter.shared()
        center.playCommand.addTarget(self, action: #selector(playAction))
        center.pauseCommand.addTarget(self, action: #selector(pauseAction))
        center.nextTrackCommand.isEnabled = false
        center.previousTrackCommand.isEnabled = false
        center.playCommand.isEnabled = true
        center.pauseCommand.isEnabled = true
    }
    
    private func updateInfoCenter() {
        var info: [String:AnyHashable] = [:]
        
        if let video = video {
            info[MPMediaItemPropertyTitle] = video.title
            
            if let artwork = artwork {
                info[MPMediaItemPropertyArtwork] = MPMediaItemArtwork(boundsSize: CGSize(width: 500, height: 500),
                                                                      requestHandler: {
                    artwork.squareCroped(minSide: max($0.width, $0.height))
                })
            }
            
            if let item = player.currentItem {
                if video.live {
                    info[MPNowPlayingInfoPropertyIsLiveStream] = true
                } else {
                    let currentTime = floor(item.currentTime().seconds)
                    
                    info[MPMediaItemPropertyPlaybackDuration] = video.durationInterval
                    info[MPNowPlayingInfoPropertyDefaultPlaybackRate] = player.rate
                    info[MPNowPlayingInfoPropertyElapsedPlaybackTime] = currentTime
                }
                info[MPNowPlayingInfoPropertyAssetURL] = (item.asset as? AVURLAsset)?.url
            }
        }
        MPNowPlayingInfoCenter.default().nowPlayingInfo = info
    }
    
    public func createGif() async throws -> URL {
        guard let asset = player.currentItem?.asset else {
            throw RunError.custom("Please whait till video is loaded")
        }
        player.pause()
        
        let time = CMTime.init(seconds: Double(player.currentTime().seconds), preferredTimescale: 1000)
        if time.seconds == 0 {
            throw RunError.custom("Please, drag the time pin to non zero position")
        }
        return try await ImageExporter().generateGIF(asset: asset, time: time)
    }
}

extension Player: AVPlayerViewControllerDelegate {
    
    public nonisolated func playerViewControllerWillStartPictureInPicture(_ playerViewController: AVPlayerViewController) {
        Task { @MainActor in presentingInPIP = true }
    }
        
    public nonisolated func playerViewControllerDidStopPictureInPicture(_ playerViewController: AVPlayerViewController) {
        Task { @MainActor in presentingInPIP = false }
    }
}
