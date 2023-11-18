//
//  ImagePreview.swift
//  Ivory
//
//  Created by Ilya Kuznetsov on 22/01/2023.
//

import SwiftUI

struct GifImageView: UIViewControllerRepresentable {
    
    let url: URL
    
    func makeUIViewController(context: Context) -> UINavigationController {
        let nc = UINavigationController(rootViewController: ImagePreviewViewController(url: url))
        nc.overrideUserInterfaceStyle = .dark
        return nc
    }
    
    func updateUIViewController(_ uiViewController: UINavigationController, context: Context) { }
}
