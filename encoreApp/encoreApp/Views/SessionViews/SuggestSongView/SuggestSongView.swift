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
            SearchBar(text: $searchText, songs: $networkModel.items, placeholder: "Search songs")
            List {
                ForEach(networkModel.items.filter {
                    self.searchText.isEmpty ? true : $0.name.lowercased().contains(self.searchText.lowercased())
                }, id: \.self) { song in
                    SuggestSongCell(song: song)
                }
            }
        }
    }
}

struct AddSongView_Previews: PreviewProvider {
    static var userVM = UserVM()
    static var previews: some View {
        SuggestSongView()
    }
}
