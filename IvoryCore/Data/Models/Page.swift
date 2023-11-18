//
//  Page.swift
//  IvoryCore
//
//  Created by Ilya Kuznetsov on 28/03/2023.
//

import Foundation
import Database
import CoreData
import Loader

extension Database {
    
    func parse<DataType: Fetchable & NSManagedObject>(_ type: DataType.Type, items: [DataType.Source]) async -> [DataType] {
        await edit { DataType.parse(items, ctx: $0).ids }.objects(self)
    }
}

extension Page {
    
    func parse<DataType: Fetchable & NSManagedObject>(_ type: DataType.Type, database: Database) async -> Page<DataType> where DataType.Source == Item {
        Page<DataType>(items: await database.parse(type, items: items), next: next)
    }
}
