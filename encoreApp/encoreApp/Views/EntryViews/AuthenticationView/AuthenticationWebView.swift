//
//  AuthenticationView.swift
//  encoreApp
//
//  Created by Etienne Köhler on 21.06.20.
//  Copyright © 2020 NikolaiEtienne. All rights reserved.
//

import Foundation
import UIKit
import SwiftUI
import WebKit

struct AuthenticationWebView: UIViewRepresentable {
    @ObservedObject var viewModel: ViewModel
    @Binding var showAuthSheet: Bool
    @Binding var showActivityIndicator: Bool

    let webView = WKWebView()

    func makeUIView(context: UIViewRepresentableContext<AuthenticationWebView>) -> WKWebView {
        self.webView.navigationDelegate = context.coordinator
        if let url = URL(string: viewModel.link) {
            self.webView.load(URLRequest(url: url))
        
        }
        return self.webView
    }

    func updateUIView(_ uiView: WKWebView, context: UIViewRepresentableContext<AuthenticationWebView>) {
        
        if viewModel.link == "encore-fm.com" {
            self.showAuthSheet = false
            self.showActivityIndicator = false
        }
        
        return
    }

    class Coordinator: NSObject, WKNavigationDelegate {
        private var viewModel: ViewModel
        
        init(_ viewModel: ViewModel) {
            self.viewModel = viewModel
        }

        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            DispatchQueue.main.async {
                self.viewModel.didFinishLoading = true
            }
        }
         func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
            if let host = navigationAction.request.url?.host {
                if host.contains("encore-fm.com") {
                    DispatchQueue.main.async {
                        self.viewModel.link = host
                    }
                    decisionHandler(.allow)
                    
                    return
                }
            }
            decisionHandler(.allow)
        }
    }

    func makeCoordinator() -> AuthenticationWebView.Coordinator {
        Coordinator(viewModel)
    }
}

