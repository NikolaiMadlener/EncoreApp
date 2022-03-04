//
//  Player.swift
//  encoreApp
//
//  Created by Nikolai Madlener on 04.03.22.
//  Copyright © 2022 NikolaiEtienne. All rights reserved.
//

import Foundation
import SwiftUI

struct Player {
    var song: Song
    var progress: Int64
    var isPlaying: Bool
    var normalizedPlaybackPosition: CGFloat
    var albumCover: UIImage
    var songTimestamp_ms: CGFloat
    
    init() {
        song = Song()
        progress = 0
        isPlaying = false
        normalizedPlaybackPosition = 0
        albumCover = UIImage(imageLiteralResourceName: "IconPlaceholder")
        songTimestamp_ms = 0
    }
}
