//
//  Settings.swift
//  YouPlayer
//
//  Created by Ilya Kuznetsov on 11/22/17.
//  Copyright © 2017 Ilya Kuznetsov. All rights reserved.
//

import Foundation
import CommonUtils
import Combine

public final class Settings: ObservableObject {
    
    public enum Quality: String, Codable, CustomStringConvertible, CaseIterable {
        case hd720 = "720p"
        case sm360 = "360p"
        
        public var description: String { rawValue }
    }
    
    @PublishedStorage("quality", defaultValue: Quality.hd720) public var quality
    @PublishedStorage("forceFullscreen", defaultValue: false) public var forceFullscreen
    @PublishedStorage("autoStartVideo", defaultValue: true) public var autoStartVideo
    @PublishedStorage("backgroundPlayback", defaultValue: true) public var backgroundPlayback
    @PublishedStorage("autoPlayNextVideo", defaultValue: true) public var autoPlayNextVideo
    @PublishedStorage("hideKidsSpace", defaultValue: false) public var hideKidsSpace
    @PublishedStorage("deleteFromWatchLater", defaultValue: true) public var deleteFromWatchLater
}
