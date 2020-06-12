//
//  Song.swift
//  encoreApp
//
//  Created by Nikolai Madlener on 26.05.20.
//  Copyright © 2020 NikolaiEtienne. All rights reserved.
//

import Foundation
import SwiftUI

class Song: Hashable, ObservableObject {
    
    static func == (lhs: Song, rhs: Song) -> Bool {
        if lhs.id != rhs.id {
            return false
        } else {
            return true
        }
    }

    var id: UUID
    var name: String
    var artists: [String]
    var duration_ms: Int
    var cover_url: String
    var album_name: String
    var preview_url: String
    var suggested_by: String
    var score: Int
    var time_added: Int
    @Published var upvoters: [String]
    @Published var downvoters: [String]
    var album_image: Image   //temporary, can be deleted ounce we get images from spotify api
    var hashValue: Int {
         return id.hashValue
    }
    
    init(id: UUID,
        name: String,
        artists: [String],
        duration_ms: Int,
        cover_url: String,
        album_name: String,
        preview_url: String,
        suggested_by: String,
        score: Int,
        time_added: Int,
        upvoters: [String], //later User
        downvoters: [String],
        album_image: Image) {
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
        self.album_image = album_image
    }
}

struct Song_Previews: PreviewProvider {
    static var previews: some View {
        /*@START_MENU_TOKEN@*/Text("Hello, World!")/*@END_MENU_TOKEN@*/
    }
}
