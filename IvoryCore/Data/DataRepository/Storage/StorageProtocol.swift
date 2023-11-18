//
//  StorageProtocol.swift
//  IvoryCore
//
//  Created by Ilya Kuznetsov on 15/11/2023.
//

import Foundation
import CoreData
import Database

@MainActor
public protocol StorageProtocol: ObservableObject {
    associatedtype Stored: Hashable
    
    var items: [Stored] { get }
    
    func has(_ item: Stored) -> Bool
    
    func add(_ item: Stored) async throws
    
    func remove(_ item: Stored) async throws
    
    func removeAll() async throws
}

public extension StorageProtocol {
    
    func add(_ item: Stored) {
        Task { try await add(item) }
    }
    
    func remove(_ item: Stored) {
        Task { try await remove(item) }
    }
    
    func toggle(_ item: Stored) {
        has(item) ? remove(item) : add(item)
    }
    
    func nextAfter(_ item: Stored) -> Stored? {
        if let index = items.firstIndex(of: item) {
            return items[safe: index + 1]
        }
        return nil
    }
}
