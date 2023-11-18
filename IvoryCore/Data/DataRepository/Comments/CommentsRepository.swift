//
//  CommentsRepository.swift
//  IvoryCore
//
//  Created by Ilya Kuznetsov on 18/11/2023.
//

import Foundation
import Loader

public protocol CommentsRepository {
    
    func comments(_ video: Video, offset: AnyHashable?) async throws -> Page<Comment>
    
    func moreReplies(_ video: Video, comment: Comment) async throws
}

public struct CommentsRepositoryMock: CommentsRepository {

    public init() {}
    
    public func comments(_ video: Video, offset: AnyHashable?) async throws -> Page<Comment> {
        Page(items: Comment.exampleArray())
    }
    
    public func moreReplies(_ video: Video, comment: Comment) async throws {
        await MainActor.run {
            comment.replies += Comment.exampleArray().map {
                $0.rootComment = comment
                return $0
            }
            comment.nextReplies = nil
        }
    }
}
