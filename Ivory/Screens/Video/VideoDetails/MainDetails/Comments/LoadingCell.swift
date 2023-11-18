//
//  LoadingCell.swift
//  Ivory
//
//  Created by Ilya Kuznetsov on 16/01/2023.
//

import SwiftUI
import LoaderUI

struct LoadingCell: View {
    
    var body: some View {
        HStack {
            InCellProgressView(tintColor: .label, style: .small)
            Spacer()
        }.padding(.leading, 30).padding(.bottom, 15)
    }
}

#Preview {
    LoadingCell()
}
