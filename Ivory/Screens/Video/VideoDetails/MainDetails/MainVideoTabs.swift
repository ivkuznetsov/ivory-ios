//
//  MainVideoTabs.swift
//  Ivory
//
//  Created by Ilya Kuznetsov on 22/01/2023.
//

import SwiftUI
import CommonUtils
import SwiftUIComponents

struct MainVideoTabs: View {
    
    @MainActor final class State: ObservableObject {
        
        enum Tab: String, TabsItem, CaseIterable {
            case description
            case comments
            case related
        }
        
        @RePublished var state = TabsState(items: Tab.allCases)
        
        func reloadTabs(_ attr: OrientationAttributes) {
            let tabs: [Tab]
            
            if attr.orientation == .portrait {
                tabs = [.description, .comments, .related]
            } else {
                tabs = [.description, .comments]
            }
            
            if state.items != tabs {
                state.items = tabs
            }
        }
    }
    
    @ObservedObject var state: State
    
    var body: some View {
        OrientationContainer { orientation in
            TabsView(state: state.state)
                .frame(maxWidth: CGFloat(state.state.items.count * 130))
                .onFirstAppear { state.reloadTabs(orientation) }
        } didChange: {
            state.reloadTabs($0)
        }
    }
}

#Preview {
    MainVideoTabs(state: MainVideoTabs.State())
}
