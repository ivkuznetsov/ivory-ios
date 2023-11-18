//
//  VideoCell.swift
//  Ivory
//
//  Created by Ilya Kuznetsov on 29/12/2022.
//

import SwiftUI
import Kingfisher
import SwiftUIComponents
import IvoryCore
import CommonUtils
import DependencyContainer
import GridView
import Coordinators
import Loader

extension CollectionSnapshot {
    
    func addSection(_ videos: [Video],
                    style: VideoCell.Style = .card,
                    showChannel: Bool = true,
                    action: VideoCell.Action = .showsDetails(wrap: { .video($0) })) {
        addSection(videos,
                   fill: { VideoCell(video: $0, showChannel: showChannel, style: style, action: action) },
                   itemSize: { _, width in
            VideoCell.size(width: width, style: style)
        })
    }
}

fileprivate struct VideoDurationModifier: ViewModifier {
    
    @DI.Observed(DI.data, \.history) private var history
    
    let video: Video
    
    private var videoProgress: CGFloat {
        if video.durationInterval > 0 {
            let lastPosition = history.position(video: video)
            return max(0, min(video.durationInterval, Double(lastPosition) / video.durationInterval))
        } else {
            return 0
        }
    }
    
    func body(content: Content) -> some View {
        content.overlay {
            if !video.live {
                VStack(spacing: 0) {
                    Spacer()
                    HStack(spacing: 0) {
                        Spacer()
                        if video.durationInterval > 0 {
                            ZStack {
                                Color(white: 0, opacity: 0.7)
                                GeometryReader { proxy in
                                    Rectangle().foregroundColor(.tint).frame(width: proxy.size.width * videoProgress)
                                }
                                Text(video.durationInterval.toTimeString()).styled(alignment: .trailing, size: .tiny)
                                    .foregroundStyle(.white)
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 3)
                                    .layoutPriority(1)
                            }.cornerRadius(6)
                                .padding([.bottom, .trailing], 8)
                        }
                    }
                }
            }
        }
    }
}

fileprivate struct IsCurrentModifier: ViewModifier {
    
    @DI.Observed(DI.player) private var player
    
    let video: Video
    
    private var isCurrent: Bool { player.video == video }
    
    func body(content: Content) -> some View {
        content.bordered(10, color: isCurrent ? .tint : .label.opacity(0.2), width: isCurrent ? 4 : 1)
    }
}

fileprivate struct IsNewModifier: ViewModifier {
    
    @DI.Observed(DI.data, \.history) private var history
    @DI.Observed(DI.data, \.favorites.channels) private var favorites
    
    let video: Video
    
    func body(content: Content) -> some View {
        content.overlay {
            if video.isNew && !history.has(video), let channel = video.channel, favorites.has(channel) {
                VStack {
                    HStack {
                        Spacer()
                        Text("new").styled(alignment: .trailing, size: .tiny)
                            .foregroundStyle(.white)
                            .padding(.horizontal, 8).padding(.vertical, 2)
                            .background(Color(.systemRed))
                            .cornerRadius(6)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 8)
                    }
                    Spacer()
                }
            }
        }
    }
}

struct VideoCell: View {
    
    static func size(width: CGFloat, style: Style, subtitleLines: Int = 2) -> CGSize {
        if style == .card {
            #if targetEnvironment(macCatalyst)
            let size: CGFloat = 320
            #else
            let size: CGFloat = 256
            #endif
            let cardWidth = CGFloat.cellWidth(maxCellWidth: size, containerWidth: width)
            
            let height = CellHeightCache.size(id: "videoCard", width: width) {
                let textsHeight = "a\na".heightWithConstrainedWidth(.greatestFiniteMagnitude, font: .styleFont(size: .small)) + 3 +
                                  [String](repeating: "a", count: subtitleLines).joined(separator: "\n").heightWithConstrainedWidth(.greatestFiniteMagnitude, font: .styleFont(size: .tiny))
                return ceil(cardWidth / 16.0 * 9.0) + 8 + textsHeight
            }
            return CGSize(width: cardWidth, height: height)
        } else {
            #if targetEnvironment(macCatalyst)
            let size: CGFloat = 80
            #else
            let size: CGFloat = 60
            #endif
            return CGSize(width: width, height: size)
        }
    }
    
    @EnvironmentObject private var navigation: Navigation<CommonCoordinator>
    
    enum Style {
        case card
        case list
    }
    
    enum Action {
        case showsDetails(wrap: (Video)->(VideoDetails.Content))
        case custom((Video)->())
    }
    
    let video: Video
    let showChannel: Bool
    var style: Style = .card
    let action: Action
    
    private var preview: some View {
        KFImage(video.thumbnailURL)
            .prepared()
            .background { Color(white: 0.5, opacity: 0.2) }
            .aspectRatio(16.0 / 9.0, contentMode: .fit)
            .modifier(IsCurrentModifier(video: video))
            .layoutPriority(1)
            .modifier(IsNewModifier(video: video))
            .modifier(VideoDurationModifier(video: video))
            .contentShape(.contextMenuPreview, RoundedRectangle(cornerRadius: 10, style: .continuous))
                .contextMenu { VideoMenu(video: video) }
    }
    
    private var texts: some View {
        VStack(spacing: 3) {
            if let title = video.title {
                Text(title).styled(size: .small)
                    .lineLimit(2)
                    .foregroundStyle(Color.label)
            }
            
            if detailsText.isValid {
                Text(detailsText).styled(size: .tiny)
                    .foregroundStyle(Color.secondaryText)
                    .lineLimit(2)
            }
        }
    }
    
    private var detailsText: String {
        var components: [String] = []
        if showChannel {
            components.appendSafe(video.channel?.title)
        }
        components.appendSafe(video.abbriviatedViews)
        components.appendSafe(video.published?.dateAgo)
        return components.joined(separator: " ∙ ")
    }
    
    var body: some View {
        Button(action: { performAction() }) {
            if style == .list {
                HStack(spacing: 15) {
                    preview
                    texts
                }
            } else {
                VStack(spacing: 0) {
                    preview.padding(.bottom, 8)
                    texts
                    Spacer(minLength: 0)
                }.frame(maxHeight: .infinity, alignment: .top)
            }
        }
    }
    
    private func performAction() {
        switch action {
        case .showsDetails(let wrap):
            navigation().present(.videoDetails(.init(wrap(video))))
        case .custom(let action):
            action(video)
        }
    }
}

#Preview {
    previewWithData {
        Video.example(ctx: $0.previewContext)
    } view: {
        VideoCell(video: $0, showChannel: true, action: .custom({ _ in })).padding(30)
    }
}
