//
//  FavoriteVideos.swift
//  Ivory
//
//  Created by Ilya Kuznetsov on 22/01/2023.
//

import SwiftUI
import SwiftUIComponents
import IvoryCore
import CommonUtils
import DependencyContainer
import GridView

struct FavoriteVideosView: View {
    
    @DI.Observed(DI.data, \.favorites.videos) private var container
    
    @ViewBuilder var body: some View {
        GridView(reuseId: "\(container.items.hashValue)",
                 setup: { $0.setupInsets() }, emptyState: .init({ EmptyStateView(favoriteType: "Videos", details: "video") })) {
            $0.addSection(container.items)
        }.collectionSafeArea()
    }
}

#Preview {
    previewWithData { data in
        data.$favorites.replace(StorageGroup.makeMocked(ctx: data.previewContext, withObjects: true))
    } view: {
        NavigationStack { FavoriteVideosView() }
    }
}
