//
//  SongTitleBarViewModel.swift
//  encoreApp
//
//  Created by Nikolai Madlener on 04.03.22.
//  Copyright © 2022 NikolaiEtienne. All rights reserved.
//

import Foundation

// MARK: - ViewModel
extension SongTitleBarView {
    @MainActor class ViewModel: ObservableObject {
        
        // State
        @Published var albumCover: UIImage = UIImage(imageLiteralResourceName: "IconPlaceholder")
        @Published var song: Song = Song()
        
        // Misc
        @Dependency(\.appState) private var appState
        private var cancelBag = CancelBag()
        init() {
            cancelBag.collect {
                appState.map(\.player.albumCover)
                    .removeDuplicates()
                    .assign(to: \.albumCover, on: self)
                appState.map(\.player.song)
                    .removeDuplicates()
                    .assign(to: \.song, on: self)
            }
        }
    }
}
