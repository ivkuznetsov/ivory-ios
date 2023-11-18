//
//  FavoriteChannelsView.swift
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
import Loader

extension CollectionSnapshot {
    
    func addSection(_ channel: Channel, didAppear: @escaping ()->()) {
        addSection([channel],
                   fill: { ChannelCell(channel: $0).onAppear(perform: didAppear) },
                   layout: { .grid(height: ChannelCell.size(width: $0.container.contentSize.width).height, $0, spacing: .init(top: .spacing, leading: .spacing - 5, bottom: .spacing, trailing: .spacing - 5)) })
    }
    
    func addHorizontalSection(_ videos: [Video]) {
        addSection(videos,
                   fill: { VideoCell(video: $0,
                                     showChannel: false,
                                     action: .showsDetails(wrap: { .video($0) }))},
                   layout: { env in
            var width: CGFloat = 180
            
            #if targetEnvironment(macCatalyst)
            width = 250
            #else
            if env.traitCollection.horizontalSizeClass == .regular &&
                env.traitCollection.verticalSizeClass == .regular {
                width = 240
            }
            #endif
            
            return .horizontalGrid(size: VideoCell.size(width: width, style: .card, subtitleLines: 0), spacing: .spacing)
        })
    }
}

struct FavoriteChannelsView: View {
    
    @DI.Observed(DI.channelsUpdater) private var updates
    @DI.Observed(DI.data, \.favorites.channels) private var container
    
    var body: some View {
        GridView(reuseId: "\(container.items.hashValue)", setup: {
            $0.view.contentInsetAdjustmentBehavior = .automatic
            $0.view.contentInset = .init(top: 0, left: 0, bottom: .spacing, right: 0)
        }, emptyState: .init({ EmptyStateView(favoriteType: "Channels", details: "channel") })) { snapshot in
            
            container.items.reversed().forEach { channel in
                snapshot.addSection(channel) {
                    updates.updateRecentVideosIfNeeded(channel)
                }
                snapshot.addHorizontalSection(updates.currentRecentVideos(channel))
            }
        }.collectionSafeArea()
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
        NavigationStack { FavoriteChannelsView() }
    }
}
