//
//  FavoritePlaylistsView.swift
//  Ivory
//
//  Created by Ilya Kuznetsov on 18/01/2023.
//

import SwiftUI
import IvoryCore
import SwiftUIComponents
import CommonUtils
import DependencyContainer
import GridView
import Coordinators

struct WatchLaterCell: View {
    
    @EnvironmentObject private var coordinator: Navigation<CommonCoordinator>
    @DI.Observed(DI.data, \.watchLater) private var watchLater
    
    var body: some View {
        Button {
            coordinator().present(.watchLater)
        } label: {
            HStack(spacing: 15) {
                GeometryReader { geometry in
                    ZStack {
                        Image(systemName: "play.rectangle")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(maxHeight: geometry.size.height / 2)
                            .foregroundColor(Color(.tertiaryLabel))
                    }.frame(maxWidth: .infinity, maxHeight: .infinity)
                }.aspectRatio(16 / 9, contentMode: .fit)
                    .background { Color(white: 0.5, opacity: 0.2) }
                    .bordered(6)
                    .layoutPriority(1)

                VStack(spacing: 4) {
                    Text("Watch Later Playlist")
                        .styled()
                        .foregroundStyle(Color.label)
                    
                    Text("\(watchLater.items.count) video\(watchLater.items.count == 1 ? "" : "s")")
                        .styled(size: .small)
                        .foregroundStyle(Color.secondaryText)
                }
            }.padding(.bottom, .spacing).id(UUID())
        }
    }
}

struct FavoritePlaylistsView: View {
    
    @DI.Observed(DI.data, \.favorites.playlists) private var container
    @DI.Observed(DI.data, \.watchLater) private var watchLater
    
    var body: some View {
        GridView(reuseId: "\(container.items.hashValue)",
                 setup: { $0.setupInsets() }, emptyState: .init({ EmptyStateView(favoriteType: "Playlists", details: "playlist") })) {
            if watchLater.items.count > 0 {
                $0.add(WatchLaterCell(), staticSize: { 
                    CGSize(width: $0, height: PlaylistCell.size(width: $0).height + .spacing)
                })
            }
            $0.addSection(container.items)
        }.collectionSafeArea()
    }
}

#Preview {
    previewWithData { data in
        data.$watchLater.replace(MockStorage<Video>.make(ctx: data.previewContext))
        data.$favorites.replace(StorageGroup.makeMocked(ctx: data.previewContext))
    } view: {
        NavigationStack { FavoritePlaylistsView() }
    }
}
