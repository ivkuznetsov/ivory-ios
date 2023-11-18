//
//  TabsContainerScreen.swift
//  Ivory
//
//  Created by Ilya Kuznetsov on 13/11/2023.
//

import Foundation
import SwiftUI
import Coordinators
import IvoryCore

struct TabsContainerScreen: View {
    
    @Environment(\.openURL) private var openURL
    @ObservedObject var coordinator: TabsCoordinator
    
    @ViewBuilder
    func tab<V: View, C: Coordinator>(_ root: V, title: String, icon: Image, child: C) -> some View {
        if coordinator.tabs.contains(child.hashValue) {
            root.tabItem {
                Label(title: { Text(title) }, icon: { icon })
            }.tag(child.hashValue)
        }
    }
    
    var body: some View {
        TabView(selection: Binding(get: {
            coordinator.tab
        }, set: { value in
            if coordinator.tab == value {
                coordinator.children.first { $0.hashValue == value }?.popToRoot()
            } else {
                coordinator.tab = value
            }
        })) {
            tab(coordinator.popular.view(for: .popular), title: "Explore", icon: Image(systemName: "square.grid.2x2.fill"), child: coordinator.popular)
                
            tab(coordinator.favorites.view(for: .favorites), title: "Favorites", icon: Image(systemName: "star.fill"), child: coordinator.favorites)
                
            tab(coordinator.kidsSpace.view(for: .kidsSpace), title: "Kids Space", icon: Image("KidsSpace"), child: coordinator.kidsSpace)
                
            tab(coordinator.history.view(for: .history), title: "History", icon: Image(systemName: "clock.fill"), child: coordinator.history)
            
            tab(coordinator.settings.view(for: .settings), title: "Settings", icon: Image(systemName: "gearshape.fill"), child: coordinator.settings)
                
        }.id(coordinator.tabs.hashValue)
            .environment(\.openURL, OpenURLAction {
                coordinator.open(url: $0)
                return .handled
            })
            .onOpenURL { coordinator.open(url: $0) }
            .environmentObject(coordinator)
            .onAppear {
                let tabBarAppearance = UITabBarAppearance()
                tabBarAppearance.configureWithDefaultBackground()
                UITabBar.appearance().scrollEdgeAppearance = tabBarAppearance
            }
    }
}

#Preview {
    previewWithData {
        $0.$videos.replace(VideosRepositoryMock())
        $0.$channels.replace(ChannelsRepositoryMock())
        $0.$playlists.replace(PlaylistsRepostoryMock())
        $0.$comments.replace(CommentsRepositoryMock())
    } view: { _ in
        TabsContainerScreen(coordinator: .init())
    }
}
