//
//  VideoMenu.swift
//  Ivory
//
//  Created by Ilya Kuznetsov on 16/01/2023.
//

import SwiftUI
import IvoryCore
import DependencyContainer
import Loader
import Coordinators

struct VideoMenu: View {
    
    @EnvironmentObject private var navigation: Navigation<CommonCoordinator>
    @EnvironmentObject private var loader: Loader
    
    @DI.Observed(DI.settings) private var settings
    @DI.Observed(DI.player) private var player
    @DI.Observed(DI.pinService) private var pinService
    @DI.Observed(DI.data, \.history) private var history
    @DI.Static(DI.data) private var data
    
    @ObservedObject var video: Video
    
    private func makeGif() {
        loader.run(.modal()) { [player, navigation] _ in
            let url = try await player.createGif()
            
            DispatchQueue.main.async {
                navigation().present(.gifPreview(url))
            }
        }
    }
    
    var body: some View {
        if !pinService.pinSet {
            StorageButton(storage: data.watchLater, type: .watchLater, item: video)
            
            if player.video == video {
                Button {
                    makeGif()
                } label: { Label("Make GIF Clip", systemImage: "play.circle") }
                
                Menu {
                    ShareLink("Share URL", item: video.shareURL())
                    ShareLink("Share With Timestamp", item: video.shareURL(timestamp: player.currentTime))
                } label: {
                    Label("Share URL", systemImage: "square.and.arrow.up")
                }
            } else {
                ShareLink("Share URL", item: video.shareURL())
            }
            
            StorageButton(storage: data.favorites.videos, type: .favorites, item: video)
            
            if !settings.hideKidsSpace {
                StorageButton(storage: data.kidsSpace.videos, type: .kidsSpace, item: video)
            }
            
            if history.has(video) {
                StorageButton(storage: history, type: .history, item: video)
            }
        }
    }
}
