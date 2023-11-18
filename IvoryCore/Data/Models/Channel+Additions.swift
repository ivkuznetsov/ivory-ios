//
//  Channel+Additions.swift
//

import CoreData
import Database

extension Channel: Uploadable {
    
    public static func uid(from source: [String:Any]) -> String? { source["authorId"] as? String }
    
    public var toSource: [String:Any] {
        var dict: [String:Any] = ["authorId" : uid!]
        dict["author"] = title
        dict["thumbnail"] = thumbnail
        return dict
    }
    
    public func update(_ dict: [String:Any]) {
        if let value = dict["author"] as? String {
            title = value.replacingOccurrences(of: "\n", with: " ")
        }
        if let value = dict["thumbnail"] as? String {
            thumbnail = value
        }
        if let value = dict["subCount"] as? Int64 {
            subscribersCount = value
        }
        
        if let images = dict["authorBanners"] as? [[String:Any]],
            let image = images.count > 2 ? images[2] : images.first {
            backgroundImage = image["url"] as? String
            
            loadedDate = Date() // full channel loaded
        }
        updateThumbnail(dict)
    }
    
    public func updateThumbnail(_ dict: [String:Any]) {
        if let images = dict["authorThumbnails"] as? [[String:Any]],
           let image = images.count > 1 ? images[images.count - 2] : images.last,
           let thumbnail = image["url"] as? String {
            self.thumbnail = thumbnail.hasPrefix("//") ? ("https:" + thumbnail) : thumbnail
        }
    }
}

public extension Channel {
    
    var allVideos: Set<Video> {
        if let videos {
            return videos as! Set<Video>
        }
        return Set()
    }
    
    var thumbnailURL: URL? {
        if let path = thumbnail {
            return URL(string: path)
        }
        return nil
    }
    
    var abbriviatedSubs: String {
        if subscribersCount > 0 {
            let string = NumberFormatter.abbreviatedStringFrom(number: subscribersCount)
            return string + (subscribersCount == 1 ? " subscriber" : " subscribers")
        }
        return ""
    }
    
    var shareURL: URL { URL(string: "http://www.youtube.com/channel/\(uid!)")! }
}
