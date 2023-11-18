//
//  SearchAPI.swift
//  IvoryCore
//
//  Created by Ilya Kuznetsov on 08/04/2023.
//

import Foundation
import NetworkKit
import Loader

public enum SearchOrder: String, CaseIterable, CustomStringConvertible {
    case relevance = "relevance"
    case date = "upload_date"
    case rating = "rating"
    case viewCount = "view_count"
    
    public var description: String {
        switch self {
        case .relevance: return "By Relevance"
        case .date: return "By Date"
        case .rating: return "By Rating"
        case .viewCount: return "By Views Count"
        }
    }
}

extension NetworkAPI {
    
    func searchVideos(term: String, order: SearchOrder, offset: AnyHashable?) async throws -> Page<[String:Any]> {
        try await search(term: term,
                         scope: "authorId,author,lengthSeconds,videoId,published,title,videoThumbnails(url,quality),viewCount",
                         type: "video",
                         order: order,
                         offset: offset)
    }
    
    func searchChannels(term: String, order: SearchOrder, offset: AnyHashable?) async throws -> Page<[String:Any]> {
        try await search(term: term,
                         scope: "author,authorId,authorThumbnails(url),subCount",
                         type: "channel",
                         order: order,
                         offset: offset)
    }
    
    func searchPlaylists(term: String, order: SearchOrder, offset: AnyHashable?) async throws -> Page<[String:Any]> {
        try await search(term: term,
                         scope: "videoCount,playlistThumbnail,authorId,title,playlistId,author",
                         type: "playlist",
                         order: order,
                         offset: offset)
    }
    
    private func search(term: String, scope: String, type: String, order: SearchOrder, offset: AnyHashable?) async throws -> Page<[String:Any]> {
        var params: [String:Any] = ["fields":scope, "q":term, "sort_by":order.rawValue, "type":type]
        params["page"] = offset
        
        let request = SerializableRequest<[[String:Any]]>(.init(endpoint: "search", parameters: params))
        let json = try await network.load(request)
        
        return Page(items: json, next: json.count > 0 ? ((offset as? Int ?? 0) + 1) : nil)
    }
}

