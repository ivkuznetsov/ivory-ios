//
//  Video+Additions.swift
//

import Database
import CoreData

extension Video: Uploadable {
    
    public static func uid(from dict: [String:Any]) -> String? { dict["videoId"] as? String }
    
    public var toSource: [String:Any] {
        var dict: [String:Any] = ["videoId" : uid!]
        dict["title"] = title
        dict["thumbnail"] = thumbnail
        dict["published"] = published?.timeIntervalSince1970
        dict["viewCount"] = views
        dict["lengthSeconds"] = durationInterval
        return dict
    }
    
    public func update(_ dict: [String:Any]) {
        guard let ctx = managedObjectContext else { return }
        
        if channel == nil, let channelId = dict["authorId"] as? String {
            channel = Channel.findOrCreatePlaceholder(uid: channelId, ctx: ctx)
            
            if let title = dict["author"] as? String {
                channel?.title = title.replacingOccurrences(of: "\n", with: " ")
            }
        }
        channel?.updateThumbnail(dict)
        
        if let value = dict["title"] as? String {
            title = value.replacingOccurrences(of: "\n", with: " ")
        }
        if let value = dict["description"] as? String {
            videoDescription = value
        }
        if let value = dict["thumbnail"] as? String {
            thumbnail = value
        }
        if let value = dict["viewCount"] as? Int64, value > 0 {
            views = value
        }
        if let value = dict["lengthSeconds"] as? Int64 {
            durationInterval = Double(value)
            live = value == 0
        }
        if let value = dict["published"] as? Double {
            published = Date(timeIntervalSince1970: value)
        }
        
        if let thumb = dict["videoThumbnails"] as? [[String:Any]] {
            
            let thumbnails: [String : [String:Any]] = thumb.reduce(into: [:]) {
                if let quality = $1["quality"] as? String {
                    $0[quality] = $1
                }
            }
            
            if let thumbnail = thumbnails["medium"] ?? thumbnails["high"] ?? thumbnails["maxres"] ?? thumbnails["default"],
               let url = thumbnail["url"] as? String {
                self.thumbnail = url
            }
        }
    }    
}

public extension Video {
    
    var isNew: Bool {
        if let time = published?.timeIntervalSinceNow {
            return abs(time) < (3 * 24 * 60 * 60) // 3 weeks
        }
        return false
    }
    
    var thumbnailURL: URL? {
        if let path = thumbnail {
            return URL(string: path)
        }
        return nil
    }
    
    var abbriviatedViews: String? {
        if views == 0 { return nil }
        
        let string = NumberFormatter.abbreviatedStringFrom(number: views)
        return string + (views == 1 ? " view" : " views")
    }
    
    func shareURL(timestamp: Double? = nil) -> URL {
        if let timestamp {
            return URL(string: "http://www.youtube.com/watch?v=\(uid!)&t=\(timestamp)")!
        } else {
            return URL(string: "http://www.youtube.com/watch?v=\(uid!)")!
        }
    }
}
