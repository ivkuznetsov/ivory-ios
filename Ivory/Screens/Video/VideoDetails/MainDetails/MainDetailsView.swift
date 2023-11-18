//
//  MainDetailsView.swift
//  Ivory
//
//  Created by Ilya Kuznetsov on 22/01/2023.
//

import SwiftUI
import CommonUtils
import SwiftUIComponents
import Combine
import IvoryCore
import DependencyContainer
import GridView
import Loader
import LoaderUI

struct MainDetailsView: View {
    
    @MainActor final class State: ObservableObject {
        @DI.RePublished(DI.data, \.watchLater) var watchLater
        @DI.RePublished(DI.pinService) var pinService
        @DI.Static(DI.settings) var settings
        @DI.Static(DI.player) var player
        @DI.Static(DI.data) var data
        
        @RePublished var commentsPaging: Paging<Comment>.CommonManager
        @RePublished var commentsLoader: CommentsLoader
        
        @Published var next: VideoDetails.Content?
        @Published var streams: [VideoStream] = []
        @RePublished var tabs = MainVideoTabs.State()
        
        @RePublished var detailsPaging: Paging<Video>.CommonManager
        @RePublished var details: VideoDetails
        
        init(detailsPaging: Paging<Video>.CommonManager, details: VideoDetails) {
            self.detailsPaging = detailsPaging
            self.details = details
            let paging = Paging<Comment>.CommonManager(initialLoading: .none())
            commentsPaging = paging
            commentsLoader = .init(loader: paging.loader)
            
            tabs.state.$selected.sinkOnMain(retained: self) { [weak self] in
                if $0 == .comments {
                    self?.commentsPaging.initalRefresh()
                }
            }
            
            details.$content.sinkOnMain(retained: self) { [weak self] _ in
                withAnimation {
                    self?.reloadContent()
                }
            }
            
            detailsPaging.dataSource.$content.sinkMain(retained: self) { [weak self] _ in
                self?.reloadNextContent()
            }
            
            player.didFinish.sinkMain(retained: self) { [weak self] in
                self?.playerDidFinish()
            }
            
            $streams.sinkOnMain(retained: self) { [weak self] _ in
                self?.reloadPlayer()
            }
            DispatchQueue.main.async {
                self.reloadContent()
            }
        }
        
        private func playerDidFinish() {
            if case .watchLater(let video) = details.content, settings.deleteFromWatchLater {
                watchLater.remove(video)
            }
            if let next = next, settings.autoPlayNextVideo {
                details.content = next
            }
        }
        
        var video: Video {  details.content.video }
        
        private func reloadContent() {
            tabs.state.selected = .description
            streams = []
            next = nil
            detailsPaging.reset()
            commentsPaging.reset()
            let video = details.content.video
            commentsLoader.video = video
            
            detailsPaging.dataSource.loadPage = { [weak self, data] _ in
                let details = try await data.videos.details(video)
                self?.streams = details.streams
                return Page(items: details.related)
            }
            
            commentsPaging.dataSource.loadPage = { [data] in
                try await data.comments.comments(video, offset: $0)
            }
            
            reloadPlayer()
            detailsPaging.initalRefresh()
        }
        
        func reloadPlayer() {
            player.set(video: video, streams: streams)
        }
        
        private func reloadNextContent() {
            switch details.content {
            case .video(_):
                if let video = detailsPaging.dataSource.content.items.first {
                    next = .init(.video(video))
                }
            case .playlist(let video, let paging):
                if let index = paging.dataSource.content.items.firstIndex(of: video) {
                    if let video = paging.dataSource.content.items[safe: index + 1] {
                        next = .init(.playlist(video, paging))
                    } else {
                        paging.loadMore()
                    }
                }
            case .watchLater(let video):
                if let video = watchLater.nextAfter(video) {
                    next = .watchLater(video)
                }
            }
        }
        
        func didChangeWatchLaterCount() {
            if case .watchLater(_) = details.content, next == nil || !watchLater.has(next!.video) {
                next = nil
                reloadNextContent()
            }
        }
        
        var paging: any ObservablePagingLoader {
            tabs.state.selected == .comments ? commentsPaging : detailsPaging
        }
    }
    
    @ObservedObject var state: State
    
    var body: some View {
        PagingContainer(any: state.paging) { parameters in
            GridView(reuseId: "\(parameters.content.items.hashValue)", setup: { $0.setupInsets(top: 0) }) {
                
                $0.add(PlayerView(didAppear: { state.reloadPlayer() }).padding(.horizontal, -.spacing).padding(.bottom, .spacing),
                       staticSize: { CGSize(width: $0, height: PlayerView.cellHeight(width: $0 + .spacing * 2) + .spacing) })
                
                if !state.pinService.pinSet {
                    $0.add(MainVideoTabs(state: state.tabs).padding(.bottom, .spacing), staticSize: { CGSize(width: $0, height: 32 + .spacing) })
                }
                
                if let next = state.next {
                    let nextView = NextVideoView(content: next, didSelect: {
                        state.details.content = $0
                    }).id(next.hashValue)
                    $0.add(nextView, staticSize: { CGSize(width: $0, height: 60) })
                }
                
                switch state.tabs.state.selected {
                case .description:
                    if state.video.videoDescription != nil {
                        let descriptionView = VideoDescriptionView(video: state.video).id(state.video)
                        
                        $0.add(descriptionView, staticSize: {
                            VideoDescriptionView.size(video: state.video, width: $0)
                        })
                    }
                case .comments:
                    $0.addSection(parameters.content.items as! [Comment], commentsLoader: state.commentsLoader)
                case .related:
                    $0.addSection(parameters.content.items as! [Video], action: .custom({
                        state.details.content = .video($0)
                    }))
                }
                $0.addLoading(parameters.loading)
            }
        }.ignoresSafeArea(edges: [.leading, .trailing, .bottom])
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    QualityPicker(video: state.video)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    if !state.pinService.pinSet {
                        Menu {
                            VideoMenu(video: state.video)
                        } label: { Image(systemName: "ellipsis") }
                    }
                }
            }
            .onChange(of: state.watchLater.items.count) { _ in state.didChangeWatchLaterCount() }
            .onAppear { state.reloadPlayer() }
    }
}

fileprivate struct QualityPicker: View {
    
    @DI.Observed(DI.player) private var player
    
    let video: Video
    
    var body: some View {
        if player.video == video, let stream = player.stream, player.streams.count > 0 {
            Menu {
                ForEach(player.streams, id: \.self) { stream in
                    Button(action: {
                        player.stream = stream
                    }, label: {
                        Label(stream.label, systemImage: player.stream == stream ? "checkmark" : "")
                    })
                }
            } label: {
                Text(stream.label)
            }
        }
    }
}
