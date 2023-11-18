//
//  HostingWindowFinder.swift
//  Ivory
//
//  Created by Ilya Kuznetsov on 13/11/2023.
//

import Foundation
import SwiftUI
import UIKit

private struct HostingWindowFinder: UIViewRepresentable {
    
    var callback: (UIWindow?) -> ()

    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        DispatchQueue.main.async { [weak view] in
            callback(view?.window)
        }
        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) { }
}

extension View {
    
    func withHostingWindow(_ callback: @escaping (UIWindow?) -> Void) -> some View {
        self.background(HostingWindowFinder(callback: callback))
    }
}
