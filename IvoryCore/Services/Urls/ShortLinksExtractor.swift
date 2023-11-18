//
//  ShortLinksExtractor.swift
//

import UIKit
import WebKit

@MainActor
public final class ShortLinksExtractor: NSObject, WKNavigationDelegate {

    private let completion: (URL)->()
    private let url: URL
    private let webView = WKWebView()
    private var holder: Any?
    private var currentURL: URL?
    
    private init(url: URL, completion: @escaping (URL)->()) {
        self.url = url
        self.completion = completion
        super.init()
        holder = self
        webView.navigationDelegate = self
        webView.load(URLRequest(url: url))
    }
    
    class func extract(url: URL) async -> URL {
        await withCheckedContinuation { continuation in
            _ = ShortLinksExtractor(url: url, completion: {
                continuation.resume(with: .success($0))
            })
        }
    }
    
    public nonisolated func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        Task { @MainActor in
            self.currentURL = navigationAction.request.url
            
            if self.currentURL?.supported() == true {
                self.processResult(url: self.currentURL)
                decisionHandler(.cancel)
                return
            }
            decisionHandler(.allow)
        }
    }
    
    public nonisolated func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        Task { @MainActor in
            self.processResult(url: currentURL)
        }
        
    }
    
    public nonisolated func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        Task { @MainActor in
            self.processResult(url: nil)
        }
    }
    
    private func processResult(url: URL?) {
        webView.stopLoading()
        completion(url ?? self.url)
        holder = nil
    }
}
