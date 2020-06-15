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
    @ObservedObject var musicController: MusicController = .shared
    
    @ObservedObject var user: User
    @State var presentMenuSheet = false
    @State var showAddSongSheet = false
    @Binding var currentlyInSession: Bool
    @State var current_title_offset: CGFloat = 0
    @State var isPlay = false
    
    
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
        }.onAppear{ self.musicController.viewDidLoad() }
    }

    
    //MARK: Layer 1: Song Queue Layer
    private var songQueue_layer: some View {
        GeometryReader { geom in
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
                if (self.current_title_offset > -260) {
                    VStack {
                        HStack {
                            Spacer()
                            VStack {
                                self.musicController.currentAlbumImage
                                    .resizable()
                                    .frame(width: 180, height: 180)
                                Text("\(self.musicController.trackName ?? "No Song")")
                                    .font(.system(size: 25, weight: .bold))
                                Text("\(self.musicController.artistName ?? "No Artist")")
                                    .font(.system(size: 20, weight: .semibold))
                            }
                            Spacer()
                        }
                        
                        // later this will be the playbar
                        ZStack(alignment: .leading) {
                            Rectangle()
                                .frame(width: geom.size.width * 0.8, height: 3)
                                .foregroundColor(self.colorScheme == .dark ? Color("darkgray") : Color.gray)
                            Rectangle()
                                .frame(width: (self.musicController.normalizedPlaybackPosition! * geom.size.width * 0.8), height: 3)
                            .foregroundColor(Color("purpleblue"))
                        }.padding()
                        
                        Spacer()
                    }
                }
                
                VStack {
                    if (self.current_title_offset <= -260) {
                        Spacer().frame(height: 300)
                    }
                    ForEach(self.model.queue, id: \.self) { song in
                        VStack {
                            SongListCell(song: song, rank: (self.model.queue.firstIndex(of: song) ?? -1) + 1)
                            Divider()
                                .padding(.horizontal)
                                .padding(.top, -5)
                        }
                    }
                    Spacer().frame(height: 100)
                }.animation(.easeInOut(duration: 0.30))
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
                                //.background(Blur(colorScheme: self.colorScheme))
                                .background(self.colorScheme == .dark ? Color(.black) : Color(.white))
                            // later this will be the playbar
                            ZStack(alignment: .leading) {
                                Rectangle()
                                    .frame(width: geo.size.width, height: 3)
                                    .foregroundColor(self.colorScheme == .dark ? Color("darkgray") : Color.gray)
                                Rectangle()
                                    .frame(width: (self.musicController.normalizedPlaybackPosition! * geo.size.width), height: 3)
                                .foregroundColor(Color("purpleblue"))
                            }
                            
                        }.edgesIgnoringSafeArea(.top)
                        HStack {
                            self.musicController.currentAlbumImage
                                .resizable()
                                .frame(width: 30, height: 30)
                            VStack(alignment: .leading) {
                                Text("\(self.musicController.trackName ?? "No Song")")
                                    .font(.system(size: 15, weight: .bold))
                                Text("\(self.musicController.artistName ?? "No Artist")")
                                    .font(.system(size: 10, weight: .semibold))
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
                        MenuView(user: self.user, currentlyInSession: self.$currentlyInSession)
                }
            }
            Spacer()
            
            HStack {
                Spacer()
                if self.user.isAdmin {
                    HStack {
                        Button(action: {
                            //self.isPlay ? self.musicController.startPlayback() : self.musicController.pausePlayback()
                            self.musicController.playMusic()
                            self.isPlay.toggle()
                        }) {
                            ZStack {
                                Circle().frame(width: 35, height: 35).foregroundColor(self.colorScheme == .dark ? Color.black : Color.white)
                                Image(systemName: self.isPlay ? "pause.circle.fill" : "play.circle.fill")
                                    .font(.system(size: 35, weight: .light))
                                    .foregroundColor(self.colorScheme == .dark ? Color.white : Color.black)
                            }
                        }
                        Spacer().frame(width: 40)
                        Button(action: { self.showAddSongSheet = true }) {
                            ZStack {
                                Circle().frame(width: 55, height: 55).foregroundColor(Color.white).shadow(radius: 10)
                                Image(systemName: "plus.circle.fill")
                                    .font(.system(size: 60, weight: .light))
                                    .foregroundColor(Color("purpleblue"))
                            }
                        }.sheet(isPresented: self.$showAddSongSheet) {
                            AddSongView()
                        }
                        Spacer().frame(width: 40)
                        Button(action: { self.musicController.skipNext() }) {
                            Image(systemName: "forward.end.fill")
                                .font(.system(size: 35, weight: .light))
                                .foregroundColor(self.colorScheme == .dark ? Color.white : Color.black)
                        }
                    }.padding(10).padding(.horizontal, 10).background(self.colorScheme == .dark ? Color("superdarkgray") : Color.white).cornerRadius(100).shadow(radius: 10)
                } else {
                    Button(action: { self.showAddSongSheet = true }) {
                        ZStack {
                            Circle().frame(width: 55, height: 55).foregroundColor(Color.white).shadow(radius: 5)
                            Image(systemName: "plus.circle.fill")
                                .font(.system(size: 60, weight: .light))
                                .foregroundColor(Color("purpleblue"))
                            
                        }
                    }.sheet(isPresented: self.$showAddSongSheet) {
                        AddSongView()
                    }
                }
                Spacer()
            }.padding(.bottom)
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    
    @State static var currentlyInSession = true
    static var user = User()
    
    static var previews: some View {
        Group {
            HomeView(user: user, currentlyInSession: $currentlyInSession) .environment(\.colorScheme, .light)
            
            HomeView(user: user, currentlyInSession: $currentlyInSession) .environment(\.colorScheme, .dark)
        }
    }
}
