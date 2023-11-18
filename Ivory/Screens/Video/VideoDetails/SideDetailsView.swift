//
//  SideDetails.swift
//  Ivory
//
//  Created by Ilya Kuznetsov on 22/01/2023.
//

import SwiftUI
import SwiftUIComponents
import Combine
import IvoryCore
import CommonUtils
import DependencyContainer
import GridView
import Loader
import LoaderUI

struct SideDetailsView: View {
    
    @MainActor final class State: ObservableObject {
        
        @DI.RePublished(DI.pinService) var pinService
        @DI.RePublished(DI.data, \.watchLater) var watchLater

        enum SideBarTab: String, TabsItem, CaseIterable {
            case playlist
            case related
        }
        
        @RePublished var sideBarTab = TabsState(items: SideBarTab.allCases)
        @RePublished var detailsPaging: Paging<Video>.CommonManager
        let pagingPlaceholder = Paging<Video>.CommonManager()
        @RePublished var details: VideoDetails
        
        init(detailsPaging: Paging<Video>.CommonManager, details: VideoDetails) {
            self.detailsPaging = detailsPaging
            self.details = details
        }
        
        var sideBarPaging: Paging<Video>.CommonManager? {
            switch details.content {
            case .video(_): return detailsPaging
            case .watchLater(_): return sideBarTab.selected == .playlist ? nil : detailsPaging
            case .playlist(_, let paging): return sideBarTab.selected == .playlist ? paging : detailsPaging
            }
        }
    }
    
    @ObservedObject var state: State
    
    var body: some View {
        OrientationContainer { attr in
            if attr.orientation == .landscape, let paging = state.sideBarPaging {
                PagingContainer(paging) { parameters in
                    GridView(reuseId: "\(parameters.content.items.hashValue)", setup: { $0.setupInsets(top: 10) }) {
                        if attr.orientation == .landscape && !state.pinService.pinSet {
                            if !state.details.content.isJustVideo {
                                $0.add(TabsView(state: state.sideBarTab).frame(maxWidth: 200).padding(.bottom, 15),
                                       staticSize: { CGSize(width: $0, height: 32 + 15) })
                            }
                            
                            let action: (Video)->() = {
                                if state.sideBarTab.selected == .playlist {
                                    switch state.details.content {
                                    case .playlist(_, let paging):
                                        state.details.content = .playlist($0, paging)
                                    case .watchLater(_):
                                        state.details.content = .watchLater($0)
                                    case .video(_):
                                        state.details.content = .video($0)
                                    }
                                } else {
                                    state.details.content = .video($0)
                                }
                            }
                            
                            if case .watchLater(_) = state.details.content, state.sideBarTab.selected == .playlist {
                                $0.addSection(state.watchLater.items,
                                              style: .list,
                                              action: .custom(action))
                            } else {
                                $0.addSection(parameters.content.items, style: .list, action: .custom(action))
                                $0.addLoading(parameters.loading)
                            }
                        }
                    }.ignoresSafeArea(edges: [.trailing, .bottom])
                }
            }
        }
    }
}
