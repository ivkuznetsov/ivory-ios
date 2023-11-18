//
//  ActionViewController.swift
//  IvoryOpener
//
//  Created by Ilya Kuznetsov on 18/01/2023.
//

import UIKit
import MobileCoreServices
import UniformTypeIdentifiers

class ActionViewController: UIViewController {

    @IBOutlet private var label: UILabel?
    @IBOutlet private var button: UIButton!
    @IBOutlet private var loadingView: UIView!
    private var url: URL!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        loadingView.isHidden = false
        for item in self.extensionContext!.inputItems as! [NSExtensionItem] {
            for provider in item.attachments! {
                if provider.hasItemConformingToTypeIdentifier(UTType.url.identifier) {
                    
                    Task { [weak self] in
                        do {
                            guard let url = try await provider.loadItem(forTypeIdentifier: UTType.url.identifier) as? URL else { return }
                            
                            let extracted = await ShortLinksExtractor.extract(url: url)
                            
                            self?.loadingView.isHidden = true
                            if url.supported() {
                                self?.url = URL(string: "ivory://\(extracted.absoluteString)")
                                self?.button.isHidden = false
                                self?.label?.text = extracted.absoluteString
                            } else {
                                self?.label?.text = "It looks like this is not a YouTube link.\nCannot open this in Ivory"
                            }
                        } catch {
                            self?.loadingView.isHidden = true
                            self?.label?.text = error.localizedDescription
                        }
                    }
                    return
                }
            }
        }
        label?.text = "Cannot open this in Ivory"
    }
    
    @IBAction func redirectToHostApp() {
            let selectorOpenURL = sel_registerName("openURL:")
            let context = NSExtensionContext()
            context.open(url!, completionHandler: nil)

            var responder = self as UIResponder?

            while (responder != nil){
                if responder?.responds(to: selectorOpenURL) == true {
                    responder?.perform(selectorOpenURL, with: url)
                }
                responder = responder!.next
            }

        }

    @IBAction func done() {
        if let items = extensionContext?.inputItems {
            extensionContext?.completeRequest(returningItems: items)
        }
    }
}
