//
//  PlaylistsRepostory.swift
//  IvoryCore
//
//  Created by Ilya Kuznetsov on 18/11/2023.
//

import Foundation
import Loader
import DependencyContainer

public protocol PlaylistsRepostory {
    
    func get(uid: String) async throws -> Playlist
    
    func videos(_ playlist: Playlist, offset: AnyHashable?) async throws -> Page<Video>
    
    func search(term: String, order: SearchOrder, offset: AnyHashable?) async throws -> Page<Playlist>
}

public struct PlaylistsRepostoryMock: PlaylistsRepostory {
    
    @DI.Static(DI.database) private var database
    
    public init() {}
    
    public func get(uid: String) async throws -> Playlist {
        await database.edit { Playlist.example(ctx: $0).getObjectId }.object(database)!
    }
    
    public func videos(_ playlist: Playlist, offset: AnyHashable?) async throws -> Page<Video> {
        Page(items: await database.edit { Video.exampleArray(ctx: $0).ids }.objects(database))
    }
    
    public func search(term: String, order: SearchOrder, offset: AnyHashable?) async throws -> Page<Playlist> {
        Page(items: await database.edit { Playlist.exampleArray(ctx: $0).ids }.objects(database))
    }
}
