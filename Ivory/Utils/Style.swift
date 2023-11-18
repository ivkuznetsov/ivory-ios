//
//  Text+Style.swift
//  Ivory
//
//  Created by Ilya Kuznetsov on 23/01/2023.
//

import SwiftUI

extension Color {
    
    static var label: Color { Color(UIColor.label) }
    static var secondaryText: Color { .label.opacity(0.5) }
    static var control: Color { .label.opacity(0.05) }
}

enum TextSize: CGFloat {
    #if targetEnvironment(macCatalyst)
    case big = 25
    case normal = 18
    case small = 15
    case tiny = 13
    #else
    case big = 18
    case normal = 15
    case small = 13
    case tiny = 11
    #endif
}

extension View {
    
    func styled(alignment: TextAlignment = .leading, size: TextSize = .normal) -> some View {
        font(.system(size: size.rawValue))
        .multilineTextAlignment(alignment)
        .frame(maxWidth: alignment == .leading ? .infinity : nil, alignment: alignment == .leading ? .leading : .center)
    }
}

extension UIFont {
    
    static func styleFont(size: TextSize = .normal) -> UIFont {
        .systemFont(ofSize: size.rawValue)
    }
}

extension CGFloat {
    #if targetEnvironment(macCatalyst)
    static let spacing: CGFloat = 20
    #else
    static let spacing: CGFloat = 15
    #endif
    
    static func cellWidth(maxCellWidth: CGFloat, containerWidth: CGFloat) -> CGFloat {
        let itemsCount = ceil((containerWidth + .spacing) / (maxCellWidth + .spacing))
        return floor(((containerWidth + .spacing) / itemsCount) - .spacing)
    }
}
