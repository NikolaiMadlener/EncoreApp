//
//  Song.swift
//  encoreApp
//
//  Created by Nikolai Madlener on 26.05.20.
//  Copyright © 2020 NikolaiEtienne. All rights reserved.
//

import Foundation
import SwiftUI

struct Song: Codable, Hashable, Identifiable {

    var id: String
    var name: String
    var artists: [String]
    var duration_ms: Int
    var cover_url: String
    var album_name: String
    var preview_url: String
    var suggested_by: String
    var score: Int
    var time_added: String
    var upvoters: [String]
    var downvoters: [String]
    
//    "id": "7unF2ARDGldwWxZWCmlwDM",
//    "name": "A Love Supreme, Pt. II - Resolution",
//    "artists": ["list", "of", "artists"],
//    "duration_ms": 1337,
//    "cover_url": "https://i.scdn.co/image/ab67616d0000b2737fe4eca2f931b806a9c9a9dc",
//    "album_name": "A Love Supreme",
//    "preview_url": "url to 30 second song preview",
//    "suggested_by": "anton",
//    "score": 3,
//    "time_added": "time string",
//    "upvoters": ["omar", "cybotter", "anton"],
//    "downvoters": []
    
    init(id: String,
        name: String,
        artists: [String],
        duration_ms: Int,
        cover_url: String,
        album_name: String,
        preview_url: String,
        suggested_by: String,
        score: Int,
        time_added: String,
        upvoters: [String],
        downvoters: [String]) {
        self.id = id
        self.name = name
        self.artists = artists
        self.duration_ms = duration_ms
        self.cover_url = cover_url
        self.album_name = album_name
        self.preview_url = preview_url
        self.suggested_by = suggested_by
        self.score = score
        self.time_added = time_added
        self.upvoters = upvoters
        self.downvoters = downvoters
    }
}


