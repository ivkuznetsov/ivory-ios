//
//  PopularScreen.swift
//  Ivory
//
//  Created by Ilya Kuznetsov on 20/12/2022.
//

import SwiftUI
import CommonUtils
import IvoryCore
import DependencyContainer
import GridView
import Loader
import LoaderUI
import Coordinators

struct PopularScreen: View {
    
    @EnvironmentObject private var navigation: Navigation<CommonCoordinator>
    
    @MainActor private final class State: ObservableObject {
        
        @DI.Static(DI.data, \.videos) private var videos
        
        @RePublished var paging = Paging<Video>.CommonManager()
        @Published var category = VideoCategory.defaultType
        
        init() {
            paging.dataSource.loadPage = { [weak self] _ in
                if let wSelf = self {
                    return Page(items: try await wSelf.videos.popular(wSelf.category))
                }
                throw CancellationError()
            }
            
            $category.sinkOnMain(retained: self) { [paging] _ in
                paging.reset()
                paging.initalRefresh()
            }.retained(by: self)
            
            paging.initalRefresh()
        }
    }
    
    @StateObject private var state = State()
    
    private func toggleSearch() {
        shortAnimation { navigation().present(.searchFlow()) }
    }
    
    var body: some View {
        LoadingContainer(state.paging.loader) {
            PagingContainer(state.paging) { parameters in
                GridView(reuseId: "\(parameters.content.items.hashValue)", setup: { $0.setupInsets() }) {
                    $0.addSection(parameters.content.items)
                    $0.addLoading(parameters.loading)
                }.collectionSafeArea()
            }
        }.navigationTitle(state.category.title)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    MenuPicker(selection: $state.category, items: VideoCategory.allCases) { _ in
                        Image(systemName: "list.bullet")
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) { ImportLinkView() }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button { toggleSearch() } label: { Image(systemName: "magnifyingglass") }
                }
            }
    }
}

#Preview {
    previewWithData {
        $0.$videos.replace(VideosRepositoryMock())
    } view: { _ in
        NavigationStack { PopularScreen() }
    }
}
