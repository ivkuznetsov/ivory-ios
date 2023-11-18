//
//  VideosAPI.swift
//

import Foundation
import NetworkKit
import CommonUtils

public enum VideoCategory: String, CaseIterable, CustomStringConvertible, Hashable {
    case defaultType = "Default"
    case music = "Music"
    case gaming = "Gaming"
    case movies = "Movies"
    
    public var title: String { self == .defaultType ? "Trending" : rawValue }
    
    public var description: String { title }
}

extension NetworkAPI {
    
    func popularVideos(_ category: VideoCategory) async throws -> [[String:Any]] {
        let scope = "authorId,published,title,author,videoId,lengthSeconds,videoThumbnails(url,quality),viewCount"
        let request = SerializableRequest<[[String:Any]]>(.init(endpoint: "trending",
                                                                parameters: ["type" : category.rawValue,
                                                                             "fields" : scope]))
        return try await network.load(request)
    }
    
    func video(uid: String) async throws -> [String:Any] {
        let scope = "videoId,formatStreams,viewCount,likeCount,description,published,title,videoThumbnails(url,quality),author,lengthSeconds,authorId,authorThumbnails(url),recommendedVideos(author,videoThumbnails(url,quality),authorId,lengthSeconds,videoId,title,viewCount)"
        let request = SerializableRequest<[String:Any]>(.init(endpoint: "videos/\(uid)",
                                                                parameters: ["fields" : scope]))
        return try await network.load(request)
    }
}
