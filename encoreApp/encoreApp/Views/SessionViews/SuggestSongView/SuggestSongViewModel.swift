//
//  SuggestSongViewModel.swift
//  encoreApp
//
//  Created by Nikolai Madlener on 02.03.22.
//  Copyright © 2022 NikolaiEtienne. All rights reserved.
//

import Foundation

// MARK: - ViewModel
extension SuggestSongView {
    @MainActor class ViewModel: ObservableObject {
        
        // State
        @Published var items: [SpotifySearchPayload.Tracks.Item] = []
        @Published var searchText : String = ""
        @Published var currentlyInSession: Bool = true
        @Published var showSessionExpiredAlert = false
        
        // Misc
        @Dependency(\.appState) private var appState
        private var cancelBag = CancelBag()
        init() {
            cancelBag.collect {
                $currentlyInSession
                    .sink { self.appState[\.session.currentlyInSession] = $0 }
                appState.map(\.session.currentlyInSession)
                    .removeDuplicates()
                    .assign(to: \.currentlyInSession, on: self)
            }
        }
    }
}
