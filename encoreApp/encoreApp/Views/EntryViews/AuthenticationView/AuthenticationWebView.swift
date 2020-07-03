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
    @ObservedObject var webVM: WebVM
    @Binding var showAuthSheet: Bool

    let webView = WKWebView()

    func makeUIView(context: UIViewRepresentableContext<AuthenticationWebView>) -> WKWebView {
        self.webView.navigationDelegate = context.coordinator
        if let url = URL(string: webVM.link) {
            self.webView.load(URLRequest(url: url))
        
        }
        return self.webView
    }

    func updateUIView(_ uiView: WKWebView, context: UIViewRepresentableContext<AuthenticationWebView>) {
        
        if webVM.link == "encore-fm.com" {
            self.showAuthSheet = false
        }
        
        return
    }

    class Coordinator: NSObject, WKNavigationDelegate {
        private var webVM: WebVM
        
        init(_ webVM: WebVM) {
            self.webVM = webVM
        }

        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            self.webVM.didFinishLoading = true
            
        }
         func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
            if let host = navigationAction.request.url?.host {
                if host.contains("encore-fm.com") {
                    webVM.link = host
                    decisionHandler(.allow)
                    
                    return
                }
            }
            decisionHandler(.allow)
        }
    }

    func makeCoordinator() -> AuthenticationWebView.Coordinator {
        Coordinator(webVM)
    }
}


class WebVM: ObservableObject {
    @Published var link: String
    @Published var didFinishLoading: Bool = false

    init (link: String) {
        self.link = link
    }
}

