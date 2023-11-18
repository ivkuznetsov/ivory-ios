//
//  ChannelCell.swift
//  Ivory
//
//  Created by Ilya Kuznetsov on 15/01/2023.
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
    
    func addSection(_ channels: [Channel]) {
        addSection(channels,
                   fill: { ChannelCell(channel: $0) },
                   itemSize: { _, width in ChannelCell.size(width: width) })
    }
}

struct ChannelCell: View {
    
    static func size(width: CGFloat = UIScreen.main.bounds.size.width) -> CGSize {
        let big = width > 1000
        let itemWidth = CGFloat.cellWidth(maxCellWidth: big ? 700 : 500, containerWidth: width)
        return CGSize(width: itemWidth, height: big ? 70 : 50)
    }
    
    @EnvironmentObject private var navigation: Navigation<CommonCoordinator>
    
    let channel: Channel
    
    var body: some View {
        Button {
            navigation().present(.channelDetails(channel))
        } label: {
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
                Text(channel.title ?? "").styled().ignoresSafeArea()
                Spacer()
            }.padding(.horizontal, 5)
                .padding(.vertical, 5)
                .foregroundStyle(Color.label)
        }.contentShape(.contextMenuPreview, RoundedRectangle(cornerRadius: 15, style: .continuous))
            .contextMenu { ChannelMenu(channel: channel) }
    }
}

struct ChannelMenu: View {
    
    @DI.Observed(DI.settings) private var settings
    @DI.Observed(DI.pinService) private var pinService
    @DI.Static(DI.data) private var data
    
    @ObservedObject var channel: Channel
    
    var body: some View {
        if !pinService.pinSet {
            ShareLink("Share URL", item: channel.shareURL)
            
            StorageButton(storage: data.favorites.channels, type: .favorites, item: channel)
            
            if !settings.hideKidsSpace {
                StorageButton(storage: data.kidsSpace.channels, type: .kidsSpace, item: channel)
            }
        }
    }
}

#Preview {
    let size = ChannelCell.size()
    
    return previewWithData {
        Channel.example(ctx: $0.previewContext)
    } view: {
        ChannelCell(channel: $0).frame(height: size.height).padding(15)
    }
}
