//
//  ChannelsRepositoryImp.swift
//  IvoryCore
//
//  Created by Ilya Kuznetsov on 18/11/2023.
//

import Foundation
import DependencyContainer
import CommonUtils
import Loader
import Database

struct ChannelsRepositoryImp: ChannelsRepository {
    
    @DI.Static(DI.database) private var database
    @DI.Static(DI.networkAPI) private var api
    
    func get(uid: String) async throws -> Channel {
        if let channel = try await database.parse(Channel.self, items: [api.channel(uid: uid)]).first {
            return channel
        }
        throw RunError.custom("Channel Not Found")
    }
    
    func updateIfNeeded(_ channel: Channel) {
        if channel.loadedDate == nil || abs(channel.loadedDate!.timeIntervalSinceNow) > 60 * 60 * 24 {
            Task {
                _ = try await self.get(uid: channel.async.uid()!)
                try await database.edit(channel, { channel, ctx in
                    channel.loadedDate = Date()
                })
            }
        }
    }
    
    func videos(_ channel: Channel, offset: AnyHashable?) async throws -> Page<Video> {
        try await api.videos(channelId: try await channel.async.uid()!, offset: offset)
            .parse(Video.self, database: database)
    }
    
    func latestVideos(_ channel: Channel) async throws -> [Video] {
        let items = try await api.latestVideos(try await channel.async.uid()!)
        
        return try await database.edit(channel, { channel, ctx in
            channel.latestVideosLoad = Date()
            return Video.parse(items, ctx: ctx).ids
        }).objects(database)
    }
    
    func cachedLatestVideos(_ channel: Channel) async throws -> [Video] {
        try await database.fetch(channel) { channel, ctx in
             
            channel.allVideos.sorted {
                if $0.published == $1.published {
                    return $0.uid! > $1.uid!
                }
                return $0.published ?? .distantPast > $1.published ?? .distantPast
            }.prefix(25).ids
            
        }.objects(database)
    }
    
    func playlists(_ channel: Channel, offset: AnyHashable?) async throws -> Page<Playlist> {
        try await api.playlists(try await channel.async.uid()!, offset: offset)
            .parse(Playlist.self, database: database)
    }
    
    func search(term: String, order: SearchOrder, offset: AnyHashable?) async throws -> Page<Channel> {
        try await api.searchChannels(term: term, order: order, offset: offset)
            .parse(Channel.self, database: database)
    }
}
