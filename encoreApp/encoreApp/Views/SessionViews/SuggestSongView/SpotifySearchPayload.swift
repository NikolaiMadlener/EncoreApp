//
//  SpotifySearchPayload.swift
//  encoreApp
//
//  Created by Etienne Köhler on 26.06.20.
//  Copyright © 2020 NikolaiEtienne. All rights reserved.
//

import Foundation

struct SpotifySearchPayload: Codable {
    struct Tracks: Codable {
        struct Item: Codable, Hashable {
            struct Album: Codable, Hashable {
                struct ImageSpotify: Codable, Hashable {
                    let height: Int
                    let url: String
                    let width: Int
                }
                let id: String
                let images: [ImageSpotify]
                let name: String
                
            }
            struct Artists: Codable, Hashable {
                let id: String
                let name: String
            }
            let album: Album
            let artists: [Artists]
            let id: String
            let name: String
        }
        let items: [Item]
    }
    let tracks: Tracks
}
