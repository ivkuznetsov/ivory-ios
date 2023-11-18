//
//  ChannelDetailsScreen.swift
//  Ivory
//
//  Created by Ilya Kuznetsov on 15/01/2023.
//

import SwiftUI
import Kingfisher
import CommonUtils
import IvoryCore
import DependencyContainer
import GridView
import Loader
import LoaderUI

struct ChannelDetailsScreen: View {
    
    @MainActor private final class State: ObservableObject {
        
        @DI.RePublished(DI.pinService) var pinService
        @DI.Static(DI.data, \.channels) private var channels
        
        enum Tab: String, TabsItem, CaseIterable {
            case videos
            case playlists
        }
        
        @RePublished var videosPaging: Paging<Video>.CommonManager = .init(initialLoading: .none())
        @RePublished var playlistsPaging: Paging<Playlist>.CommonManager = .init(initialLoading: .none())
        @RePublished var tabs = TabsState<Tab>(items: Tab.allCases)
        
        let channel: Channel
        
        var currentPaging: any ObservablePagingLoader { tabs.selected == .videos ? videosPaging : playlistsPaging }
        
        private func didChangeTab() {
            if tabs.selected == .videos {
                videosPaging.initalRefresh()
            } else {
                playlistsPaging.initalRefresh()
            }
        }
        
        init(channel: Channel) {
            self.channel = channel
            
            channels.updateIfNeeded(channel)
            
            videosPaging.dataSource.loadPage = { [channels] in
                try await channels.videos(channel, offset: $0)
            }
            playlistsPaging.dataSource.loadPage = { [channels] in
                try await channels.playlists(channel, offset: $0)
            }
            
            videosPaging.initalRefresh()
            
            tabs.$selected.sinkOnMain(retained: self) { [weak self] _ in
                self?.didChangeTab()
            }
        }
    }
    
    @StateObject private var state: State
    
    init(channel: Channel) {
        _state = .init(wrappedValue: .init(channel: channel))
    }
    
    var body: some View {
        LoadingContainer(state.currentPaging.loader) {
            PagingContainer(any: state.currentPaging) { parameters in
                GridView(reuseId: "\(parameters.content.items.hashValue)", setup: { $0.setupInsets() }) {
                    
                    $0.add(VStack(spacing: 15) {
                        ChannelTitleView(channel: state.channel)
                        TabsView(state: state.tabs)
                            .frame(maxWidth: 250)
                        Spacer(minLength: 0)
                    }) { CGSize(width: $0, height: ChannelCell.size().height + 15 + 32 + .spacing) }
                    
                    let items = parameters.content.items
                    
                    if let items = items as? [Video] {
                        $0.addSection(items, showChannel: false)
                    } else if let items = items as? [Playlist] {
                        $0.addSection(items)
                    }
                    $0.addLoading(parameters.loading)
                }.collectionSafeArea()
            }
        }.toolbar {
                ToolbarItem() {
                    if !state.pinService.pinSet {
                        Menu {
                            ChannelMenu(channel: state.channel)
                        } label: {
                            Image(systemName: "ellipsis")
                        }
                    }
                }
            }
    }
}

fileprivate struct ChannelTitleView: View {
    
    @ObservedObject var channel: Channel
    
    var body: some View {
        HStack(spacing: 10) {
            ZStack {
                Color(white: 0.5, opacity: 0.2)
                KFImage(channel.thumbnailURL)
                    .prepared()
                    .aspectRatio(contentMode: .fill)
                Circle().stroke(Color.label.opacity(0.2), lineWidth: 1)
            }.aspectRatio(contentMode: .fit)
                .clipShape(Circle())
                .layoutPriority(1)
                
            VStack(spacing: 4) {
                Text(channel.title ?? "")
                    .styled()
                    .foregroundStyle(Color.label)
                Text(channel.abbriviatedSubs)
                    .styled(size: .small)
                    .foregroundStyle(Color.secondaryText)
            }
            Spacer()
        }.frame(maxHeight: ChannelCell.size().height)
    }
}

#Preview {
    previewWithData {
        $0.$channels.replace(ChannelsRepositoryMock())
        return await $0.makeExample { Channel.example(ctx: $0) }
    } view: { channel in
        NavigationStack { ChannelDetailsScreen(channel: channel) }
    }
}
