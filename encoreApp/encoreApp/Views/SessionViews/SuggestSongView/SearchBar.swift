//
//  SearchBar.swift
//  encoreApp
//
//  Created by Etienne Köhler on 20.06.20.
//  Copyright © 2020 NikolaiEtienne. All rights reserved.
//

import Foundation
import SwiftUI
import UIKit

struct SearchBar: UIViewRepresentable {
    @ObservedObject var searchResultListVM: SearchResultListVM
    @ObservedObject var userVM: UserVM
    @Binding var text: String
    @Binding var songs: [SpotifySearchPayload.Tracks.Item]
    var placeholder: String
    
    class Coordinator: NSObject, UISearchBarDelegate {
        @ObservedObject var searchResultListVM: SearchResultListVM
        @ObservedObject var userVM: UserVM
        @Binding var text: String
        @Binding var songs: [SpotifySearchPayload.Tracks.Item]
        
        init(searchResultListVM: SearchResultListVM, userVM: UserVM, text: Binding<String>, songs: Binding<[SpotifySearchPayload.Tracks.Item]>) {
            self.searchResultListVM = searchResultListVM
            self.userVM = userVM
            _text = text
            _songs = songs
        }
        
        func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
            text = searchText
            searchResultListVM.searchSong(query: self.text)
        }
        
        
    }
    
    func makeCoordinator() -> SearchBar.Coordinator {
        return Coordinator(searchResultListVM: searchResultListVM, userVM: userVM, text: $text, songs: $songs)
    }
    
    func makeUIView(context: UIViewRepresentableContext<SearchBar>) -> UISearchBar {
        let searchBar = UISearchBar(frame: .zero)
        searchBar.delegate = context.coordinator
        searchBar.searchBarStyle = .minimal
        searchBar.autocapitalizationType = .none
        searchBar.placeholder = placeholder
        return searchBar
    }
    
    func updateUIView(_ uiView: UISearchBar, context: UIViewRepresentableContext<SearchBar>) {
        uiView.text = text
    }
}

