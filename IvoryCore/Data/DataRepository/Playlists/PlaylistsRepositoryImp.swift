//
//  PlaylistsRepositoryMock.swift
//  IvoryCore
//
//  Created by Ilya Kuznetsov on 18/11/2023.
//

import Foundation
import DependencyContainer
import CommonUtils
import Loader

struct PlaylistsRepostoryImp: PlaylistsRepostory {
    
    @DI.Static(DI.database) private var database
    @DI.Static(DI.networkAPI) private var api
    
    func get(uid: String) async throws -> Playlist {
        if let playlist = try await database.parse(Playlist.self, items: [api.playlist(uid: uid)]).first {
            return playlist
        }
        throw RunError.custom("Playlist Not Found")
    }
    
    func videos(_ playlist: Playlist, offset: AnyHashable?) async throws -> Page<Video> {
        try await api.videos(playlistId: try await playlist.async.uid()!, offset: offset)
            .parse(Video.self, database: database)
    }
    
    func search(term: String, order: SearchOrder, offset: AnyHashable?) async throws -> Page<Playlist> {
        try await api.searchPlaylists(term: term, order: order, offset: offset)
            .parse(Playlist.self, database: database)
    }
}
