//
//  HomeView.swift
//  encoreApp
//
//  Created by Nikolai Madlener on 26.05.20.
//  Copyright © 2020 NikolaiEtienne. All rights reserved.
//

import SwiftUI

struct HomeView: View {
    @ObservedObject var user: User
    @ObservedObject var model: Model = .shared
    @State var presentMenuSheet = false
    @Binding var currentlyInSession: Bool
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
                            MenuView(user: self.user, currentlyInSession: self.$currentlyInSession, sessionID: self.$sessionID)
                    }
                }
                Spacer()
            }
            ScrollView {
                ForEach(model.queue, id: \.self) { song in
                    VStack {
                        SongListCell(song: song, rank: (self.model.queue.firstIndex(of: song) ?? -1) + 1)
                        Divider()
                    }
                }.animation(.easeInOut(duration: 0.30))
            }.padding(.top, 50)
        }.onAppear{ print("onAppear: " + self.user.username) }
    }
}

struct HomeView_Previews: PreviewProvider {
    @State static var currentlyInSession = true
    @State static var sessionID = ""
    static var user = User()
    
    static var previews: some View {
        HomeView(user: user, currentlyInSession: $currentlyInSession, sessionID: $sessionID)
    }
}
