//
//  PlayerStateVM.swift
//  encoreApp
//
//  Created by Nikolai Madlener on 17.06.20.
//  Copyright © 2020 NikolaiEtienne. All rights reserved.
//

import Foundation
import IKEventSource

class PlayerStateVM: ObservableObject {
    @Published var song: Song
    var serverURL: URL
    var userVM: UserVM
    var eventSource: EventSource
    
    init(userVM: UserVM) {
        song = Song(id: "1", name: "Alle meine Entchen", artists: ["Etienne"], duration_ms: 123, cover_url: "", album_name: "Kinderlieder", preview_url: "", suggested_by: "", score: 3, time_added: "1", upvoters: ["Niko", "Etienne", "Bob", "James"], downvoters: [])
        
        self.userVM = userVM
        
        serverURL = URL(string: "https://api.encore-fm.com/events/"+"\(userVM.username)"+"/\(userVM.sessionID)")!
        eventSource = EventSource(url: serverURL)
        
        eventSource.connect()
        
        eventSource.addEventListener("sse:player_state_change") { [weak self] id, event, dataString in
            print("eventListener Data:" + "(dataString)")
            // Convert HTTP Response Data to a String
            if let dataString = dataString {
                let data: Data? = dataString.data(using: .utf8)
                if let data = data {
                    do {
                        let decodedData = try JSONDecoder().decode(Song.self, from: data)
                        DispatchQueue.main.async {
                            print("Update Player State")
                            print(decodedData)
                            
                            //self?.song = decodedData.current_song
                        }
                    } catch {
                        print("Error SSE player_state_change ")
                        
                    }
                }
            }
        }
    }
}

struct PlayerStateChangePayload: Codable, Hashable {
    var current_song: Song
    var is_playing: Bool
    var progress: Int64
    var timestamp: Float

    init(current_song: Song, is_playing: Bool, progress: Int64, timestamp: Float) {
        self.current_song = current_song
        self.is_playing = is_playing
        self.progress = progress
        self.timestamp = timestamp
    }
}
