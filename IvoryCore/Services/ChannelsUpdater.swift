//
//  UpdatesNotifier.swift
//

import Foundation
import CoreData
import NetworkKit
import UIKit
import Database
import DependencyContainer
import CommonUtils

@MainActor
public protocol ChannelsUpdater: ObservableObject {
    
    func currentRecentVideos(_ channel: Channel) -> [Video]
    
    func updateRecentVideosIfNeeded(_ channel: Channel)
}

public final class ChannelsUpdaterImp: ChannelsUpdater {
    
    @DI.Static(DI.data, \.channels) private var channels
    @DI.Static(DI.favorites, \.channels) private var favorites
    
    @Published private var loadedVideos: [Channel:[Video]] = [:]
    
    nonisolated public init() {
        Task { @MainActor in
            setup()
        }
    }
    
    private func setup() {
        UIApplication.shared.applicationIconBadgeNumber = 0
        
        favorites.sinkOnMain(retained: self) { [weak self] in
            self?.reload()
        }
    }
    
    public func currentRecentVideos(_ channel: Channel) -> [Video] {
        loadedVideos[channel] ?? []
    }
    
    public func updateRecentVideosIfNeeded(_ channel: Channel) {
        let datePassed = channel.latestVideosLoad == nil || abs(channel.latestVideosLoad!.timeIntervalSinceNow) > 86400
        
        Task {
            if loadedVideos[channel] == nil {
                let result = try await channels.cachedLatestVideos(channel)
                loadedVideos[channel] = result
            }
            if datePassed {
                try await SingletonTasks.run(key: "updatesNotifier.loadFavorites" + channel.async.uid()!) {
                    let result = try await self.channels.latestVideos(channel)
                    Task { @MainActor in
                        self.loadedVideos[channel] = result
                    }
                }
            }
        }
    }
    
    private func reload() {
        if loadedVideos.isEmpty {
            Task {
                var videos: [Channel:[Video]] = [:]
                print(favorites.items)
                for channel in favorites.items {
                    videos[channel] = try await channels.cachedLatestVideos(channel)
                }
                loadedVideos = videos
            }
        } else {
            loadedVideos.keys.forEach {
                if !favorites.has($0) {
                    loadedVideos[$0] = nil
                }
            }
        }
    }
}

public final class ChannelsUpdaterMock: ChannelsUpdater {
    
    public var loadedVideos: [Channel:[Video]] = [:]
    
    public func currentRecentVideos(_ channel: Channel) -> [Video] { loadedVideos[channel] ?? [] }
    
    public func updateRecentVideosIfNeeded(_ channel: Channel) { }
    
    public init() {}
}
