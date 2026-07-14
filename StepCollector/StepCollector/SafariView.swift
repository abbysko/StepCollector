//
//  SafariView.swift
//  Step Collector
//
//  Created by Abigail Skofield on 7/14/26.
//

import SwiftUI
import WebKit

struct WebView: UIViewRepresentable {
    let url: URL

    func makeCoordinator() -> Coordinator {
        Coordinator(rootURL: url)
    }

    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView(frame: .zero)
        webView.scrollView.contentInsetAdjustmentBehavior = .never
        webView.allowsBackForwardNavigationGestures = true
        webView.navigationDelegate = context.coordinator
        webView.load(URLRequest(url: url))
        return webView
    }

    func updateUIView(_ webView: WKWebView, context: Context) {
        guard webView.url != url else { return }
        webView.load(URLRequest(url: url))
    }

    final class Coordinator: NSObject, WKNavigationDelegate {
        private let rootURL: URL

        init(rootURL: URL) {
            self.rootURL = rootURL
        }

        func webView(
            _ webView: WKWebView,
            decidePolicyFor navigationAction: WKNavigationAction,
            decisionHandler: @escaping (WKNavigationActionPolicy) -> Void
        ) {
            guard let requestedURL = navigationAction.request.url else {
                decisionHandler(.allow)
                return
            }

            guard shouldOpenExternally(requestedURL, navigationType: navigationAction.navigationType) else {
                decisionHandler(.allow)
                return
            }

            UIApplication.shared.open(requestedURL)
            decisionHandler(.cancel)
        }

        private func shouldOpenExternally(_ url: URL, navigationType: WKNavigationType) -> Bool {
            guard navigationType == .linkActivated else {
                return false
            }

            guard let scheme = url.scheme?.lowercased() else {
                return true
            }

            if scheme != "http" && scheme != "https" {
                return true
            }

            guard let host = url.host?.lowercased(),
                  let rootHost = rootURL.host?.lowercased() else {
                return true
            }

            guard host == rootHost else {
                return true
            }

            let normalizedRootPath = normalizedPath(rootURL.path)
            let normalizedRequestedPath = normalizedPath(url.path)

            if normalizedRequestedPath == normalizedRootPath {
                return false
            }

            return !normalizedRequestedPath.hasPrefix(normalizedRootPath + "/")
        }

        private func normalizedPath(_ path: String) -> String {
            if path.isEmpty || path == "/" {
                return "/"
            }

            return path.hasSuffix("/") ? String(path.dropLast()) : path
        }
    }
}
