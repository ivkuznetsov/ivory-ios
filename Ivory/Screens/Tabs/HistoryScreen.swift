//
//  HistoryView.swift
//  Ivory
//
//  Created by Ilya Kuznetsov on 20/12/2022.
//

import SwiftUI
import SwiftUIComponents
import IvoryCore
import CommonUtils
import DependencyContainer
import GridView

struct HistoryScreen: View {
    
    @DI.Observed(DI.data, \.history) private var container
    
    var body: some View {
        GridView(reuseId: "\(container.items.hashValue)", setup: { $0.setupInsets() },
                 emptyState: .init({ EmptyStateView(title: "History is Empty",
                                                    details: "Here the viewed videos will appear") })) {
            $0.addSection(container.items.reversed())
        }.collectionSafeArea()
            .navigationTitle("History")
            .toolbar {
                ToolbarItem {
                    Menu("Clear") {
                        Button("Clear History", role: .destructive) {
                            Task { try await container.removeAll() }
                        }
                    }.disabled(container.items.isEmpty)
                }
            }
    }
}

#Preview {
    previewWithData {
        $0.$history.replace(MockStorage<Video>.make(ctx: $0.previewContext))
    } view: {
        NavigationStack { HistoryScreen() }
    }
}
