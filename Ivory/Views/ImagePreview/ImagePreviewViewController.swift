//
//  ImagePreviewViewController.swift
//  YouPlayer
//
//  Created by Ilya Kuznetsov on 12/6/17.
//  Copyright © 2017 Ilya Kuznetsov. All rights reserved.
//

import Foundation
import UIKit
import SwiftUIComponents

final class ImagePreviewViewController: UIViewController {
    
    private let url: URL
    private let image: UIImage
    private let scrollView = PreviewScrollView()
    private var viewLayouted: Bool = false
    
    init(url: URL) {
        self.url = url
        self.image = UIImage.gifImage(data: try! Data(contentsOf: url))!
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if !viewLayouted {
            scrollView.set(image: image)
            viewLayouted = true
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        scrollView.frame = view.bounds
        scrollView.contentInsetAdjustmentBehavior = .never
        view.attach(scrollView)
        navigationController?.navigationBar.tintColor = .tint
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Close", style: .plain, target: self, action: #selector(closeAction))
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(shareAction(_:)))
        
        view.overrideUserInterfaceStyle = .dark
    }
    
    @IBAction private func closeAction() {
        dismiss(animated: true, completion: nil)
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        DispatchQueue.main.async {
            self.scrollView.set(image: self.image)
        }
    }
    
    @objc private func shareAction(_ sender: UIBarButtonItem) {
        let vc = UIActivityViewController(activityItems: [url], applicationActivities: nil)
        vc.popoverPresentationController?.barButtonItem = sender
        vc.overrideUserInterfaceStyle = .dark
        present(vc, animated: true, completion: nil)
    }
}
