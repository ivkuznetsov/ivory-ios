//
//  GridState+Layout.swift
//  Ivory
//
//  Created by Ilya Kuznetsov on 14/11/2023.
//

import Foundation
import GridView
import UIKit
import LoaderUI

extension GridState {
    
    func setupInsets(top: CGFloat = .spacing) {
        view.contentInset = .init(top: top, left: .spacing, bottom: .spacing, right: .spacing)
        configureLayout = {
            if let layout = $0 as? UICollectionViewFlowLayout {
                layout.minimumInteritemSpacing = .spacing
                layout.minimumLineSpacing = .spacing
            }
        }
    }
}

extension CollectionSnapshot {
    
    func addLoading(_ view: PagingLoadingView) {
        add(view, staticSize: { CGSize(width: $0, height: 50) })
    }
}
