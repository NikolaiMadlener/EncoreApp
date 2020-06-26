//
//  Mockmodel.swift
//  encoreApp
//
//  Created by Nikolai Madlener on 26.05.20.
//  Copyright © 2020 NikolaiEtienne. All rights reserved.
//

import Foundation
import Combine
import SwiftUI

class Mockmodel {
    
    static func getSongs() -> [Song] {
        
        var songList = [
            Song(id: "1", name: "Alle meine Entchen", artists: ["Etienne"], duration_ms: 123, cover_url: "", album_name: "Kinderlieder", preview_url: "", suggested_by: "", score: 3, time_added: "1", upvoters: ["Niko", "Etienne", "Bob", "James"], downvoters: []),
            Song(id: "2", name: "Abkfjkö", artists: ["Etienne"], duration_ms: 123, cover_url: "", album_name: "Kinderlieder", preview_url: "", suggested_by: "", score: 3, time_added: "1", upvoters: ["Niko", "Etienne"], downvoters: []),
            Song(id: "3", name: "jjfalksdfg", artists: ["Etienne"], duration_ms: 123, cover_url: "", album_name: "Kinderlieder", preview_url: "", suggested_by: "", score: 3, time_added: "1", upvoters: ["Niko", "Etienne"], downvoters: []),
            Song(id: "4", name: "kjaosighoi", artists: ["Etienne"], duration_ms: 123, cover_url: "", album_name: "Kinderlieder", preview_url: "", suggested_by: "", score: 3, time_added: "1", upvoters: [], downvoters: []),
            Song(id: "5", name: "Alle meine ", artists: ["Etienne"], duration_ms: 123, cover_url: "", album_name: "Kinderlieder", preview_url: "", suggested_by: "", score: 3, time_added: "1", upvoters: [], downvoters: ["Niko"])]

        return songList
    }
    
    static func getSongPayload() -> SpotifySearchPayload.Tracks.Item {
        SpotifySearchPayload.Tracks.Item(
                    album: SpotifySearchPayload.Tracks.Item.Album(
                        id: "6akEvsycLGftJxYudPjmqK",
                        images: [SpotifySearchPayload.Tracks.Item.Album.ImageSpotify(
                            height: 300,
                            url: "https://i.scdn.co/image/ab67616d00001e021ae2bdc1378da1b440e1f610",
                            width: 300)],
                        name: "Place In The Sun"),
                    artists: [SpotifySearchPayload.Tracks.Item.Artists(
                        id: "08td7MxkoHQkXnWAYD8d6Q",
                        name: "Tania Bowra")],
                    id: "5cBLGuA6AFlZISzkRiE7IT",
                    name: "Sympathy")
    }
}

