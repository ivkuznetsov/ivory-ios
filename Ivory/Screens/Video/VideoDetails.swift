//
//  VideoContent.swift
//  Ivory
//
//  Created by Ilya Kuznetsov on 21/01/2023.
//

import Foundation
import IvoryCore
import Loader

final class VideoDetails: ObservableObject, Hashable {
    
    enum Content: Hashable {
        case video(Video)
        case watchLater(Video)
        case playlist(Video, Paging<Video>.CommonManager)
        
        var video: Video {
            switch self {
            case .video(let video): return video
            case .watchLater(let video): return video
            case .playlist(let video, _): return video
            }
        }
        
        var isJustVideo: Bool {
            if case .video(_) = self { return true } else { return false }
        }
        
        static func == (lhs: Content, rhs: Content) -> Bool {
            lhs.hashValue == rhs.hashValue
        }
        
        func hash(into hasher: inout Hasher) {
            hasher.combine(video.hash)
            
            switch self {
            case .playlist(_, _):
                hasher.combine(1)
            case .watchLater(_):
                hasher.combine(2)
            default:
                break
            }
        }
    }
    
    @Published var content: Content
    
    init(_ content: Content) {
        self.content = content
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(content)
    }
    
    static func == (lhs: VideoDetails, rhs: VideoDetails) -> Bool { lhs.hashValue == rhs.hashValue }
}
