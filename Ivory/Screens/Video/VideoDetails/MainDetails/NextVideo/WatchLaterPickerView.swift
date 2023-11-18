//
//  WatchLaterPickerView.swift
//  Ivory
//
//  Created by Ilya Kuznetsov on 15/11/2023.
//

import Foundation
import SwiftUI
import DependencyContainer
import GridView
import IvoryCore

struct WatchLaterPickerView: View {
    
    @DI.Observed(DI.data, \.watchLater) private var container
    @Environment(\.dismiss) private var dismiss
    
    let didSelect: (VideoDetails.Content)->()
    
    var body: some View {
        NavigationStack {
            GridView(reuseId: "\(container.items.hashValue)", setup: { $0.setupInsets() }) {
                $0.addSection(container.items, style: .list, action: .custom({
                    didSelect(.watchLater($0))
                    dismiss()
                }))
            }.ignoresSafeArea().navigationTitle("Watch Later Playlist").toolbar {
                ToolbarItem {
                    Button(action: { dismiss() }, label: { Image(systemName: "xmark.circle.fill") })
                        .tint(Color(.tertiaryLabel))
                }
            }.navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    previewWithData { data in
        data.$watchLater.replace(MockStorage<Video>.make(ctx: data.previewContext))
    } view: {
        NavigationStack { WatchLaterPickerView(didSelect: { _ in }) }
    }
}
