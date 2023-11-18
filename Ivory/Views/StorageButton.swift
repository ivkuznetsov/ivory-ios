//
//  ContainerButton.swift
//  Ivory
//
//  Created by Ilya Kuznetsov on 16/01/2023.
//

import Foundation
import SwiftUI
import CoreData
import IvoryCore
import DependencyContainer

enum StorageType {
    case favorites
    case kidsSpace
    case history
    case watchLater
    
    var addTitle: String {
        switch self {
        case .favorites: return "Add to Favorites"
        case .kidsSpace: return "Add to Kids Space"
        case .watchLater: return "Watch Later"
        case .history: return ""
        }
    }
    
    var removeTitle: String {
        switch self {
        case .favorites: return "Remove from Favorites"
        case .kidsSpace: return "Remove from Kids Space"
        case .watchLater: return "Remove from Watch Later"
        case .history: return "Remove from History"
        }
    }
    
    var icon: Image {
        switch self {
        case .favorites: return Image(systemName: "star")
        case .kidsSpace: return Image("KidsSpace")
        case .watchLater: return Image(systemName: "square.and.arrow.down")
        case .history: return Image(systemName: "clock")
        }
    }
}

struct StorageButton: View {

    @StateObject private var storage: ObservableObjectWrapper<any StorageProtocol>
    private let has: ()->Bool
    private let toggle: ()->()
    private let storageType: StorageType
    
    init(storage: any VideoStorage, type: StorageType, item: Video) {
        _storage = .init(wrappedValue: .init(storage))
        has = { storage.has(item) }
        toggle = { storage.toggle(item) }
        storageType = type
    }
    
    init(storage: any ChannelStorage, type: StorageType, item: Channel) {
        _storage = .init(wrappedValue: .init(storage))
        has = { storage.has(item) }
        toggle = { storage.toggle(item) }
        storageType = type
    }
    
    init(storage: any PlaylistStorage, type: StorageType, item: Playlist) {
        _storage = .init(wrappedValue: .init(storage))
        has = { storage.has(item) }
        toggle = { storage.toggle(item) }
        storageType = type
    }
    
    var body: some View {
        let title = has() ? storageType.removeTitle : storageType.addTitle
        
        return Button {
            toggle()
        } label: {
            Label(title: { Text(title) }, icon: { storageType.icon })
        }
    }
}
