//
//  SuggestSongView.swift
//  encoreApp
//
//  Created by Nikolai Madlener on 15.06.20.
//  Copyright © 2020 NikolaiEtienne. All rights reserved.
//

import SwiftUI

struct SuggestSongView: View {
    @ObservedObject var searchResultListVM: SearchResultListVM
    @ObservedObject var userVM: UserVM
    @State private var searchText : String = ""
    //@State var songs: [Song] = []
    typealias JSONStandard = [String : AnyObject]
    
    var body: some View {
        VStack {
            SearchBar(searchResultListVM: searchResultListVM, userVM: userVM, text: $searchText, songs: $searchResultListVM.items, placeholder: "Search songs")
            List {
                ForEach(searchResultListVM.items, id: \.self) { song in
                    SuggestSongCell(searchResultListVM: self.searchResultListVM, song: song)
                }
            }
        }
    }
}

struct AddSongView_Previews: PreviewProvider {
    static var userVM = UserVM()
    static var searchResultListVM = SearchResultListVM(userVM: userVM)
    static var previews: some View {
        SuggestSongView(searchResultListVM: searchResultListVM, userVM: userVM)
    }
}
