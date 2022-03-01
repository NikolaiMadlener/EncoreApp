//
//  AuthenticationWebViewModel.swift
//  encoreApp
//
//  Created by Nikolai Madlener on 01.03.22.
//  Copyright © 2022 NikolaiEtienne. All rights reserved.
//

import Foundation

// MARK: - ViewModel
extension AuthenticationWebView {
    @MainActor class ViewModel: ObservableObject {
        
        // State
        @Published var link: String
        @Published var didFinishLoading: Bool = false

        // Misc
        init (link: String) {
            self.link = link
        }
    }
}
