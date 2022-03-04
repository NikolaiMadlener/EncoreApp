//
//  AddSongBarViewModel.swift
//  encoreApp
//
//  Created by Nikolai Madlener on 02.03.22.
//  Copyright © 2022 NikolaiEtienne. All rights reserved.
//

import Foundation
import SwiftUI

// MARK: - ViewModel
extension AddSongsBarView {
    @MainActor class ViewModel: ObservableObject {
        
        // State
        @Published var isUserAdmin: Bool = false
        @Published var isPlaying: Bool = false
        var showAddSongSheet: Binding<Bool>
        
        // Misc
        @Dependency(\.appState) private var appState
        @Dependency(\.playerService) private var playerService
        @Dependency(\.musicControllerService) private var musicControllerService
        private var cancelBag = CancelBag()
        init(showAddSongSheet: Binding<Bool>) {
            self.showAddSongSheet = showAddSongSheet
            
            cancelBag.collect {
                appState.map(\.user.isAdmin)
                    .removeDuplicates()
                    .assign(to: \.isUserAdmin, on: self)
                appState.map(\.player.isPlaying)
                    .removeDuplicates()
                    .assign(to: \.isPlaying, on: self)
            }
        }
        
        // Functions
        func playPause() {
//            if !(self.musicControllerService.appRemote?.isConnected ?? false) {
//                self.musicControllerService.appRemote?.connect()
//                if !(self.musicControllerService.appRemote?.isConnected ?? false) {
//                    self.musicControllerService.appRemote?.authorizeAndPlayURI("")
//                    self.musicControllerService.appRemote?.connect()
//                }
//            }
            self.isPlaying ? self.playerService.playerPause() : self.playerService.playerPlay()
        }
        
        func skipNext() {
            self.playerService.playerSkipNext()
        }
    }
}
