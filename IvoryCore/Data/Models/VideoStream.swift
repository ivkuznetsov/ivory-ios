//
//  VideoStream.swift
//  IvoryCore
//
//  Created by Ilya Kuznetsov on 08/04/2023.
//

import Foundation

public struct VideoStream: Hashable, CustomStringConvertible {
    
    public let label: String
    public let url: URL
    public let quality: Settings.Quality?
    
    init(label: String, url: URL, quality: Settings.Quality? = nil) {
        self.label = label
        self.url = url
        self.quality = quality
    }
    
    init?(dict: [String:Any]) {
        if let quality = dict["resolution"] as? String,
           let label = dict["qualityLabel"] as? String,
           let urlString = dict["url"] as? String,
           let url = URL(string: urlString) {
            
            self.label = label
            
            if quality == "360p" {
                self.quality = .sm360
            } else if quality == "hd720" {
                self.quality = .hd720
            } else {
                self.quality = nil
            }
            self.url = url
        } else {
            return nil
        }
    }
    
    public var description: String { label }
}
