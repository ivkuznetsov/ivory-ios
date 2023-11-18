//
//  StorageMock.swift
//  IvoryCore
//
//  Created by Ilya Kuznetsov on 15/11/2023.
//

import Foundation
import CoreData

extension MockStorage: VideoStorage where Stored == Video {

    public static func make(ctx: NSManagedObjectContext, withObjects: Bool = true) -> Self {
        let mock = self.init()
        
        if withObjects {
            mock.items = Video.exampleArray(ctx: ctx)
        }
        return mock
    }
}

extension MockStorage: HistoryStorage where Stored == Video { }

extension MockStorage: ChannelStorage where Stored == Channel { 
    
    public static func make(ctx: NSManagedObjectContext, withObjects: Bool = true) -> Self {
        let mock = self.init()
        
        if withObjects {
            mock.items = Channel.exampleArray(ctx: ctx)
        }
        return mock
    }
}

extension MockStorage: PlaylistStorage where Stored == Playlist { 
    
    public static func make(ctx: NSManagedObjectContext, withObjects: Bool = true) -> Self {
        let mock = self.init()
        
        if withObjects {
            mock.items = Playlist.exampleArray(ctx: ctx)
        }
        return mock
    }
}

@MainActor
public extension StorageGroup {
    
    static func makeMocked(ctx: NSManagedObjectContext, withObjects: Bool = true) -> StorageGroup {
        .init(videos: MockStorage<Video>.make(ctx: ctx, withObjects: withObjects),
              channels: MockStorage<Channel>.make(ctx: ctx, withObjects: withObjects),
              playlists: MockStorage<Playlist>.make(ctx: ctx, withObjects: withObjects))
    }
}

public final class MockStorage<Stored: Hashable>: StorageProtocol {
    
    @Published public var items: [Stored] = []
    
    public func has(_ item: Stored) -> Bool { items.contains(item) }
    
    public func add(_ item: Stored) async throws {
        items.append(item)
    }
    
    public func remove(_ item: Stored) async throws {
        items.remove(item)
    }
    
    public func removeAll() async throws {
        items.removeAll()
    }
    
    public func position(video: Video) -> Double { 0 }
    
    public func save(position: Double, video: Video) { }
    
    public init() { }
}
