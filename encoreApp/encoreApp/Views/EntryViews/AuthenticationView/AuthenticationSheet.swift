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

    let url: URL
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<AuthenticationSheet>) -> SFSafariViewController {
        return SFSafariViewController(url: url)
    }

    func updateUIViewController(_ uiViewController: SFSafariViewController, context: UIViewControllerRepresentableContext<AuthenticationSheet>) {
        //open homeview, after AuthSheet has been dismissed
        print("UPDATE")
    }
}
