//
//  DataRepository.swift
//  IvoryCore
//
//  Created by Ilya Kuznetsov on 09/04/2023.
//

import Foundation
import DependencyContainer
import CoreData

public struct DataRepository {
    
    @DI.Static(DI.networkAPI) var api
    @DI.Static(DI.database) var database
    
    @DI.Static(DI.favorites) public var favorites
    @DI.Static(DI.kidsSpace) public var kidsSpace
    @DI.Static(DI.history) public var history
    @DI.Static(DI.watchLater) public var watchLater
    
    @DI.Static(DI.playlists) public var playlists
    @DI.Static(DI.channels) public var channels
    @DI.Static(DI.videos) public var videos
    @DI.Static(DI.comments) public var comments
}

@MainActor
public extension DataRepository {
    
    var previewContext: NSManagedObjectContext { database.viewContext }
    
    func makeExample<R: NSManagedObject>(_ closure: @escaping (_ ctx: NSManagedObjectContext) -> R) async -> R {
        await database.edit { closure($0).getObjectId }.object(database)!
    }
}
