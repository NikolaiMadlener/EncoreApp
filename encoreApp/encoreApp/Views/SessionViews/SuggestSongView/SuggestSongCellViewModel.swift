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
            let username = appState[\.user.username]
            let sessionID = appState[\.session.sessionID]
            let secret = appState[\.session.secret]
            
            guard let url = URL(string: "https://api.encore-fm.com/users/"+"\(username)"+"/suggest/"+"\(songID)") else {
                print("Invalid URL")
                return
                
            }
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.addValue(secret, forHTTPHeaderField: "Authorization")
            request.addValue(sessionID, forHTTPHeaderField: "Session")
            
            let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
                // Check for Error
                if let error = error {
                    print("Error took place \(error)")
                    return
                }
                
                // Convert HTTP Response Data to a String
                if let data = data, let dataString = String(data: data, encoding: .utf8) {
                    print("Response data string:\n \(dataString)")
                    do {
                        let decodedData = try JSONDecoder().decode(Song.self, from: data)
                        print("Successfully post of suggest song: \(decodedData.name)")
                    } catch {
                        print("Error suggest Song")
                    }
                }
            }
            task.resume()
        }
    }
}
