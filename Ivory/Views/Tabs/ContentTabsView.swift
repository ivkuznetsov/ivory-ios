//
//  FeaturedView.swift
//  Ivory
//
//  Created by Ilya Kuznetsov on 10/01/2023.
//

import SwiftUI
import SwiftUIComponents

struct ContentTabsView: View {
    
    @StateObject private var state: TabsState<ViewItem>
    
    init(items: [ViewItem]) {
        _state = .init(wrappedValue: .init(items: items))
    }
    
    var body: some View {
        ZStack {
            state.selected.view().asAny
        }.navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    OrientationContainer { orientation in
                        TabsView(state: state).frame(width: min(400, UIScreen.main.bounds.size.width - 60))
                    }
                }
            }
    }
}

#Preview {
    NavigationStack {
        ContentTabsView(items: [.init(title: "View 1", view: { Color.red }),
                                .init(title: "View 2", view: { Color.blue }),
                                .init(title: "View 3", view: { Color.green })])
    }
}
