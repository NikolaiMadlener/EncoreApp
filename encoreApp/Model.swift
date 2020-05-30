//
//  Model.swift
//  encoreApp
//
//  Created by Etienne Köhler on 28.05.20.
//  Copyright © 2020 NikolaiEtienne. All rights reserved.
//

import Foundation
import SwiftUI

public class Model: ObservableObject {
    
    static let shared = Model()
    
    @Published var song_playing: Song
    @Published var queue: [Song]
    
    init() {
        self.song_playing = Mockmodel.getSongs()[0]
        self.queue = Mockmodel.getSongs()
    }
    
    func getQueue() -> [Song] {
        let queueSorted = queue.sorted {
            $0.upvoters.count - $0.downvoters.count > $1.upvoters.count - $1.downvoters.count
        }
        return queueSorted
    }
    
    func upvote(song: Song, username: String) {
        getSong(id: song.id)?.upvoters.append(username)
        sortQueue()
    }
    
    func downvote(song: Song, username: String) {
        getSong(id: song.id)?.downvoters.append(username)
        sortQueue()
    }
    
    func sortQueue() {
        let queueSorted = queue.sorted {
            $0.upvoters.count - $0.downvoters.count > $1.upvoters.count - $1.downvoters.count
        }
        self.queue = queueSorted
    }
    
    func getSong(id: UUID) -> Song? {
        guard let song = queue.first(where: { $0.id == id }) else {
            print("No song found with that id")
            return nil
        }
        return song
    }
    
    func getSongPlaying() -> Song {
        return song_playing
    }
}
