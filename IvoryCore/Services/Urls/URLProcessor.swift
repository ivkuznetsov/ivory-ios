//
//  URLProcessor.swift
//  Ivory
//
//  Created by Ilya Kuznetsov on 18/01/2023.
//

import Foundation
import UIKit
import CommonUtils
import DependencyContainer

public struct URLProcessor {
    
    @DI.Static(DI.data) private var data
    
    public init() { }
    
    public func processURLFromPasterboard() throws -> URL {
        var url = UIPasteboard.general.url ?? UIPasteboard.general.urls?.first
        
        if url == nil, let string = UIPasteboard.general.string ?? UIPasteboard.general.strings?.first {
            url = URL(string: string)
        }
        
        if let url = url, url.host != nil {
            if url.supported() {
                return url
            } else {
                throw RunError.custom("It seems the copied URL is not a YouTube link")
            }
        } else {
            throw RunError.custom("Copy a Youtube video link in browser and tap again")
        }
    }
    
    public func open(url: URL) async -> AnyHashable? {
        
        var guardURL: URL? = url
        
        if let scheme = url.scheme, scheme == "ivory" {
            if url.absoluteString.hasPrefix("ivory://https://") || url.absoluteString.hasPrefix("ivory://http://") {
                guardURL = URL(string: url.absoluteString.replacingOccurrences(of: "ivory://", with: ""))
            } else {
                guardURL = URL(string: url.absoluteString.replacingOccurrences(of: "ivory://", with: "https://"))
            }
        }
        
        guard var theURL = guardURL else { return nil }
        
        theURL = await ShortLinksExtractor.extract(url: theURL)
        
        if theURL.supported(),
           let urlComponents = URLComponents(url: theURL, resolvingAgainstBaseURL: true) {
            
            let items = urlComponents.queryItems
            let components = urlComponents.path.components(separatedBy: "/").filter { $0 != "" }
            
            if let items = items {
                if (items.count == 1 && items.count == 0) || (components.count == 2 && components[0] == "channel") {
                    if let item = try? await data.channels.get(uid: components.last!) {
                        return item
                    }
                } else if let videoId = items.first(where: { $0.name == "v" })?.value, components.count == 1 && components.last! == "watch", videoId.count > 0 {
                    if let item = try? await data.videos.get(uid: videoId) {
                        return item.video
                    }
                    return nil
                } else if let playlistId = items.first(where: { $0.name == "list" })?.value, components.count == 1 && components.last! == "playlist", playlistId.count > 0 {
                    if let item = try? await data.playlists.get(uid: playlistId) {
                        return item
                    }
                }
            } else if components.count == 1 && theURL.host == "youtu.be" {
                if let item = try? await data.videos.get(uid: components[0]) {
                    return item.video
                }
            }
        }
        
        Task { @MainActor [theURL] in
            await UIApplication.shared.open(theURL)
        }
        return nil
    }
}
