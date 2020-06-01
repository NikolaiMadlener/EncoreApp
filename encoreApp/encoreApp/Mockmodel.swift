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
            Song(id: UUID(), name: "Alle meine Entchen", artists: ["Etienne"], duration_ms: 123, cover_url: "", album_name: "Kinderlieder", preview_url: "", suggested_by: "", score: 3, time_added: 1, upvoters: ["Niko", "Etienne", "Bob", "James"], downvoters: [], album_image: Image("album1")),
            Song(id: UUID(), name: "Abkfjkö", artists: ["Etienne"], duration_ms: 123, cover_url: "", album_name: "Kinderlieder", preview_url: "", suggested_by: "", score: 3, time_added: 1, upvoters: ["Niko", "Etienne"], downvoters: [], album_image: Image("album2")),
            Song(id: UUID(), name: "jjfalksdfg", artists: ["Etienne"], duration_ms: 123, cover_url: "", album_name: "Kinderlieder", preview_url: "", suggested_by: "", score: 3, time_added: 1, upvoters: ["Niko", "Etienne"], downvoters: [], album_image: Image("album3")),
            Song(id: UUID(), name: "kjaosighoi", artists: ["Etienne"], duration_ms: 123, cover_url: "", album_name: "Kinderlieder", preview_url: "", suggested_by: "", score: 3, time_added: 1, upvoters: [], downvoters: [], album_image: Image("album4")),
            Song(id: UUID(), name: "Alle meine ", artists: ["Etienne"], duration_ms: 123, cover_url: "", album_name: "Kinderlieder", preview_url: "", suggested_by: "", score: 3, time_added: 1, upvoters: [], downvoters: ["Niko"], album_image: Image("album5")),
            Song(id: UUID(), name: "Alle Entchen", artists: ["Etienne"], duration_ms: 123, cover_url: "", album_name: "Kinderlieder", preview_url: "", suggested_by: "", score: 3, time_added: 1, upvoters: [], downvoters: ["Niko", "Etienne", "Bob", "James"], album_image: Image("album6")),
            Song(id: UUID(), name: "Alle meine Entchen", artists: ["Etienne"], duration_ms: 123, cover_url: "", album_name: "Kinderlieder", preview_url: "", suggested_by: "", score: 3, time_added: 1, upvoters: ["Niko", "Etienne", "Bob", "James"], downvoters: [], album_image: Image("album6")),
            Song(id: UUID(), name: "Abkfjkö", artists: ["Etienne"], duration_ms: 123, cover_url: "", album_name: "Kinderlieder", preview_url: "", suggested_by: "", score: 3, time_added: 1, upvoters: ["Niko", "Etienne"], downvoters: [], album_image: Image("album2")),
            Song(id: UUID(), name: "jjfalksdfg", artists: ["Etienne"], duration_ms: 123, cover_url: "", album_name: "Kinderlieder", preview_url: "", suggested_by: "", score: 3, time_added: 1, upvoters: ["Niko", "Etienne"], downvoters: [], album_image: Image("album3")),
            Song(id: UUID(), name: "kjaosighoi", artists: ["Etienne"], duration_ms: 123, cover_url: "", album_name: "Kinderlieder", preview_url: "", suggested_by: "", score: 3, time_added: 1, upvoters: [], downvoters: [], album_image: Image("album4")),
            Song(id: UUID(), name: "Alle meine ", artists: ["Etienne"], duration_ms: 123, cover_url: "", album_name: "Kinderlieder", preview_url: "", suggested_by: "", score: 3, time_added: 1, upvoters: [], downvoters: ["Niko"], album_image: Image("album5")),
            Song(id: UUID(), name: "Alle Entchen", artists: ["Etienne"], duration_ms: 123, cover_url: "", album_name: "Kinderlieder", preview_url: "", suggested_by: "", score: 3, time_added: 1, upvoters: [], downvoters: ["Niko", "Etienne", "Bob", "James"], album_image: Image("album6"))
            
        ]
        return songList
    }
}
