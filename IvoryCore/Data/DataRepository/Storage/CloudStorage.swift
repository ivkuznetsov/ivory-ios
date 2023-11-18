//
//  CloudContainer.swift
//

import Foundation
import CoreData
import Database
import Combine
import CommonUtils
import DependencyContainer

//  ____________________        _______________         _______________
// |                    |      |               |       |               |
// |    CloudStorage    | -->> | ContainerLink | <<--> | ContainedItem |
// |____________________|      |_______________|       |_______________|
//                                     |
//                         --------------------------
//                        |      ReferencedType      |
//                        | (Video/Channel/Playlist) |
//                        |__________________________|
//
// CloudStorage - a storage for specified type of container links
//
// ContainerLink - a link to some associated NSManagedObject, linking happens by uid and type of associaed object
//
// ContainedItem - a dictionary representation of associated NSManagedObject. This used to recreate NSManagedObject if there is no one in local storage. This may happen during cloud sync, or reinstalling the app.
//
// ConainerLink can reference the same associated object, thus it has one to many relationship with ContainedItem.
// The relationship is made with retain/release like style rather than real CoreData relationship, due the inconsistent synchronization in CloudKit over CoreData and lack of 'deny' delete rule.
//

public protocol StorageReference {
    associatedtype ReferencedType: NSManagedObject & Uploadable where ReferencedType.Source == [String:Any], ReferencedType.Id == String?
}

extension FavoriteVideo: StorageReference {
    public typealias ReferencedType = Video
}

extension FavoriteChannel: StorageReference {
    public typealias ReferencedType = Channel
}

extension FavoritePlaylist: StorageReference {
    public typealias ReferencedType = Playlist
}

extension KidsSpaceVideo: StorageReference {
    public typealias ReferencedType = Video
}

extension KidsSpaceChannel: StorageReference {
    public typealias ReferencedType = Channel
}

extension KidsSpacePlaylist: StorageReference {
    public typealias ReferencedType = Playlist
}

extension WatchLaterVideo: StorageReference {
    public typealias ReferencedType = Video
}

extension HistoryVideo: StorageReference {
    public typealias ReferencedType = Video
}

extension CloudStorage: VideoStorage where Reference.ReferencedType == Video { }
extension CloudStorage: ChannelStorage where Reference.ReferencedType == Channel { }
extension CloudStorage: PlaylistStorage where Reference.ReferencedType == Playlist { }

extension CloudStorage<HistoryVideo>: HistoryStorage {
    
    public func position(video: Video) -> Double { Double(reference(video)?.position ?? 0) }
    
    public func save(position: Double, video: Video) {
        if let reference = reference(video) {
            Task {
                try await database.edit(reference) { reference, _ in
                    reference.position = Float(position)
                }
            }
        }
    }
}

fileprivate extension ContainerLink {
    
    var item: ContainedItem? {
        if let ctx = managedObjectContext {
            return ContainedItem.findFirst(\.uid, uid!, ctx: ctx)
        }
        return nil
    }
    
    func deleteWithItem() {
        if let item = item {
            item.links -= 1
            if item.links <= 0 {
                item.delete()
            }
        }
        delete()
    }
}

@MainActor
public final class CloudStorage<Reference: ContainerLink & StorageReference> : StorageProtocol {
    public typealias Stored = Reference.ReferencedType
    
    @DI.Static(DI.database) var database
    
    private let limit: Int?
    
    private var references: [String : ObjectId<Reference>] = [:]
    @Published public private(set) var items: [Reference.ReferencedType] = []
    
    nonisolated public init(limit: Int? = nil) {
        self.limit = limit
        Task {
            await setup()
            try await reload()
        }
    }
    
    private func setup() {
        Reference.objectsDidChange(database).sink { [weak self] _ in
            if let wSelf = self {
                Task { try await wSelf.reload() }
            }
        }.retained(by: self)
    }
    
    private func reload() async throws {
        var references: [String : ObjectId<Reference>] = [:]
        
        let items = await database.edit { ctx -> [ObjectId<Reference.ReferencedType>] in
            var ids = Set<String>()
            
            return Reference.allSortedBy(key: \.date!, ctx: ctx).compactMap { item -> Reference.ReferencedType? in
                guard !ids.contains(item.uid!) else {
                    item.deleteWithItem()
                    return nil
                }
                references[item.uid!] = item.getObjectId
                ids.insert(item.uid!)
                
                let object = Reference.ReferencedType.findOrCreatePlaceholder(uid: item.uid!, ctx: ctx)
                
                if object.isInserted, let dict = item.item?.content {
                    object.update(dict)
                }
                return object
            }.ids
        }.objects(database)
        
        self.references = references
        self.items = items
    }
    
    public func removeAll() async throws {
        await database.edit {
            Reference.all($0).forEach { $0.deleteWithItem() }
        }
    }
    
    public func has(_ item: Stored) -> Bool { references[item.uid!] != nil }
    
    public func reference(_ item: Stored) -> Reference? {
        references[item.uid!]?.object(database)
    }
    
    public func add(_ item: Stored) async throws {
        try await database.edit(item) { item, ctx in
            let link = Reference.findFirst(\.uid, item.uid!, ctx: ctx) ?? Reference(context: ctx)
            link.date = Date()
            
            if link.isInserted {
                link.uid = item.uid
                
                let containedItem = ContainedItem.findFirst(\.uid, item.uid!, ctx: ctx) ?? ContainedItem(context: ctx)
                containedItem.links += 1
                
                if containedItem.isInserted {
                    containedItem.uid = item.uid
                    containedItem.content = item.toSource
                }
                
                if let limit = self.limit {
                    let allItems = Reference.all(ctx)
                    
                    if allItems.count > limit {
                        allItems.min { $0.date ?? .distantFuture < $1.date ?? .distantFuture }?.deleteWithItem()
                    }
                }
            }
        }
    }
    
    public func remove(_ item: Stored) async throws {
        if let reference = references[item.uid!] {
            try await database.edit(reference) { reference, ctx in
                reference.deleteWithItem()
            }
        }
    }
}
