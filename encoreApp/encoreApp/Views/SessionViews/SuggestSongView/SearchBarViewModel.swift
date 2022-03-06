//
//  SearchBarViewModel.swift
//  encoreApp
//
//  Created by Nikolai Madlener on 02.03.22.
//  Copyright © 2022 NikolaiEtienne. All rights reserved.
//

import Foundation
import SwiftUI

// MARK: - ViewModel
extension SearchBar {
    @MainActor class ViewModel: ObservableObject {

        //State
        var items: Binding<[SpotifySearchPayload.Tracks.Item]>
        
        // Misc
        @Dependency(\.appState) private var appState
        @Dependency(\.sessionService) private var sessionService
        init(items: Binding<[SpotifySearchPayload.Tracks.Item]>) {
            self.items = items
        }
        
        // Functions
        func searchSong(query: String) {
            sessionService.searchSong(query: query, binding: items)
        }
    }
}
