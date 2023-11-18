//
//  PlayerViewController.swift
//  IvoryCore
//
//  Created by Ilya Kuznetsov on 16/03/2023.
//

import Foundation
import AVKit

public extension AVPlayer {
    
    func setVideo(enabled: Bool) {
        currentItem?.tracks.first(where: { $0.assetTrack?.mediaType == .video })?.isEnabled = enabled
    }
    
    var isPlaying: Bool {
        get { rate > 0 }
        set { newValue ? play() : pause() }
    }
}

public final class PlayerViewController: AVPlayerViewController {
    
    func goFullScreen() {
        perform(NSSelectorFromString("enterFullScreenAnimated:completionHandler:"), with: true, with: nil)
    }
    
    public var isFullScreen: Bool {
        presentedViewController != nil
    }
    
    func removeLogo() {
        view.subviews.first?.subviews.first(where: { $0 is UIImageView })?.isHidden = true
    }
    
    override public func remoteControlReceived(with event: UIEvent?) {
        switch event?.subtype {
        case .remoteControlTogglePlayPause:
            if player?.rate == 0 {
                player?.play()
            } else {
                player?.pause()
            }
        case .remoteControlPlay:
            player?.play()
        case .remoteControlPause:
            player?.pause()
        default: break
        }
    }
}
