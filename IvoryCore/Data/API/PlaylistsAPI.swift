//
//  PlaylistAPI.swift
//  IvoryCore
//
//  Created by Ilya Kuznetsov on 08/04/2023.
//

import Foundation
import NetworkKit
import Loader

extension NetworkAPI {
    
    func playlist(uid: String) async throws -> [String:Any] {
        let request = SerializableRequest<[String:Any]>(.init(endpoint: "playlists/\(uid)",
                                                              parameters: ["fields" : "playlistId,title"]))
        return try await network.load(request)
    }
    
    public func videos(playlistId: String, offset: AnyHashable?) async throws -> Page<[String:Any]> {
        var dict: [String:Any] = ["field" : "continuation,videos(authorId,lengthSeconds,videoId,published,title,videoThumbnails(url,quality),viewCount)"]
        dict["page"] = offset
        
        let request = SerializableRequest<[String:Any]>(.init(endpoint: "playlists/\(playlistId)",
                                                              parameters: dict))
        let json = try await network.load(request)["videos"] as? [[String:Any]] ?? []
        
        return Page(items: json, next: json.count > 0 ? ((offset as? Int ?? 0) + 1) : nil)
    }
}
