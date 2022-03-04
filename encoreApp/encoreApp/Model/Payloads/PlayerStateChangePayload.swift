//
//  PlayerStateChangePayload.swift
//  encoreApp
//
//  Created by Nikolai Madlener on 04.03.22.
//  Copyright © 2022 NikolaiEtienne. All rights reserved.
//

import Foundation

struct PlayerStateChangePayload: Codable, Hashable {
    var current_song: Song?
    var is_playing: Bool
    var progress: Int64
    var timestamp: String

    init(current_song: Song?, is_playing: Bool, progress: Int64, timestamp: String) {
        self.current_song = current_song
        self.is_playing = is_playing
        self.progress = progress
        self.timestamp = timestamp
    }
}
