//
//  PlaylistDetailsScreen.swift
//  Ivory
//
//  Created by Ilya Kuznetsov on 16/01/2023.
//

import SwiftUI
import CommonUtils
import IvoryCore
import DependencyContainer
import GridView
import Loader
import LoaderUI

struct PlaylistDetailsScreen: View {
    
    @MainActor private final class State: ObservableObject {
        
        @DI.RePublished(DI.pinService) var pinService
        @DI.Static(DI.data, \.playlists) var playlists
        
        @RePublished var paging = Paging<Video>.CommonManager()
        
        let playlist: Playlist
        
        init(playlist: Playlist) {
            self.playlist = playlist
            paging.dataSource.loadPage = { [playlists] in
                try await playlists.videos(playlist, offset: $0)
            }
            paging.initalRefresh()
        }
    }
    
    @StateObject private var state: State
    
    init(playlist: Playlist) {
        _state = .init(wrappedValue: .init(playlist: playlist))
    }
    
    var body: some View {
        LoadingContainer(state.paging.loader) {
            PagingContainer(state.paging) { parameters in
                GridView(reuseId: "\(parameters.content.items.hashValue)", setup: { $0.setupInsets() }) {
                    $0.addSection(parameters.content.items, action: .showsDetails(wrap: { .playlist($0, state.paging) }))
                    $0.addLoading(parameters.loading)
                }.collectionSafeArea()
            }
        }.navigationTitle(state.playlist.title ?? "")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem() {
                    if !state.pinService.pinSet {
                        Menu {
                            PlaylistMenu(playlist: state.playlist)
                        } label: { Image(systemName: "ellipsis") }
                    }
                }
            }
    }
}

#Preview {
    previewWithData {
        $0.$playlists.replace(PlaylistsRepostoryMock())
        return await $0.makeExample { Playlist.example(ctx: $0) }
    } view: { playlist in
        NavigationStack { PlaylistDetailsScreen(playlist: playlist) }
    }
}
