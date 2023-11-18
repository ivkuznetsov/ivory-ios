//
//  VideoRepositoryImp.swift
//  IvoryCore
//
//  Created by Ilya Kuznetsov on 18/11/2023.
//

import Foundation
import DependencyContainer
import CommonUtils
import YouTubeKit
import Loader

struct VideosRepositoryImp: VideosRepository {

    @DI.Static(DI.database) private var database
    @DI.Static(DI.networkAPI) private var api
    
    func popular(_ category: VideoCategory) async throws -> [Video] {
        try await database.parse(Video.self, items: api.popularVideos(category))
    }
    
    func get(uid: String) async throws -> DetailsResult {
        let json = try await api.video(uid: uid)
        
        let result = try await database.edit {
            guard let id = Video.parse([json], ctx: $0).first?.getObjectId else {
                throw RunError.custom("Video not found")
            }
            return (id, Video.parse(json["recommendedVideos"] as? [[String:Any]], ctx: $0).ids)
        }
        let streams = (json["formatStreams"] as? [[String:Any]])?.compactMap {
            VideoStream(dict: $0)
        } ?? []
        return await .init(video: result.0.object(database)!,
                           related: result.1.objects(database),
                           streams: streams)
    }
    
    func details(_ video: Video) async throws -> DetailsResult {
        try await get(uid: await video.async.uid()!)
    }
    
    func search(term: String, order: SearchOrder, offset: AnyHashable?) async throws -> Page<Video> {
        try await api.searchVideos(term: term, order: order, offset: offset)
            .parse(Video.self, database: database)
    }
    
    func extractLocalStreams(_ video: Video) async throws -> [VideoStream] {
        let uid = try await video.async.uid()!
        
        let streams = try await YouTube(videoID: uid).streams.filter { $0.subtype == "mp4" && $0.includesVideoTrack && $0.includesAudioTrack }
        
        return streams.compactMap {
            if $0.itag.itag == 22 {
                return VideoStream(label: "720p", url: $0.url)
            } else if $0.itag.itag == 18 {
                return VideoStream(label: "360p", url: $0.url)
            } else if $0.itag.itag == 36 {
                return VideoStream(label: "240p", url: $0.url)
            } else {
                return nil
            }
        }.sorted { $0.label < $1.label }
    }
}
