//
//  SongListCellViewModel.swift
//  encoreApp
//
//  Created by Nikolai Madlener on 02.03.22.
//  Copyright © 2022 NikolaiEtienne. All rights reserved.
//

import Foundation
import SwiftUI

// MARK: - ViewModel
extension SongListCell {
    @MainActor class ViewModel: ObservableObject {
        
        // State
        @Published var voteState: VoteState = VoteState.NEUTRAL
        @Published var currentImage: Image = Image("albumPlaceholder")
        @Published var username: String = ""
        var song: Song
        var rank: Int
        
        // Misc
        @Dependency(\.appState) private var appState
        @Dependency(\.sessionService) private var sessionService
        private var cancelBag = CancelBag()
        init(song: Song, rank: Int) {
            self.song = song
            self.rank = rank
            
            cancelBag.collect {
                appState.map(\.user.username)
                    .removeDuplicates()
                    .assign(to: \.username, on: self)
            }
        }
        
        // Functions
        func upvote() {
            sessionService.upvote(songID: song.id)
        }
        
        func downvote() {
            sessionService.downvote(songID: song.id)
        }
    }
}
