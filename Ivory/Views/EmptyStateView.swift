//
//  EmptyStateView.swift
//  Ivory
//
//  Created by Ilya Kuznetsov on 18/01/2023.
//

import SwiftUI

struct EmptyStateView: View {
    
    let title: String
    let details: String
    
    var body: some View {
        VStack(spacing: 8) {
            Text(title).styled(alignment: .center, size: .big)
            Text(details).styled(alignment: .center).opacity(0.5)
        }.foregroundStyle(Color.secondaryText)
            .padding(30)
    }
}

#Preview {
    EmptyStateView(title: "No Items", details: "Some details string")
}
