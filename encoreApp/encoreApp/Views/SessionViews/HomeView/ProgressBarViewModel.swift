//
//  ProgressBarViewModel.swift
//  encoreApp
//
//  Created by Nikolai Madlener on 04.03.22.
//  Copyright © 2022 NikolaiEtienne. All rights reserved.
//

import Foundation
import SwiftUI

// MARK: - ViewModel
extension ProgressBarView {
    @MainActor class ViewModel: ObservableObject {
        
        // State
        @Published var songTimestamp_ms: CGFloat = 0
        @Published var song: Song = Song()
        @Published var isPlaying: Bool = false
        var showMenuSheet: Binding<Bool>
        var isWide: Bool
        
        // Misc
        @Dependency(\.appState) private var appState
        private var cancelBag = CancelBag()
        init(showMenuSheet: Binding<Bool>, isWide: Bool) {
            self.showMenuSheet = showMenuSheet
            self.isWide = isWide
            
            cancelBag.collect {
                $songTimestamp_ms
                    .sink { self.appState[\.player.songTimestamp_ms] = $0 }
                appState.map(\.player.songTimestamp_ms)
                    .removeDuplicates()
                    .assign(to: \.songTimestamp_ms, on: self)
                appState.map(\.player.song)
                    .removeDuplicates()
                    .assign(to: \.song, on: self)
                appState.map(\.player.isPlaying)
                    .removeDuplicates()
                    .assign(to: \.isPlaying, on: self)
            }
        }
    }
}
