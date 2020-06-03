//
//  HomeView.swift
//  encoreApp
//
//  Created by Nikolai Madlener on 26.05.20.
//  Copyright © 2020 NikolaiEtienne. All rights reserved.
//

import SwiftUI

struct HomeView: View {
    
    @ObservedObject var model: Model = .shared
    @State var presentMenuSheet = false
    @Binding var currentlyInSession: Bool
    @Binding var sessionID: String
    @State var current_title_offset: CGFloat = 200
    
    var body: some View {
        ZStack {
            //Layer 0: Background Layer
            LinearGradient(gradient: Gradient(colors: [
                Color.white,
                Color.white,
                Color.white
            ]), startPoint: .top, endPoint: .bottom).edgesIgnoringSafeArea(.all)
            
            //Layer 1: Song Queue Layer
            songQueue_layer
            
            //Layer 2: Menu Layer
            menu_layer
            
            //Layer 3: Song Title Layer
            songTitle_layer
            
            //Layer4: Observer Layer (Debugging)
//            VStack {
//                Text("\(current_title_offset)")
//                    .foregroundColor(Color.yellow)
//                Spacer()
//            }
        }
    }
    
    //Layer 1: Song Queue Layer
    private var songQueue_layer: some View {
        ScrollView {
            GeometryReader { geo -> AnyView? in
                let thisOffset = geo.frame(in: .global).minY
                if thisOffset > -260 {
                    self.current_title_offset = thisOffset
                } else {
                    self.current_title_offset = -260
                }
                return nil
            }
            VStack {
                HStack {
                    Spacer()    //Spacer for Album Cover Layer
                        .frame(height: 400)
                }
                VStack {
                    ForEach(model.queue, id: \.self) { song in
                        VStack {
                            SongListCell(song: song, rank: (self.model.queue.firstIndex(of: song) ?? -1) + 1)
                            Divider()
                        }
                    }
                }.animation(.easeInOut(duration: 0.30))
            }.background(Color.clear)
        }
    }
    
    //Layer 2: Menu Layer
    private var menu_layer: some View {
        VStack {
            HStack {
                Spacer()
                Button(action: { self.presentMenuSheet = true }) {
                    Image(systemName: "ellipsis")
                        .font(Font.system(.title))
                        .foregroundColor(Color.black)
                }.padding()
                    .sheet(isPresented: self.$presentMenuSheet) {
                        MenuView(currentlyInSession: self.$currentlyInSession, sessionID: self.$sessionID)
                }
            }
            Spacer()
        }
    }

    //Layer 3: Song Title Layer
    private var songTitle_layer: some View {
        VStack {
            Spacer()
                .frame(height: current_title_offset + 50)
            
            HStack {
                if (current_title_offset > -260) {
                    VStack {
                        Image("album1")
                            .resizable()
                            .frame(width: 200, height: 200)
                        Text("\(model.getSongPlaying().name)")
                            .font(.system(size: 25, weight: .bold))
                        Text("\(model.getSongPlaying().artists[0])")
                            .font(.system(size: 20, weight: .semibold))
                    }
                } else {
                    VStack {
                        Spacer()
                            .frame(height: 210)
                        Text("\(model.getSongPlaying().name)")
                            .font(.system(size: 25, weight: .bold))
                        Text("\(model.getSongPlaying().artists[0])")
                            .font(.system(size: 20, weight: .semibold))
                        Spacer()
                    }
                }
            }
            Spacer()
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
