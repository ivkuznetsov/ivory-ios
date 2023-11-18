//
//  TextView.swift
//  Ivory
//
//  Created by Ilya Kuznetsov on 15/01/2023.
//

import SwiftUI
import UIKit

struct TextView: UIViewRepresentable {
    
    @Environment(\.openURL) var openURL
    
    fileprivate class TextViewDelegate: NSObject, UITextViewDelegate {
        
        let openURL: (URL)->()
        
        init(openURL: @escaping (URL) -> ()) {
            self.openURL = openURL
        }
        
        func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
            openURL(URL)
            return false
        }
    }
    
    let text: String
    
    func makeUIView(context: Context) -> UITextView {
        let textView = UITextView()
        textView.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        textView.isSelectable = true
        textView.isEditable = false
        textView.backgroundColor = .clear
        textView.dataDetectorTypes = [.link]
        textView.tintColor = .tint
        textView.isScrollEnabled = false
        textView.font = UIFont.styleFont(size: .small)
        textView.textContainer.lineFragmentPadding = 0
        textView.textContainerInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        
        let delegate = TextViewDelegate { openURL($0) }
        textView.delegate = delegate
        delegate.retained(by: textView)
        return textView
    }
    
    func updateUIView(_ uiView: UITextView, context: Context) {
        uiView.text = text
    }
}
