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
        @Published var link: String = ""
        @Published var didFinishLoading: Bool = false

        // Misc
        @Dependency(\.appState) private var appState
        private var cancelBag = CancelBag()
        init () {
            cancelBag.collect {
                appState.map(\.session.auth_url)
                    .removeDuplicates()
                    .assign(to: \.link, on: self)
            }
        }
    }
}
