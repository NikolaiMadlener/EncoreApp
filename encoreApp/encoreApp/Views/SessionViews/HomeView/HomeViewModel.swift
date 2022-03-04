//
//  HomeViewModel.swift
//  encoreApp
//
//  Created by Nikolai Madlener on 01.03.22.
//  Copyright © 2022 NikolaiEtienne. All rights reserved.
//

import Foundation
import CoreHaptics

// MARK: - ViewModel
extension HomeView {
    @MainActor class ViewModel: ObservableObject {
        
        // State
        @Published var song: Song = Song()
        @Published var songs: [Song] = []
        @Published var showMenuSheet = false
        @Published var showAddSongSheet = false
        @Published var current_title_offset: CGFloat = 0
        @Published var value: Float = 0.8
        @Published var offset = CGFloat()
        @Published private var engine: CHHapticEngine?
        

        // Misc
        @Dependency(\.appState) private var appState
        @Dependency(\.sseService) private var sseService
        private var cancelBag = CancelBag()
        init() {
            cancelBag.collect {
                appState.map(\.songs)
                    .removeDuplicates()
                    .assign(to: \.songs, on: self)
                appState.map(\.player.song)
                    .removeDuplicates()
                    .assign(to: \.song, on: self)
            }
        }
        
        // Functions
        func setupSSE() async {
            await sseService.setupEventSource()
        }
        
        func prepareHaptics() {
            guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }
            
            do {
                self.engine = try CHHapticEngine()
                try engine?.start()
            } catch {
                print("There was an error creating the engine: \(error.localizedDescription)")
            }
        }
        
        func hapticEvent() {
            prepareHaptics()
            
            // make sure that the device supports haptics
            guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }
            var events = [CHHapticEvent]()
            
            // create one intense, sharp tap
            let intensity = CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.6)
            let sharpness = CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.5)
            let event = CHHapticEvent(eventType: .hapticTransient, parameters: [intensity, sharpness], relativeTime: 0)
            events.append(event)
            
            // convert those events into a pattern and play it immediately
            do {
                let pattern = try CHHapticPattern(events: events, parameters: [])
                let player = try engine?.makePlayer(with: pattern)
                try player?.start(atTime: 0)
            } catch {
                print("Failed to play pattern: \(error.localizedDescription).")
            }
        }
    }
}
