//
//  Comment+Additions.swift
//

import Foundation

public final class Comment: Hashable, ObservableObject {
    
    public let id = UUID()
    public let authorName: String
    public let date: Date
    public let content: String
    public let repliesCount: Int64
    public var replies: [Comment] = []
    public var nextReplies: AnyHashable?
    public weak var rootComment: Comment?
    
    init(authorName: String, 
         date: Date,
         content: String,
         repliesCount: Int64 = 0,
         replies: [Comment] = [],
         nextReplies: AnyHashable? = nil,
         rootComment: Comment? = nil) {
        self.authorName = authorName
        self.date = date
        self.content = content
        self.repliesCount = repliesCount
        self.replies = replies
        self.nextReplies = nextReplies
        self.rootComment = rootComment
    }
    
    init?(dict: [String:Any]) {
        if let content = dict["content"] as? String {
            authorName = dict["author"] as? String ?? ""
            date = Date(timeIntervalSince1970: dict["published"] as? Double ?? 0)
            repliesCount = (dict["replies"] as? [String:Any])?["replyCount"] as? Int64 ?? 0
            nextReplies = (dict["replies"] as? [String:Any])?["continuation"] as? AnyHashable
            self.content = content
        } else {
            return nil
        }
    }
    
    public static func == (lhs: Comment, rhs: Comment) -> Bool { lhs.hashValue == rhs.hashValue }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine("comment")
        hasher.combine(id)
    }
}
