//
//  File.swift
//  encoreApp
//
//  Created by Etienne Köhler on 28.05.20.
//  Copyright © 2020 NikolaiEtienne. All rights reserved.
//

import Foundation
import SwiftUI

public class Model {
    
    @Published private var song_playing: Song
    @Published private var queue: [Song]
    
    init(song_playing: Song, queue: [Song]) {
        self.song_playing = song_playing
        self.queue = Mockmodel.getSongs()
    }
    
    func getQueue() -> [Song] {
        let queueSorted = queue.sorted {
            $0.upvoters.count - $0.downvoters.count > $1.upvoters.count - $1.downvoters.count
        }
        return queueSorted
    }
    
    func getSongPlaying() -> Song {
        return song_playing
    }
}

extension Model: ObservableObject { }
