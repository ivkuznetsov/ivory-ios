//
//  TabsCoordinator.swift
//  Ivory
//
//  Created by Ilya Kuznetsov on 13/11/2023.
//

import Foundation
import SwiftUI
import Coordinators
import IvoryCore
import DependencyContainer

final class TabsCoordinator: CustomCoordinator {
    
    @DI.Static(DI.pinService) private var pinService
    @DI.Static(DI.settings) private var appSettings
    
    @Published var tab: Int
    @Published var tabs = Set<Int>()
    
    let popular = CommonCoordinator()
    let favorites = CommonCoordinator()
    let kidsSpace = CommonCoordinator()
    let history = CommonCoordinator()
    let settings = CommonCoordinator()
    
    var children: [any NavigationModalCoordinator] { [popular, favorites, kidsSpace, history, settings] }
    
    init() {
        tab = popular.hashValue
        
        pinService.sinkOnMain(retained: self) { [weak self] in
            self?.reloadTabs()
        }
        appSettings.sinkOnMain(retained: self) { [weak self] in
            self?.reloadTabs()
        }
        reloadTabs()
    }
    
    func destination() -> some View {
        TabsContainerScreen(coordinator: self)
    }
    
    private func reloadTabs() {
        var tabs = Set<Int>()
        
        if !pinService.pinSet {
            tabs.insert(popular.hashValue)
            tabs.insert(favorites.hashValue)
            tabs.insert(history.hashValue)
            tabs.insert(settings.hashValue)
        }
        if pinService.pinSet || !appSettings.hideKidsSpace {
            tabs.insert(kidsSpace.hashValue)
        }
        self.tabs = tabs
    }
    
    func present(video: Video) {
        present(CommonCoordinator.Screen.videoDetails(.init(.video(video))))
    }
    
    private func present(_ screen: CommonCoordinator.Screen) {
        if pinService.pinSet { return }
        
        for coordinator in children {
            if case .videoDetails(let video) = screen,
               coordinator.popTo(where: {
                   if let currentScreen = $0 as? CommonCoordinator.Screen,
                      case .videoDetails(let currentVideo) = currentScreen,
                      currentVideo.content.video == video.content.video {
                       return true
                   }
                   return false
               }) == true {
                
                self.tab = coordinator.hashValue
                return
            } else {
                if coordinator.popTo(where: { $0.hashValue == screen.hashValue }) {
                    self.tab = coordinator.hashValue
                    return
                }
            }
        }

        tab = popular.hashValue
        popular.popToRoot()
        popular.present(screen)
    }
    
    func open(url: URL) {
        Task { @MainActor in
            if let item = await URLProcessor().open(url: url) {
                if let video = item as? Video {
                    present(.videoDetails(.init(.video(video))))
                } else if let playlist = item as? Playlist {
                    present(.playlistDetails(playlist))
                } else if let channel = item as? Channel {
                    present(.channelDetails(channel))
                }
            }
        }
    }
}
