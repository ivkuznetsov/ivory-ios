//
//  ChannelsRepository.swift
//  IvoryCore
//
//  Created by Ilya Kuznetsov on 18/11/2023.
//

import Foundation
import Loader
import DependencyContainer

public protocol ChannelsRepository {
    
    func get(uid: String) async throws -> Channel
    
    func updateIfNeeded(_ channel: Channel)
    
    func videos(_ channel: Channel, offset: AnyHashable?) async throws -> Page<Video>
    
    func latestVideos(_ channel: Channel) async throws -> [Video]
    
    func cachedLatestVideos(_ channel: Channel) async throws -> [Video]
    
    func playlists(_ channel: Channel, offset: AnyHashable?) async throws -> Page<Playlist>
    
    func search(term: String, order: SearchOrder, offset: AnyHashable?) async throws -> Page<Channel>
}

public struct ChannelsRepositoryMock: ChannelsRepository {
    
    @DI.Static(DI.database) private var database
    
    public init() {}
    
    public func get(uid: String) async throws -> Channel {
        await database.edit { Channel.example(ctx: $0).getObjectId }.object(database)!
    }
    
    public func updateIfNeeded(_ channel: Channel) { }
    
    public func videos(_ channel: Channel, offset: AnyHashable?) async throws -> Page<Video> {
        Page(items: await database.edit { Video.exampleArray(ctx: $0).ids }.objects(database))
    }
    
    public func latestVideos(_ channel: Channel) async throws -> [Video] {
        try await videos(channel, offset: nil).items
    }
    
    public func cachedLatestVideos(_ channel: Channel) async throws -> [Video] {
        try await latestVideos(channel)
    }
    
    public func playlists(_ channel: Channel, offset: AnyHashable?) async throws -> Page<Playlist> {
        Page(items: await database.edit { Playlist.exampleArray(ctx: $0).ids }.objects(database))
    }
    
    public func search(term: String, order: SearchOrder, offset: AnyHashable?) async throws -> Page<Channel> {
        Page(items: await database.edit { Channel.exampleArray(ctx: $0).ids }.objects(database))
    }
}
