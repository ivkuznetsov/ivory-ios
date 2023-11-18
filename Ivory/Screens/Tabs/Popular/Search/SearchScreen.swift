//
//  SearchView.swift
//  Ivory
//
//  Created by Ilya Kuznetsov on 17/01/2023.
//

import SwiftUI
import CommonUtils
import SwiftUIComponents
import IvoryCore
import DependencyContainer
import GridView
import Loader
import LoaderUI
import Coordinators

struct SearchScreen: View {
    
    @EnvironmentObject private var navigation: Navigation<CommonCoordinator>
    
    @MainActor private final class State: ObservableObject {
        
        @DI.Static(DI.data) private var data
        
        enum Scope: String, CaseIterable, TabsItem {
            case videos
            case channels
            case playlists
            
            var title: String { rawValue.capitalized }
        }
        
        @RePublished private var pagingVideo: Paging<Video>.CommonManager
        @RePublished private var pagingChannel: Paging<Channel>.CommonManager
        @RePublished private var pagingPlaylist: Paging<Playlist>.CommonManager
        
        @Published var searchText = ""
        @RePublished var scope = TabsState(items: Scope.allCases)
        @Published var order = SearchOrder.relevance
        
        let loader = Loader()
        
        var paging: any ObservablePagingLoader {
            switch scope.selected {
            case .videos: return pagingVideo
            case .channels: return pagingChannel
            case .playlists: return pagingPlaylist
            }
        }
        
        init() {
            pagingVideo = .init(initialLoading: .none(), loader: loader)
            pagingChannel = .init(initialLoading: .none(), loader: loader)
            pagingPlaylist = .init(initialLoading: .none(), loader: loader)
            
            pagingVideo.dataSource.loadPage = { [weak self] in
                if let wSelf = self {
                    return try await wSelf.data.videos.search(term: wSelf.searchText, order: wSelf.order, offset: $0)
                }
                throw CancellationError()
            }
            
            pagingChannel.dataSource.loadPage = { [weak self] in
                if let wSelf = self {
                    return try await wSelf.data.channels.search(term: wSelf.searchText, order: wSelf.order, offset: $0)
                }
                throw CancellationError()
            }
            
            pagingPlaylist.dataSource.loadPage = { [weak self] in
                if let wSelf = self {
                    return try await wSelf.data.playlists.search(term: wSelf.searchText, order: wSelf.order, offset: $0)
                }
                throw CancellationError()
            }
            
            $searchText.sinkOnMain(retained: self) { [weak self] _ in
                self?.reset()
                self?.performSearch()
            }
            
            $order.sinkOnMain(retained: self) { [weak self] _ in
                self?.reset()
                self?.performSearch()
            }

            scope.$selected.sinkOnMain(retained: self) { [weak self] _ in
                self?.performSearch()
            }
        }
        
        private func reset() {
            pagingVideo.reset()
            pagingChannel.reset()
            pagingPlaylist.reset()
        }
        
        private func performSearch() {
            if paging.dataSource.anyContent.items.isEmpty, searchText.count > 1 {
                paging.refresh()
            }
        }
    }
    
    @StateObject private var state = State()
    
    private func cancelSearch() {
        shortAnimation { navigation().dismiss() }
    }
    
    private var tabs: some View {
        HStack(spacing: 10) {
            TabsView(state: state.scope).frame(maxWidth: 340)
            
            MenuPicker(selection: $state.order, items: SearchOrder.allCases) { _ in
                Image(systemName: "arrow.up.arrow.down")
            }
        }.padding(.vertical, 10)
    }
    
    var body: some View {
        LoadingContainer(state.loader) {
            VStack(spacing: 0) {
                ZStack {
                    OrientationContainer {
                        if $0.orientation == .landscape {
                            HStack(spacing: 30) {
                                tabs
                                SearchBar(searchText: $state.searchText, cancel: { cancelSearch() })
                            }
                        } else {
                            VStack(spacing: 0) {
                                SearchBar(searchText: $state.searchText, cancel: { cancelSearch() })
                                tabs.padding(.top, -5)
                            }
                        }
                    }
                }.frame(maxWidth: .infinity).background(.thinMaterial)
                Divider()
                PagingContainer(any: state.paging) { parameters in
                    GridView(reuseId: "\(parameters.content.items.hashValue)", setup: { $0.setupInsets() }) {
                        let items = parameters.content.items
                        
                        if let items = items as? [Video] {
                            $0.addSection(items)
                        } else if let items = items as? [Channel] {
                            $0.addSection(items)
                        } else if let items = items as? [Playlist] {
                            $0.addSection(items)
                        }
                        $0.addLoading(parameters.loading)
                    }.collectionSafeArea()
                }
            }
        }.toolbar(.hidden, for: .navigationBar)
    }
}

#Preview {
    previewWithData {
        $0.$videos.replace(VideosRepositoryMock())
        $0.$channels.replace(ChannelsRepositoryMock())
        $0.$playlists.replace(PlaylistsRepostoryMock())
    } view: { _ in
        NavigationStack { SearchScreen() }
    }
}
