//
//  ImportLinkView.swift
//  Ivory
//
//  Created by Ilya Kuznetsov on 14/11/2023.
//

import Foundation
import SwiftUI
import IvoryCore

struct ImportLinkView: UIViewRepresentable {
    
    @Environment(\.openURL) private var openURL
    
    private final class Helper: NSObject {
        
        let completion: ([UIAction])->()
        
        init(completion: @escaping ([UIAction]) -> Void) {
            self.completion = completion
        }
        
        @objc func complete(result: [UIAction]) {
            completion(result)
        }
    }
    
    func makeUIView(context: Context) -> UIButton {
        let button = UIButton(type: .system)
        button.showsMenuAsPrimaryAction = true
        button.menu = UIMenu(title: "", children: [UIDeferredMenuElement.uncached({ completion in
            let helper = Helper(completion: completion)
            
            let elements: [UIAction]
            
            do {
                let url = try URLProcessor().processURLFromPasterboard()
                
                elements = [UIAction(title: "\(url.absoluteString)", attributes: .disabled, handler: { _ in}),
                            UIAction(title: "Open", handler: { _ in
                      openURL(url)
                  })]
            } catch {
                elements = [UIAction(title: error.localizedDescription, attributes: .disabled, handler: { _ in })]
            }
            
            DispatchQueue.global(qos: .default).async {
                //UIDeferredMenuElement doesn't work in Mac catalyst by normal way, need to run in runloop common mode
                helper.performSelector(onMainThread: #selector(Helper.complete(result:)), with: elements, waitUntilDone: true, modes: [RunLoop.Mode.common.rawValue])
            }
        })])
        button.setImage(UIImage(systemName: "arrow.down.app"), for: .normal)
        return button
    }
    
    func updateUIView(_ uiView: UIButton, context: Context) { }
}

#Preview {
    ImportLinkView()
}
