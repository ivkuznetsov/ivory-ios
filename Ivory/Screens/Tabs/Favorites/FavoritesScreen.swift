//
//  FavoritesScreen.swift
//  Ivory
//
//  Created by Ilya Kuznetsov on 20/12/2022.
//

import SwiftUI
import SwiftUIComponents
import IvoryCore
import DependencyContainer

extension EmptyStateView {
    
    init(favoriteType: String, details: String) {
        let text = "Add a \(details) to favorites using\nmenu button"
        self.init(title: "No Favorite \(favoriteType)", details: text)
    }
}

struct FavoritesScreen: View {
    
    var body: some View {
        ContentTabsView(items: [.init(title: "Channels", view: { FavoriteChannelsView() }),
                                .init(title: "Videos", view: { FavoriteVideosView() }),
                                .init(title: "Playlists", view: { FavoritePlaylistsView() })])
    }
}

#Preview {
    previewWithData { data in
        let updater = ChannelsUpdaterMock()
        let favorites = StorageGroup.makeMocked(ctx: data.previewContext)
        
        favorites.channels.items.forEach {
            updater.loadedVideos[$0] = Video.exampleArray(ctx: data.previewContext)
        }
        
        DI.Container.register(DI.channelsUpdater, updater)
        data.$favorites.replace(favorites)
    } view: {
        NavigationStack { FavoritesScreen() }
    }
}
