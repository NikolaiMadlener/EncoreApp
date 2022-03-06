//
//  SuggestSongCellViewModel.swift
//  encoreApp
//
//  Created by Nikolai Madlener on 02.03.22.
//  Copyright © 2022 NikolaiEtienne. All rights reserved.
//

import Foundation
import SwiftUI

// MARK: - ViewModel
extension SuggestSongCell {
    @MainActor class ViewModel: ObservableObject {
        
        // State
        @Published var currentImage: Image = Image("albumPlaceholder")
        @Published var addingInProcess = false
        @Published var songs: [Song] = []
        @Published var currentSong: Song = Song()
        var song: SpotifySearchPayload.Tracks.Item
        
        
        // Misc
        @Dependency(\.appState) private var appState
        @Dependency(\.sessionService) private var sessionService
        private var cancelBag = CancelBag()
        init(song: SpotifySearchPayload.Tracks.Item) {
            self.song = song
            cancelBag.collect {
                appState.map(\.songs)
                    .removeDuplicates()
                    .assign(to: \.songs, on: self)
                appState.map(\.player.song)
                    .removeDuplicates()
                    .assign(to: \.currentSong, on: self)
            }
        }
        
        // Functions
        func suggestSong(songID: String) {
            sessionService.suggestSong(songID: songID)
        }
    }
}
