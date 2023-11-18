//
//  VideoDescriptionView.swift
//  Ivory
//
//  Created by Ilya Kuznetsov on 15/01/2023.
//

import SwiftUI
import IvoryCore
import CommonUtils
import DependencyContainer
import GridView

private extension Video {
    
    var subtitle: String {
        var components: [String] = []
        components.appendSafe(abbriviatedViews)
        components.appendSafe(published?.dateAgo)
        return components.joined(separator: " ∙ ")
    }
}

struct VideoDescriptionView: View {
    
    @DI.Observed(DI.pinService) private var pinService
    @DI.Observed(DI.data, \.kidsSpace.channels) private var kidsChannels
    
    @ObservedObject var video: Video
    
    static func size(video: Video, width: CGFloat) -> CGSize {
        let height = CellHeightCache.size(id: video, width: width) {
            var height: CGFloat = video.channel == nil ? 0 : 60
            
            height += (video.title ?? "").heightWithConstrainedWidth(width, font: .styleFont(size: .big))
            height += 15
            
            height += video.subtitle.heightWithConstrainedWidth(width, font: .styleFont(size: .small))
            height += 15
            
            height += (video.videoDescription ?? "").heightWithConstrainedWidth(width, font: .styleFont(size: .small))
            height += 15
            
            return height
        }
        return CGSize(width: width, height: height)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            if let channel = video.channel {
                ChannelCell(channel: channel)
                    .disabled(pinService.pinSet && !kidsChannels.has(channel))
                    .frame(maxHeight: ChannelCell.size().height)
                    .padding(-5)
            }
            
            Text(video.title ?? "").styled(size: .big)
                .layoutPriority(100)
            
            Text(video.subtitle).styled(size: .small)
            
            TextView(text: video.videoDescription ?? "")
        }
    }
}

#Preview {
    previewWithData {
        Video.example(ctx: $0.previewContext)
    } view: {
        VideoDescriptionView(video: $0).padding(15)
    }
}
