//
//  VideosRepository.swift
//  IvoryCore
//
//  Created by Ilya Kuznetsov on 18/11/2023.
//

import Foundation
import Loader
import DependencyContainer

public struct DetailsResult: Equatable {
    public let video: Video
    public let related: [Video]
    public let streams: [VideoStream]
}

public protocol VideosRepository {
    
    func popular(_ category: VideoCategory) async throws -> [Video]
    
    func get(uid: String) async throws -> DetailsResult
    
    func details(_ video: Video) async throws -> DetailsResult
    
    func search(term: String, order: SearchOrder, offset: AnyHashable?) async throws -> Page<Video>
    
    func extractLocalStreams(_ video: Video) async throws -> [VideoStream]
}

public struct VideosRepositoryMock: VideosRepository {

    @DI.Static(DI.database) private var database
    
    public init() {}
    
    public func popular(_ category: VideoCategory) async throws -> [Video] {
        await database.edit { Video.exampleArray(ctx: $0).ids }.objects(database)
    }
    
    public func get(uid: String) async throws -> DetailsResult {
        await .init(video: database.edit { Video.example(ctx: $0).getObjectId }.object(database)!,
                    related: database.edit { Video.exampleArray(ctx: $0).ids }.objects(database),
                    streams: [.init(label: "720p",
                                    url: URL(string: "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4")!,
                                    quality: .hd720)])
    }
    
    public func details(_ video: Video) async throws -> DetailsResult {
        try await get(uid: video.async.uid()!)
    }
    
    public func search(term: String, order: SearchOrder, offset: AnyHashable?) async throws -> Page<Video> {
        Page(items: await database.edit { Video.exampleArray(ctx: $0).ids }.objects(database))
    }
    
    public func extractLocalStreams(_ video: Video) async throws -> [VideoStream] { [] }
}
