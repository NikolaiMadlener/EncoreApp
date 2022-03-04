//
//  SuggestSongView.swift
//  encoreApp
//
//  Created by Nikolai Madlener on 15.06.20.
//  Copyright © 2020 NikolaiEtienne. All rights reserved.
//

import SwiftUI

struct SuggestSongView: View {
    @StateObject var viewModel: ViewModel
    
    var body: some View {
        VStack(spacing: 0) {
            topBar.padding(.vertical)
            SearchBar(viewModel: .init(items: $viewModel.items),
                      text: $viewModel.searchText,
                      songs: $viewModel.items,
                      placeholder: "Search").background(Color(uiColor: UIColor.systemGray6))
            if viewModel.items.isEmpty {
                VStack(alignment: .center) {
                    Spacer()
                    Group {
                        Text("find your favourite songs by ")
                        Text("artist, album or title.")
                    }.font(.system(size: 18, weight: .semibold))
                        .foregroundColor(Color("purpleblue"))
                        .padding(.horizontal)
                        .padding(.vertical, 2)
                    Spacer()
                    Spacer()
                }
            } else {
                List {
                    ForEach(viewModel.items, id: \.self) { song in
                        SuggestSongCell(viewModel: .init(song: song))
                            .frame(height: 60)
                    }
                }.alert(isPresented: self.$viewModel.showSessionExpiredAlert) {
                    Alert(title: Text("Session expired"),
                          message: Text("The host has ended the session."),
                          dismissButton: .destructive(Text("Leave"), action: {
                        self.viewModel.currentlyInSession = false
                    }))
                }.edgesIgnoringSafeArea(.all)
            }
        }.background(Color(uiColor: UIColor.systemGray6))
    }
    
    var topBar: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 6)
                .fill(Color.secondary)
                .frame(width: 60, height: 4)
        }
    }
}

struct AddSongView_Previews: PreviewProvider {
    
    static var previews: some View {
        SuggestSongView(viewModel: .init())
    }
}
