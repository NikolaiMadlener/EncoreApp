//
//  AddSongView.swift
//  encoreApp
//
//  Created by Nikolai Madlener on 15.06.20.
//  Copyright © 2020 NikolaiEtienne. All rights reserved.
//

import SwiftUI

struct AddSongView: View {
    
    @State private var searchText : String = ""
    @State var userVM: UserVM
    @State var songs: [Song] = []
    typealias JSONStandard = [String : AnyObject]
    
    var body: some View {
        VStack {
            SearchBar(text: $searchText, userVM: $userVM, songs: $songs, placeholder: "Search songs")
            List {
                ForEach(songs.filter {
                    self.searchText.isEmpty ? true : $0.name.lowercased().contains(self.searchText.lowercased())
                }, id: \.self) { song in
                    Text(song.name)
                }
            }
        }
    }
}

struct SpotifySearchPayload: Codable {
    var tracks: TracksPayload?

    init(tracks: TracksPayload) {
        self.tracks = tracks
    }
}

struct TracksPayload: Codable {
    var href: String
    var items: [ItemPayload]
    var limit: Int
    var next: String
    var offset: Int
    var previous: String
    var total: Int

    init(href: String, items: [ItemPayload], limit: Int, next: String, offset: Int, previous: String, total: Int) {
        self.href = href
        self.items = items
        self.limit = limit
        self.next = next
        self.offset = offset
        self.previous = previous
        self.total = total
    }
}

struct ItemPayload: Codable {
    var album: AlbumPayload
    var artists: ArtistPayLoad
    var disc_number: Int
    var duration_ms: Int
    var explicit: Bool
    var external_ids: [String : String]
    var external_urls: [String : String]
    var href: String
    var id: String
    var is_local: Bool
    var is_playable: Bool
    var name: String
    var popularity: Int
    var preview_url: String
    var track_number: Int
    var type: String
    var uri: String

    init(album: AlbumPayload, artists: ArtistPayLoad, disc_number: Int, duration_ms: Int, explicit: Bool, external_ids: [String : String], external_urls: [String : String], href: String, id: String, is_local: Bool, is_playable: Bool, name: String, popularity: Int, preview_url: String, track_number: Int, type: String, uri: String) {
        self.album = album
        self.artists = artists
        self.disc_number = disc_number
        self.duration_ms = duration_ms
        self.explicit = explicit
        self.external_ids = external_ids
        self.external_urls = external_urls
        self.href = href
        self.id = id
        self.is_local = is_local
        self.is_playable = is_playable
        self.name = name
        self.popularity = popularity
        self.preview_url = preview_url
        self.track_number = track_number
        self.type = type
        self.uri = uri
    }
}

struct AlbumPayload: Codable {
    var album_type: String
    var artists: ArtistPayLoad
    var external_urls: [String : String]
    var href: String
    var id: String
    var images: [ImagePayload]
    var name: String
    var release_date: String
    var release_date_precision: String
    var total_tracks: Int
    var type: String
    var uri: String
    
    init(album_type: String, artists: ArtistPayLoad, external_urls: [String : String], href: String, id: String, images: [ImagePayload], name: String, release_date: String, release_date_precision: String, total_tracks: Int, type: String, uri: String) {
        self.album_type = album_type
        self.artists = artists
        self.external_urls = external_urls
        self.href = href
        self.id = id
        self.images = images
        self.name = name
        self.release_date = release_date
        self.release_date_precision = release_date_precision
        self.total_tracks = total_tracks
        self.type = type
        self.uri = uri
    }
}

struct ArtistPayLoad: Codable {
    var external_urls: [String : String]
    var href: String
    var id: String
    var name: String
    var type: String
    var uri: String
    
    init(external_urls: [String : String], href: String, id: String, name: String, type: String, uri: String) {
        self.external_urls = external_urls
        self.href = href
        self.id = id
        self.name = name
        self.type = type
        self.uri = uri
    }
}

struct ImagePayload: Codable {
    var height: Int
    var url: String
    var width: Int
    
    init(height: Int, url: String, width: Int) {
        self.height = height
        self.url = url
        self.width = width
    }
}



struct AddSongView_Previews: PreviewProvider {
    static var userVM = UserVM()
    static var previews: some View {
        AddSongView(userVM: userVM)
    }
}
