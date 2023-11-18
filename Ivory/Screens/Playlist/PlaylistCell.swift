//
//  PlaylistCell.swift
//  Ivory
//
//  Created by Ilya Kuznetsov on 16/01/2023.
//

import SwiftUI
import Kingfisher
import SwiftUIComponents
import IvoryCore
import CommonUtils
import DependencyContainer
import GridView
import Coordinators

extension CollectionSnapshot {
    
    func addSection(_ playlists: [Playlist]) {
        addSection(playlists,
                   fill: { PlaylistCell(playlist: $0) },
                   itemSize: { _, width in PlaylistCell.size(width: width) })
    }
}

struct PlaylistCell: View {
    
    static func size(width: CGFloat) -> CGSize {
        let big = width > 1000
        let itemWidth = CGFloat.cellWidth(maxCellWidth: big ? 700 : 500, containerWidth: width)
        return CGSize(width: itemWidth, height: big ? 80 : 52)
    }
    
    @EnvironmentObject private var navigation: Navigation<CommonCoordinator>
    
    let playlist: Playlist
    
    var body: some View {
        Button {
            navigation().present(.playlistDetails(playlist))
        } label: {
            HStack(spacing: 15) {
                KFImage(playlist.thumbnailURL)
                    .prepared()
                    .background { Color(white: 0.5, opacity: 0.2) }
                    .aspectRatio(16.0 / 9.0, contentMode: .fit)
                    .bordered(6)
                    .layoutPriority(1)
                VStack(spacing: 4) {
                    Text(playlist.title ?? "").styled()
                        .foregroundStyle(Color.label)
                    Text("\(playlist.count) video\(playlist.count == 1 ? "" : "s")")
                        .styled(size: .small)
                        .foregroundStyle(Color.secondaryText)
                }
            }
        }.contentShape(.contextMenuPreview, RoundedRectangle(cornerRadius: 6, style: .continuous))
            .contextMenu { PlaylistMenu(playlist: playlist) }
    }
}

struct PlaylistMenu: View {
    
    @DI.Observed(DI.settings) private var settings
    @DI.Observed(DI.pinService) private var pinService
    @DI.Static(DI.data) private var data
    
    @ObservedObject var playlist: Playlist
    
    var body: some View {
        if !pinService.pinSet {
            ShareLink("Share URL", item: playlist.shareURL)
            
            StorageButton(storage: data.favorites.playlists, type: .favorites, item: playlist)
            
            if !settings.hideKidsSpace {
                StorageButton(storage: data.kidsSpace.playlists, type: .kidsSpace, item: playlist)
            }
        }
    }
}

#Preview {
    let size = PlaylistCell.size(width: 400)
    
    return previewWithData {
        Playlist.example(ctx: $0.previewContext)
    } view: {
        PlaylistCell(playlist: $0).frame(height: size.height).padding(20)
    }
}
