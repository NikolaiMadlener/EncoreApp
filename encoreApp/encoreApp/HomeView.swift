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
            songTitleBar_layer
            
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
    
    //MARK: Layer 1: Song Queue Layer
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
                songTitle
                
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
                    .offset(CGSize(width: 0, height: 300))
            }.background(Color.clear)
        }
    }
    
    private var songTitle: some View {
        GeometryReader { geo in
            VStack {
                HStack {
                    Spacer()
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
                        Spacer()
                    }
                }
                
                // later this will be the playbar
                HStack(spacing: 0) {
                    Rectangle()
                        .frame(width: geo.size.width * 0.5, height: 3)
                        .foregroundColor(Color("purpleblue"))
                    Rectangle()
                        .frame(width: geo.size.width * 0.3, height: 3)
                        .foregroundColor(self.colorScheme == .dark ? Color("darkgray") : Color.gray)
                }.padding()
                
                Spacer()
            }
        }
    }
    
    //MARK: Layer 2: Song Title Bar Layer
    private var songTitleBar_layer: some View {
        GeometryReader { geo in
            if (self.current_title_offset <= -260) {
                VStack(alignment: .leading) {
                    ZStack(alignment: .top) {
                        VStack(spacing: 0) {
                            Rectangle()
                                .frame(width: geo.size.width, height: geo.size.height * 0.13)
                                .foregroundColor(Color.clear)
                                .background(Blur(colorScheme: self.colorScheme))
                            
                            // later this will be the playbar
                            HStack(spacing: 0) {
                                Rectangle()
                                    .frame(width: geo.size.width * (2/3), height: 3)
                                    .foregroundColor(Color("purpleblue"))
                                Rectangle()
                                    .frame(width: geo.size.width * (1/3), height: 3)
                                    .foregroundColor(self.colorScheme == .dark ? Color("darkgray") : Color.gray)
                            }
                            
                        }.edgesIgnoringSafeArea(.top)
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
                Spacer()
            }
        }
    }
    
    //MARK: Layer 3: Menu Layer
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
}

struct HomeView_Previews: PreviewProvider {
    @State static var currentlyInSession = true
    @State static var sessionID = ""
    
    static var previews: some View {
        HomeView(currentlyInSession: $currentlyInSession, sessionID: $sessionID)
    }
}
