//
//  Examples.swift
//  IvoryCore
//
//  Created by Ilya Kuznetsov on 15/11/2023.
//

import Foundation
import CoreData

public extension Channel {
    
    static func example(ctx: NSManagedObjectContext) -> Channel {
        let uid = "UCqECaJ8Gagnn7YCbPEzWH6g"
        let channel = Channel(context: ctx)
        channel.uid = uid
        channel.latestVideosLoad = Date()
        channel.loadedDate = Date()
        channel.subscribersCount = 55200000
        channel.title = "Taylor Swift"
        channel.thumbnail = "https://yt3.googleusercontent.com/Udfgx_So2Z5UBHtnX7ZWtGt62Znvjr7BSBuboSz89A3-o6POuHot6QvldEp1siGncPDEwr7-Ag=s88-c-k-c0x00ffffff-no-rj-mo"
        return channel
    }
    
    static func exampleArray(ctx: NSManagedObjectContext) -> [Channel] {
        [Channel.example(ctx: ctx),
         Channel.example(ctx: ctx),
         Channel.example(ctx: ctx),
         Channel.example(ctx: ctx),
         Channel.example(ctx: ctx),
         Channel.example(ctx: ctx),
         Channel.example(ctx: ctx)]
    }
}

public extension Video {
    
    static func example(ctx: NSManagedObjectContext) -> Video {
        let video = Video(context: ctx)
        video.uid = "h8DLofLM7No"
        video.durationInterval = 211
        video.title = "Taylor Swift - Lavender Haze (Official Music Video)"
        video.published = Date()
        video.views = 50419078
        video.thumbnail = "https://api.ivoryapp.de/vi/h8DLofLM7No/mqdefault.jpg"
        video.videoDescription = "Official music video for Lavender Haze by Taylor Swift from the album Midnights.\n\nBuy/Download/Stream Midnights: https://taylor.lnk.to/taylorswiftmidnights \n\nGet tickets to Taylor Swift | The Er"
        video.channel = Channel.example(ctx: ctx)
        return video
    }
    
    static func exampleArray(ctx: NSManagedObjectContext) -> [Video] {
        [Video.example(ctx: ctx),
         Video.example(ctx: ctx),
         Video.example(ctx: ctx),
         Video.example(ctx: ctx),
         Video.example(ctx: ctx),
         Video.example(ctx: ctx),
         Video.example(ctx: ctx)]
    }
}

public extension Playlist {
    
    static func example(ctx: NSManagedObjectContext) -> Playlist {
        let playlist = Playlist(context: ctx)
        playlist.uid = "PLINj2JJM1jxP5aYiX47uBCRu9g8JItDWp"
        playlist.count = 23
        playlist.title = "Taylor Swift - Midnights"
        playlist.thumbnail = "https://i.ytimg.com/vi/h8DLofLM7No/hqdefault.jpg?sqp=-oaymwEXCOADEI4CSFryq4qpAwkIARUAAIhCGAE=&rs=AOn4CLCcKbCTqVOx__PFmMlfZx1tY7YTsg"
        playlist.channel = Channel.example(ctx: ctx)
        return playlist
    }
    
    static func exampleArray(ctx: NSManagedObjectContext) -> [Playlist] {
        [Playlist.example(ctx: ctx),
         Playlist.example(ctx: ctx),
         Playlist.example(ctx: ctx),
         Playlist.example(ctx: ctx),
         Playlist.example(ctx: ctx),
         Playlist.example(ctx: ctx),
         Playlist.example(ctx: ctx)]
    }
}

public extension Comment {
    
    static func example(hasChildren: Bool = false) -> Comment {
        .init(authorName: "John Smith",
              date: Date().addingTimeInterval(-10000),
              content: "Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book. It has survived not only five centuries, but also the leap into electronic typesetting, remaining essentially unchanged.",
              repliesCount: hasChildren ? 10 : 0)
    }
    
    static func exampleArray() -> [Comment] {
        [Comment.example(),
         Comment.example(hasChildren: true),
         Comment.example(),
         Comment.example(hasChildren: true),
         Comment.example(),
         Comment.example(),
         Comment.example(hasChildren: true)]
    }
}
