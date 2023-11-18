//
//  DataLayer.swift
//  Ivory
//
//  Created by Ilya Kuznetsov on 20/12/2022.
//

import Foundation
import NetworkKit
import Database
import DependencyContainer
import CommonUtils

extension String {
    static let baseURL = "https://url.to.your.backend"
    static let authKey: String? = nil // api key for basic authorization
    static let iCloudIdentifier = "iCloud.com.ilyakuznetsov.ivorycontainer"
}

public extension DI {
    static let data = Key<DataRepository>()
    static let pinService = Key<any PinService>()
    static let settings = Key<Settings>()
    static let player = Key<Player>()
    static let channelsUpdater = Key<any ChannelsUpdater>()
}

// Internal services
extension DI {
    
    static let network = Key<NetworkProvider>()
    static let networkAPI = Key<NetworkAPI>()
    static let database = Key<Database>()
    
    static let favorites = Key<StorageGroup>()
    static let kidsSpace = Key<StorageGroup>()
    static let history = Key<any HistoryStorage>()
    static let watchLater = Key<any VideoStorage>()
    static let playlists = Key<any PlaylistsRepostory>()
    static let channels = Key<any ChannelsRepository>()
    static let videos = Key<any VideosRepository>()
    static let comments = Key<any CommentsRepository>()
}

public extension URLRequest {
    
    mutating func authotize() {
        if let key = String.authKey {
            addValue("Basic \(key)", forHTTPHeaderField: "Authorization")
        }
    }
}

public extension DI.Container {
    
    static func setup() {
        register(DI.pinService, PinServiceImp())
        register(DI.settings, .init())
        register(DI.database, Database(storeDescriptions: [.dataStore(.local(name: "Cache")),
                                                           .dataStore(.cloud(name: "Cloud", identifier: .iCloudIdentifier))],
                                     modelBundle: Bundle(for: Video.self)))
        register(DI.network, NetworkProvider(baseURL: URL(string: .baseURL)!,
                                             willSend: { $0.authotize() },
                                           validateBody: { _, _, body in
            if let body = body, let error = body["error"] {
                throw RunError.custom(error as? String ?? "Some service issue")
            }
        }, logging: false))
        
        register(DI.history, CloudStorage<HistoryVideo>(limit: 1000))
        register(DI.networkAPI, .init())
        
        register(DI.favorites, .init(videos: CloudStorage<FavoriteVideo>(),
                                     channels: CloudStorage<FavoriteChannel>(),
                                     playlists: CloudStorage<FavoritePlaylist>()))
        
        register(DI.kidsSpace, .init(videos: CloudStorage<KidsSpaceVideo>(),
                                     channels: CloudStorage<KidsSpaceChannel>(),
                                     playlists: CloudStorage<KidsSpacePlaylist>()))
        
        register(DI.watchLater, CloudStorage<WatchLaterVideo>())
        
        if String.baseURL == "https://url.to.your.backend" {
            print("""
            \nSpecify URL to Invidious instance in IvoryCore/DIContainer.swift alongside with authKey for accessing to your server.\n
            Also you need to make an iCloud identifier for Cloud Kit container for syncronization of History and Favorites between user devices.\n\n
            Currently the app is running with mocked data
            """)
            register(DI.playlists, PlaylistsRepostoryMock())
            register(DI.channels, ChannelsRepositoryMock())
            register(DI.videos, VideosRepositoryMock())
            register(DI.comments, CommentsRepositoryMock())
        } else {
            register(DI.playlists, PlaylistsRepostoryImp())
            register(DI.channels, ChannelsRepositoryImp())
            register(DI.videos, VideosRepositoryImp())
            register(DI.comments, CommentsRepositoryImp())
        }
        
        register(DI.data, .init())
        register(DI.player, .init())
        register(DI.channelsUpdater, ChannelsUpdaterImp())
    }
}
