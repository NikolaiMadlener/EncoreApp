//
//  HomeView.swift
//  encoreApp
//
//  Created by Nikolai Madlener on 26.05.20.
//  Copyright © 2020 NikolaiEtienne. All rights reserved.
//

import SwiftUI

struct HomeView: View {
    var songsList: [Song] = Mockmodel.getSongs()
    @Binding var currentlyInSession: Bool
    @State var presentMenuSheet = false
    @Binding var sessionID: String
    
    var body: some View {
        ZStack {
            VStack {
                HStack {
                    Spacer()
                    Button(action: { self.presentMenuSheet = true }) {
                        Image(systemName: "ellipsis").font(Font.system(.title))
                    }.padding()
                        .sheet(isPresented: self.$presentMenuSheet) {
                            MenuView(currentlyInSession: self.$currentlyInSession, sessionID: self.$sessionID)
                    }
                }
                Spacer()
            }
            ScrollView {
                VStack {
                    ForEach(songsList, id: \.self) { song in
                        SongListCell(song: song)
                    }
                }
            }.padding(.top, 50)
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    @State static var currentlyInSession = true
    @State static var sessionID = ""
    
    static var previews: some View {
        HomeView(currentlyInSession: $currentlyInSession, sessionID: $sessionID)
    }
}
