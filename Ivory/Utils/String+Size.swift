//
//  String+Size.swift
//  Mood
//
//  Created by Ilya Kuznetsov on 30/09/2023.
//

import Foundation
import UIKit

extension String {

    func heightWithConstrainedWidth(_ width: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = self.boundingRect(with: constraintRect,
                                            options: .usesLineFragmentOrigin,
                                            attributes: [.font: font],
                                            context: nil)
        return ceil(boundingBox.height)
    }

}
