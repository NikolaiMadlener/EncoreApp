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

struct AuthSheet: UIViewControllerRepresentable {

    let url: URL
    @Binding var hasShownAuthView: Bool
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<AuthSheet>) -> SFSafariViewController {
        return SFSafariViewController(url: url)
    }

    func updateUIViewController(_ uiViewController: SFSafariViewController, context: UIViewControllerRepresentableContext<AuthSheet>) {
        //open homeview, after AuthSheet has been dismissed
        self.hasShownAuthView = true
    }
}
