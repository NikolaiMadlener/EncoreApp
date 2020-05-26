//
//  Mockmodel.swift
//  encoreApp
//
//  Created by Nikolai Madlener on 26.05.20.
//  Copyright © 2020 NikolaiEtienne. All rights reserved.
//

import Foundation

class Mockmodel {
    static func getSongs() -> [Song] {
        var songList = [
            Song(id: UUID(), name: "Alle meine Entchen", artists: ["Etienne"], duration_ms: 123, cover_url: "", album_name: "Kinderlieder", preview_url: "", suggested_by: "", score: 3, time_added: 1, upvoters: ["Niko"], downvoters: []),
            Song(id: UUID(), name: "Abkfjkö", artists: ["Etienne"], duration_ms: 123, cover_url: "", album_name: "Kinderlieder", preview_url: "", suggested_by: "", score: 3, time_added: 1, upvoters: [], downvoters: []),
            Song(id: UUID(), name: "jjfalksdfg", artists: ["Etienne"], duration_ms: 123, cover_url: "", album_name: "Kinderlieder", preview_url: "", suggested_by: "", score: 3, time_added: 1, upvoters: [], downvoters: []),
            Song(id: UUID(), name: "kjaosighoi", artists: ["Etienne"], duration_ms: 123, cover_url: "", album_name: "Kinderlieder", preview_url: "", suggested_by: "", score: 3, time_added: 1, upvoters: [], downvoters: []),
            Song(id: UUID(), name: "Alle meine ", artists: ["Etienne"], duration_ms: 123, cover_url: "", album_name: "Kinderlieder", preview_url: "", suggested_by: "", score: 3, time_added: 1, upvoters: [], downvoters: []),
            Song(id: UUID(), name: "Alle Entchen", artists: ["Etienne"], duration_ms: 123, cover_url: "", album_name: "Kinderlieder", preview_url: "", suggested_by: "", score: 3, time_added: 1, upvoters: [], downvoters: [])
            
        ]
        return songList
    }
}
