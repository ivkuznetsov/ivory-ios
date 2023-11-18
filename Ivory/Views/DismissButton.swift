//
//  DismissButton.swift
//  Ivory
//
//  Created by Ilya Kuznetsov on 04/04/2023.
//

import Foundation
import SwiftUI

struct DismissButton<L: View>: View {
    
    @Environment(\.dismiss) private var dismiss
    
    @ViewBuilder let label: ()->L
    var shouldDismiss: (()->Bool)? = nil
    
    var body: some View {
        Button {
            if shouldDismiss?() ?? true {
                dismiss()
            }
        } label: { label() }
    }
}
