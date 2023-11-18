//
//  ChannelsAPI.swift
//  IvoryCore
//
//  Created by Ilya Kuznetsov on 08/04/2023.
//

import Foundation
import NetworkKit
import Loader

extension NetworkAPI {
    
    func channel(uid: String) async throws -> [String:Any] {
        let scope = "authorThumbnails,authorBanners(url),author,authorId,subCount"
        let request = SerializableRequest<[String:Any]>(.init(endpoint: "channels/\(uid)", parameters: ["fields" : scope]))
        return try await network.load(request)
    }
    
    private enum VideosSource: String {
        case videos
        case latest
    }
    
    func videos(channelId: String, offset: AnyHashable?) async throws -> Page<[String:Any]> {
        try await internalVideos(channelId, source: .videos, offset: offset)
    }
    
    func latestVideos(_ channelId: String) async throws -> [[String:Any]] {
        try await internalVideos(channelId, source: .videos, offset: nil).items
    }
    
    private func internalVideos(_ channelId: String, source: VideosSource, offset: AnyHashable?) async throws -> Page<[String:Any]> {
        var params: [String:Any] = ["fields" : "videos(authorId,lengthSeconds,videoId,published,title,videoThumbnails(url,quality),viewCount),continuation"]
        params["continuation"] = offset
        let request = SerializableRequest<[String:Any]>(.init(endpoint: "channels/\(source.rawValue)/\(channelId)", parameters: params))
        let json = try await network.load(request)
        let result = json["videos"] as? [[String:Any]] ?? []
        
        return Page(items: result, next: json["continuation"] as? String)
    }
    
    func playlists(_ channelId: String, offset: AnyHashable?) async throws -> Page<[String:Any]> {
        var params: [String : Any] = ["fields" : "playlists(authorId,title,playlistId,playlistThumbnail,videoCount),continuation"]
        params["continuation"] = offset
        let request = SerializableRequest<[String:Any]>(.init(endpoint: "channels/playlists/\(channelId)", parameters: params))
        let json = try await network.load(request)
        let result = json["playlists"] as? [[String:Any]] ?? []
        
        return Page(items: result, next: json["continuation"] as? String)
    }
}
