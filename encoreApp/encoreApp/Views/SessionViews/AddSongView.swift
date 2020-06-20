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
    
    var body: some View {
        VStack {
            SearchBar(text: $searchText, placeholder: "Search songs")
            List {
                ForEach(Mockmodel.getSongs().filter {
                    self.searchText.isEmpty ? true : $0.name.lowercased().contains(self.searchText.lowercased())
                }, id: \.self) { song in
                    Text(song.name)
                }
            }
        }
    }
}

struct AddSongView_Previews: PreviewProvider {
    static var previews: some View {
        AddSongView()
    }
}
