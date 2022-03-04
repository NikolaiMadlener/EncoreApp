//
//  AppContentViewModel.swift
//  encoreApp
//
//  Created by Nikolai Madlener on 02.03.22.
//  Copyright © 2022 NikolaiEtienne. All rights reserved.
//

import Foundation
// MARK: - ViewModel
extension AppContentView {
    @MainActor class ViewModel: ObservableObject {
        
        // State
        @Published var showJoinSheet: Bool = false
        @Published var currentlyInSession: Bool = false
        var joinedViaURL: Bool
        var sessionID: String
        
        // Misc
        @Dependency(\.appState) private var appState
        private var cancelBag = CancelBag()
        init(joinedViaURL: Bool, sessionID: String) {
            self.joinedViaURL = joinedViaURL
            self.sessionID = sessionID
            
            cancelBag.collect {
                appState.map(\.session.currentlyInSession)
                    .removeDuplicates()
                    .assign(to: \.currentlyInSession, on: self)
            }
        }
    }
}
