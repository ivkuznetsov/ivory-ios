//
//  WatchLaterView.swift
//  Ivory
//
//  Created by Ilya Kuznetsov on 20/01/2023.
//

import SwiftUI
import SwiftUIComponents
import IvoryCore
import CommonUtils
import DependencyContainer
import GridView
import Loader

struct WatchLaterView: View {
    
    @DI.Observed(DI.data, \.watchLater) private var container
    
    var body: some View {
        GridView(reuseId: "\(container.items.hashValue)",
                 setup: { $0.setupInsets() },
                 emptyState: .init({ EmptyStateView(title: "No More Videos", details: "Add more by menu button") })) {
            $0.addSection(container.items, action: .showsDetails(wrap: { .watchLater($0) }))
        }.collectionSafeArea()
            .navigationTitle("Watch Later Playlist")
    }
}

#Preview {
    previewWithData { data in
        data.$watchLater.replace(MockStorage<Video>.make(ctx: data.previewContext))
    } view: {
        NavigationStack { WatchLaterView() }
    }
}
