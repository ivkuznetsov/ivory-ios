//
//  StorageGroup.swift
//  IvoryCore
//
//  Created by Ilya Kuznetsov on 28/03/2023.
//

import Foundation
import Database

public protocol VideoStorage: StorageProtocol where Stored == Video { }
public protocol ChannelStorage: StorageProtocol where Stored == Channel { }
public protocol PlaylistStorage: StorageProtocol where Stored == Playlist { }

public protocol HistoryStorage: VideoStorage {
    
    func position(video: Video) -> Double
    func save(position: Double, video: Video)
}

public struct StorageGroup {
    
    public let videos: any VideoStorage
    public let channels: any ChannelStorage
    public let playlists: any PlaylistStorage
    
    public init(videos: any VideoStorage, channels: any ChannelStorage, playlists: any PlaylistStorage) {
        self.videos = videos
        self.channels = channels
        self.playlists = playlists
    }
}
