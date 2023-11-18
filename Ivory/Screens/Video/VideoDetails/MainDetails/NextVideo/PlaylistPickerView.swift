//
//  PlaylistPickerView.swift
//  Ivory
//
//  Created by Ilya Kuznetsov on 15/11/2023.
//

import Foundation
import DependencyContainer
import SwiftUI
import Loader
import LoaderUI
import GridView
import IvoryCore

struct PlaylistPickerView: View {
    
    @Environment(\.dismiss) private var dismiss
    
    @ObservedObject var paging: Paging<Video>.CommonManager
    let didSelect: (VideoDetails.Content)->()
    
    var body: some View {
        NavigationStack {
            PagingContainer(paging) { parameters in
                GridView(reuseId: "\(parameters.content.items.hashValue)", setup: { $0.setupInsets() }) {
                    $0.addSection(parameters.content.items, style: .list, showChannel: false, action: .custom({
                        didSelect(.playlist($0, paging))
                        dismiss()
                    }))
                }.ignoresSafeArea()
            }.navigationTitle("Playlist").toolbar {
                ToolbarItem {
                    Button(action: { dismiss() }, label: { Image(systemName: "xmark.circle.fill") })
                        .tint(Color(.tertiaryLabel))
                }
            }.navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    previewWithData { data -> Paging<Video>.CommonManager in
        let videos = [Video.example(ctx: data.previewContext),
                      Video.example(ctx: data.previewContext),
                      Video.example(ctx: data.previewContext)]
        
        let paging = Paging<Video>.CommonManager()
        paging.dataSource.update(content: .init(items: videos))
        return paging
    } view: { paging in
        NavigationStack { PlaylistPickerView(paging: paging, didSelect: { _ in }) }
    }
}
