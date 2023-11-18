//
//  CommentsRepositoryImp.swift
//  IvoryCore
//
//  Created by Ilya Kuznetsov on 18/11/2023.
//

import Foundation
import CommonUtils
import Loader
import DependencyContainer

struct CommentsRepositoryImp: CommentsRepository {
    
    @DI.Static(DI.database) private var database
    @DI.Static(DI.networkAPI) private var api
    
    func comments(_ video: Video, offset: AnyHashable?) async throws -> Page<Comment> {
        let page = try await api.comments(try await video.async.uid()!, source: .video, offset: offset)
        return Page(items: page.items.compactMap { Comment(dict: $0) }, next: page.next)
    }
    
    func moreReplies(_ video: Video, comment: Comment) async throws {
        let page = try await api.comments(try await video.async.uid()!, source: .replies, offset: comment.nextReplies)
        let comments = page.items.compactMap {
            if let comment = Comment(dict: $0) {
                comment.rootComment = comment
                return comment
            }
            return nil
        }
        
        await MainActor.run {
            comment.replies += comments
            comment.nextReplies = page.next
        }
    }
}
