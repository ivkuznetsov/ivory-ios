//
//  VideoDetailsScreen.swift
//  Ivory
//
//  Created by Ilya Kuznetsov on 09/01/2023.
//

import SwiftUI
import SwiftUIComponents
import Combine
import Kingfisher
import IvoryCore
import DependencyContainer
import Loader
import LoaderUI

struct VideoDetailsScreen: View {
    
    @MainActor final class State: ObservableObject {
        
        @DI.RePublished(DI.pinService) var pinService
        
        let loader = Loader()
        let sideDetails: SideDetailsView.State
        let mainDetails: MainDetailsView.State
        
        init(details: VideoDetails) {
            let detailsPaging = Paging<Video>.CommonManager(initialLoading: .none(), loader: loader)
            
            sideDetails = SideDetailsView.State(detailsPaging: detailsPaging, details: details)
            mainDetails = MainDetailsView.State(detailsPaging: detailsPaging, details: details)
        }
    }
    
    @StateObject private var state: State
    
    init(details: VideoDetails) {
        _state = .init(wrappedValue: .init(details: details))
    }
    
    func sideBarWidth(_ orientation: OrientationAttributes.Orientation, fullWidth: CGFloat) -> CGFloat {
        if orientation == .landscape && !state.pinService.pinSet && fullWidth > 0 {
            return floor(min(fullWidth * 0.4, 500))
        }
        return 0
    }
    
    var body: some View {
        LoadingContainer(state.loader) {
            GeometryReader { proxy in
                OrientationContainer { attr in
                    HStack(spacing: 0) {
                        MainDetailsView(state: state.mainDetails)
                            .frame(width: proxy.size.width - sideBarWidth(attr.orientation, fullWidth: proxy.size.width))
                        
                        SideDetailsView(state: state.sideDetails)
                            .frame(width: sideBarWidth(attr.orientation, fullWidth: proxy.size.width))
                            .opacity(attr.orientation == .landscape ? 1 : 0)
                    }
                }
            }
        }.navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    previewWithData {
        DI.Container.resolve(DI.settings).autoStartVideo = false
        $0.$videos.replace(VideosRepositoryMock())
        $0.$comments.replace(CommentsRepositoryMock())
        return await $0.makeExample { Video.example(ctx: $0) }
    } view: { video in
        NavigationStack { VideoDetailsScreen(details: .init(.video(video))) }
    }
}
