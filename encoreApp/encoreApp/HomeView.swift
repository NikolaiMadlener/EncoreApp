//
//  HomeView.swift
//  encoreApp
//
//  Created by Nikolai Madlener on 26.05.20.
//  Copyright © 2020 NikolaiEtienne. All rights reserved.
//

import SwiftUI

struct HomeView: View {
    
    @Environment(\.colorScheme) var colorScheme
    
    @ObservedObject var model: Model = .shared
    @State var presentMenuSheet = false
    @Binding var currentlyInSession: Bool
    @Binding var sessionID: String
    @State var current_title_offset: CGFloat = 200
    
    var body: some View {
        ZStack {
            //Layer 0: Background Layer
//            LinearGradient(gradient: Gradient(colors: [
//                Color.white,
//                Color.white,
//                Color.white
//            ]), startPoint: .top, endPoint: .bottom).edgesIgnoringSafeArea(.all)
            
            //Layer 1: Song Queue Layer
            songQueue_layer
            
            //Layer 2: Song Title Layer
            songTitle_layer
            
            //Layer 3: Menu Layer
            menu_layer
            
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
                if thisOffset > -190 {
                    self.current_title_offset = thisOffset
                } else {
                    self.current_title_offset = -260
                }
                return nil
            }
            VStack {
                HStack {
                    Spacer()    //Spacer for Album Cover Layer
                        .frame(height: 320)
                }
                VStack {
                    ForEach(model.queue, id: \.self) { song in
                        VStack {
                            SongListCell(song: song, rank: (self.model.queue.firstIndex(of: song) ?? -1) + 1)
                            Divider()
                                .padding(.horizontal)
                                .padding(.top, -5)
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
                        .foregroundColor(self.colorScheme == .dark ? Color.white : Color.black)
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
        GeometryReader { geo in
            VStack {
                Spacer()
                    .frame(height: self.current_title_offset)
                
                HStack {
                    if (self.current_title_offset > -260) {
                        VStack {
                            Image("album1")
                                .resizable()
                                .frame(width: 180, height: 180)
                            Text("\(self.model.getSongPlaying().name)")
                                .font(.system(size: 25, weight: .bold))
                            Text("\(self.model.getSongPlaying().artists[0])")
                                .font(.system(size: 20, weight: .semibold))
                        }
                    } else {
                        VStack(alignment: .leading) {
                            Spacer().frame(height: 260)
                            ZStack(alignment: .top) {
                                Rectangle()
                                    .frame(width: geo.size.width, height: 120)
                                    .foregroundColor(Color.clear)
                                    .background(Blur(colorScheme: self.colorScheme))
                                    .edgesIgnoringSafeArea(.top)
                                HStack {
                                    Image("album1")
                                        .resizable()
                                        .frame(width: 40, height: 40)
                                    VStack(alignment: .leading) {
                                        Text("\(self.model.getSongPlaying().name)")
                                            .font(.system(size: 20, weight: .bold))
                                        Text("\(self.model.getSongPlaying().artists[0])")
                                            .font(.system(size: 15, weight: .semibold))
                                    }
                                    Spacer()
                                    }.padding()
                            }
                            Spacer()
                        }
                    }
                }
                Spacer()
            }
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
