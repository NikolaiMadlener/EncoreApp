//
//  SuggestSongView.swift
//  encoreApp
//
//  Created by Nikolai Madlener on 15.06.20.
//  Copyright © 2020 NikolaiEtienne. All rights reserved.
//

import SwiftUI

struct SuggestSongView: View {
    @ObservedObject var networkModel: NetworkModel = .shared
    @State private var searchText : String = ""
    @State var songs: [Song] = []
    typealias JSONStandard = [String : AnyObject]
    
    var body: some View {
        VStack {
            SearchBar(text: $searchText, songs: $networkModel.items, placeholder: "Search songs").environmentObject(networkModel)
            List {
                ForEach(networkModel.items.filter {
                    self.searchText.isEmpty ? true : $0.name.lowercased().contains(self.searchText.lowercased())
                }, id: \.self) { song in
                    Text(song.name)
                }
            }
        }
    }
}

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
        let href: String
    }
    let tracks: Tracks
}



struct AddSongView_Previews: PreviewProvider {
    static var userVM = UserVM()
    static var previews: some View {
        SuggestSongView()
    }
}
