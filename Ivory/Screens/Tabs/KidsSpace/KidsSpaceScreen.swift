//
//  KidsSpaceView.swift
//  Ivory
//
//  Created by Ilya Kuznetsov on 20/12/2022.
//

import SwiftUI
import SwiftUIComponents
import IvoryCore
import CommonUtils
import DependencyContainer
import GridView
import Coordinators

extension EmptyState {
    
    init(kidsType: String, details: String) {
        self.init( { EmptyStateView(title: "No \(kidsType) in Kids Space",
                                    details: "Add a \(details) to Kids Space using\nmenu button") } )
    }
}

struct KidsVideosView: View {
    
    @DI.Observed(DI.data, \.kidsSpace.videos) private var container
    
    @ViewBuilder var body: some View {
        GridView(reuseId: "\(container.items.hashValue)",
                 setup: { $0.setupInsets() }, emptyState: .init(kidsType: "Videos", details: "video")) {
            $0.addSection(container.items)
        }.collectionSafeArea()
    }
}

struct KidsChannelsView: View {
    
    @DI.Observed(DI.data, \.kidsSpace.channels) private var container
    
    var body: some View {
        GridView(reuseId: "\(container.items.hashValue)",
                 setup: { $0.setupInsets() }, emptyState: .init(kidsType: "Channels", details: "channel")) {
            $0.addSection(container.items)
        }.collectionSafeArea()
    }
}

struct KidsPlaylistsView: View {
    
    @DI.Observed(DI.data, \.kidsSpace.playlists) private var container
    
    var body: some View {
        GridView(reuseId: "\(container.items.hashValue)",
                 setup: { $0.setupInsets() }, emptyState: .init(kidsType: "Playlists", details: "playlist")) {
            $0.addSection(container.items)
        }.collectionSafeArea()
    }
}

struct KidsSpaceScreen: View {
    
    @DI.Observed(DI.pinService) private var pinService
    @EnvironmentObject private var navigation: Navigation<CommonCoordinator>
    
    var body: some View {
        ContentTabsView(items: [.init(title: "Channels", view: { KidsChannelsView() }),
                                .init(title: "Videos", view: { KidsVideosView() }),
                                .init(title: "Playlists", view: { KidsPlaylistsView() }) ])
        .toolbar {
            ToolbarItem {
                Button {
                    togglePin()
                } label: { pinService.pinSet ? Image(systemName: "lock.fill") : Image(systemName: "lock") }
            }
        }
    }
    
    private func togglePin() {
        if pinService.pinSet {
            navigation().present(.inputPin)
        } else {
            navigation().present(.createPin)
        }
    }
}

#Preview {
    previewWithData { data in
        data.$kidsSpace.replace(.makeMocked(ctx: data.previewContext))
    } view: {
        NavigationStack { KidsSpaceScreen() }
    }
}
