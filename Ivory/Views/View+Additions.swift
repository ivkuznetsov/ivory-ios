//
//  View+Additions.swift
//  Ivory
//
//  Created by Ilya Kuznetsov on 28/12/2022.
//

import SwiftUI
import Kingfisher
import CoreData
import Combine
import IvoryCore

extension KFImage {
    
    func prepared() -> some View {
        fade(duration: 0.15)
            .resizable()
            .requestModifier { $0.authotize() }
    }
}

extension View {
    
    func bordered(_ cornerRadius: CGFloat, color: Color? = nil, width: CGFloat = 1) -> some View {
        overlay(content: {
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .stroke(color ?? .label.opacity(0.2), lineWidth: width)
        }).cornerRadius(cornerRadius)
    }
    
    func collectionSafeArea() -> some View {
        ignoresSafeArea(edges: .all)
    }
}
