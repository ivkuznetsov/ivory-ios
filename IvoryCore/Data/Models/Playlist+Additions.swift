//
//  Paylist+Additions.swift
//

import Database

extension Playlist: Uploadable {
    
    public static func uid(from source: [String:Any]) -> String? { source["playlistId"] as? String }
    
    public var toSource: [String:Any] {
        var dict: [String:Any] = ["playlistId" : uid!]
        dict["title"] = title
        dict["playlistThumbnail"] = thumbnail
        dict["videoCount"] = count
        return dict
    }
    
    public func update(_ dict: [String:Any]) {
        guard let ctx = managedObjectContext else { return }
        
        if let value = dict["title"] as? String {
            title = value.replacingOccurrences(of: "\n", with: " ")
        }
        if let value = dict["playlistThumbnail"] as? String {
            thumbnail = value
        }
        if let value = dict["videoCount"] as? Int64 {
            count = value
        }
        
        if let channelId = dict["authorId"] as? String, channelId.isValid {
            if channel == nil {
                channel = Channel.findOrCreatePlaceholder(uid: channelId, ctx: ctx)
            }
            if let author = dict["author"] as? String, author.isValid {
                channel?.title = author.replacingOccurrences(of: "\n", with: " ")
            }
        }
    }
}

public extension Playlist {
    
    var thumbnailURL: URL? {
        if let path = thumbnail {
            return URL(string: path)
        }
        return nil
    }
    
    var shareURL: URL { URL(string: "https://www.youtube.com/playlist/?list=\(uid!)")! }
}
