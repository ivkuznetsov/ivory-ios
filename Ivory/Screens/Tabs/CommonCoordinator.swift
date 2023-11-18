//
//  AppCoordinators.swift
//  Ivory
//
//  Created by Ilya Kuznetsov on 31/03/2023.
//

import Foundation
import SwiftUI
import IvoryCore
import CommonUtils
import SwiftUIComponents
import Coordinators
import DependencyContainer

final class CommonCoordinator: NavigationModalCoordinator {
    
    enum Screen: ScreenProtocol {
        case popular
        case favorites
        case kidsSpace
        case history
        case videoDetails(VideoDetails)
        case channelDetails(Channel)
        case playlistDetails(Playlist)
        case watchLater
        case search
        case settings
    }
    
    func destination(for screen: Screen) -> some View {
        switch screen {
        case .popular: PopularScreen()
        case .favorites: FavoritesScreen()
        case .kidsSpace: KidsSpaceScreen()
        case .history: HistoryScreen()
        case .videoDetails(let details): VideoDetailsScreen(details: details)
        case .channelDetails(let channel): ChannelDetailsScreen(channel: channel)
        case .playlistDetails(let playlist): PlaylistDetailsScreen(playlist: playlist)
        case .watchLater: WatchLaterView()
        case .search: SearchScreen()
        case .settings: SettingsScreen()
        }
    }
    
    enum ModalFlow: ModalProtocol {
        case createPin
        case inputPin
        case searchFlow(CommonCoordinator = .init())
        case gifPreview(URL)
        
        var style: ModalStyle {
            switch self {
            case .searchFlow(_): return .overlay
            default: return .sheet
            }
        }
    }
    
    func destination(for flow: ModalFlow) -> some View {
        switch flow {
        case .createPin: CreatePinScreen()
        case .inputPin: RemovePinScreen()
        case .searchFlow(let coordinator): coordinator.view(for: .search)
        case .gifPreview(let url): GifImageView(url: url).ignoresSafeArea()
        }
    }
}
