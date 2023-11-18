//
//  CommentsAPI.swift
//  IvoryCore
//
//  Created by Ilya Kuznetsov on 08/04/2023.
//

import Foundation
import NetworkKit
import Loader

extension NetworkAPI {
    
    enum CommentsSource {
        case video
        case replies
        
        var action: String? { self == .replies ? "action_get_comment_replies" : nil }
    }
    
    func comments(_ videoId: String, source: CommentsSource, offset: AnyHashable?) async throws -> Page<[String:Any]> {
        var parameters: [String : Any] = ["fields" : "comments(content,published,replies,author),continuation"]
        parameters["action"] = source.action
        parameters["continuation"] = offset
        
        let request = SerializableRequest<[String:Any]>(.init(endpoint: "comments/\(videoId)", parameters: parameters))
        let json = try await network.load(request)
        return Page(items: json["comments"] as? [[String:Any]] ?? [],
                    next: json["continuation"] as? String)
    }
}
