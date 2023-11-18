//
//  URL+Supported.swift
//

import Foundation

public extension URL {
    
    func supported() -> Bool {
        if let host = host {
            return host.hasPrefix("youtube.") || host.hasPrefix("www.youtube.") || host.hasPrefix("m.youtube.") || host == "youtu.be"
        }
        return false
    }
}
