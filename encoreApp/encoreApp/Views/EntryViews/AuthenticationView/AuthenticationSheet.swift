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
import SafariServices

struct AuthenticationSheet: UIViewControllerRepresentable {
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    

    let url: URL
    @Binding var showAuthSheet: Bool
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<AuthenticationSheet>) -> SFSafariViewController {
        
        
        return SFSafariViewController(url: url)
    }

    func updateUIViewController(_ uiViewController: SFSafariViewController, context: UIViewControllerRepresentableContext<AuthenticationSheet>) {
        print(url)
        //open homeview, after AuthSheet has been dismissed
        print("UPDATE")
        //
    }
    
    class Coordinator: NSObject, SFSafariViewControllerDelegate {
        var authenticationSheet: AuthenticationSheet
        
        
        init(_ authenticationSheet: AuthenticationSheet) {
            self.authenticationSheet = authenticationSheet
        }
        
        func safariViewController(_ controller: SFSafariViewController, initialLoadDidRedirectTo URL: URL) {
            //if URL.absoluteString == "encore-fm.com" {
                controller.dismiss(animated: true, completion: nil)
                self.authenticationSheet.showAuthSheet = false
            //}
        }
        func safariViewController(_ controller: SFSafariViewController, activityItemsFor URL: URL, title: String?) -> [UIActivity] {
            controller.dismiss(animated: true, completion: nil)
            self.authenticationSheet.showAuthSheet = false
            return [UIActivity()]
        }
        func safariViewController(_ controller: SFSafariViewController, didCompleteInitialLoad didLoadSuccessfully: Bool) {
            controller.dismiss(animated: true, completion: nil)
            self.authenticationSheet.showAuthSheet = false
        }
    }
}
