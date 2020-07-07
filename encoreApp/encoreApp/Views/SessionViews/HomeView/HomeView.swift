//
//  HomeView.swift
//  encoreApp
//
//  Created by Nikolai Madlener on 26.05.20.
//  Copyright © 2020 NikolaiEtienne. All rights reserved.
//

import SwiftUI
import URLImage

struct HomeView: View {
    @Environment(\.colorScheme) var colorScheme
    //@ObservedObject var musicController: MusicController = .shared
    @ObservedObject var songListVM: SongListVM
    @ObservedObject var userVM: UserVM
    @ObservedObject var playerStateVM: PlayerStateVM
    @ObservedObject var searchResultListVM: SearchResultListVM
    
    @State var showMenuSheet = false
    @State var showAddSongSheet = false
    @Binding var currentlyInSession: Bool
    @State var current_title_offset: CGFloat = 0
    @State var isPlay = true
    
    
    init(userVM: UserVM, currentlyInSession: Binding<Bool>) {
        self.userVM = userVM
        self._currentlyInSession = currentlyInSession
        self.songListVM = SongListVM(userVM: userVM)
        self.playerStateVM = PlayerStateVM(userVM: userVM)
        self.searchResultListVM = SearchResultListVM(userVM: userVM)
    }
    
    var body: some View {
        ZStack {
            
            //Layer 1: Song Queue Layer
            songQueue_layer
            
            // for hiding Song Queue Layer above Song Title Layer
            if (self.current_title_offset <= -260) {
                VStack {
                    Rectangle()
                        .frame(height: 50)
                        .foregroundColor(self.colorScheme == .dark ? Color(.black) : Color(.white))
                    Spacer()
                }.edgesIgnoringSafeArea(.top)
            }
            
            //Layer 2: Song Title Layer
            if (self.current_title_offset <= -260) {
                VStack {
                    SongTitleBarView(playerStateVM: self.playerStateVM)
                    Spacer()
                }
            }
            
            //Layer 3: Menu Layer
            menu_layer
        }//.onAppear{ self.playerStateVM.viewDidLoad() }
        // triggers updates on every second
    }
    
    
    //MARK: Layer 1: Song Queue Layer
    private var songQueue_layer: some View {
        return
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
                            Spacer().frame(height: 30)
                            HStack {
                                Spacer()
                                CurrentSongView(playerStateVM: self.playerStateVM)
                                Spacer()
                            }
                            //                            VStack(spacing: 5) {
                            //                                ZStack(alignment: .leading) {
                            //                                    Rectangle()
                            //                                        .frame(width: geom.size.width * 0.8, height: 4)
                            //                                        .foregroundColor(self.colorScheme == .dark ? Color("darkgray") : Color.gray)
                            //                                        .cornerRadius(5)
                            //                                    Rectangle()
                            //                                        .frame(width: (/*self.musicController*/self.playerStateVM.normalizedPlaybackPosition * geom.size.width * 0.8), height: 4)
                            //                                        .foregroundColor(Color("purpleblue"))
                            //                                        .cornerRadius(5)
                            //                                }
                            //                                HStack {
                            //                                    Text(/*self.musicController.playerState?.playbackPosition*/Int(self.playerStateVM.progress).msToSeconds.minuteSecondMS.description ?? "--:--").font(.system(size: 10))
                            //                                    Spacer()
                            //                                    Text("-" + (Int(self.musicController.playerState?.track.duration ?? 0) - (self.musicController.playerState?.playbackPosition ?? 0)).msToSeconds.minuteSecondMS.description).font(.system(size: 10))
                            //                                }.frame(width: geom.size.width * 0.8)
                            //                            }.padding(.bottom)
                            Spacer()
                        }
                    }
                    
                    VStack {
                        if (self.current_title_offset <= -260) {
                            Spacer().frame(height: 280)
                        }
                        ForEach(self.songListVM.songs, id: \.self) { song in
                            
                            VStack {
                                SongListCell(userVM: self.userVM, song: song, rank: (self.songListVM.songs.firstIndex(of: song) ?? -1) + 1)
                                Divider()
                                    .padding(.horizontal)
                                    .padding(.top, -5)
                            }
                        }
                        Spacer().frame(height: 100)
                    }.animation(.easeInOut(duration: 0.2))
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
                            ZStack(alignment: .leading) {
                                Rectangle()
                                    .frame(width: geo.size.width, height: 3)
                                    .foregroundColor(self.colorScheme == .dark ? Color("darkgray") : Color.gray)
                                Rectangle()
                                    .frame(width: (self.playerStateVM.normalizedPlaybackPosition * geo.size.width), height: 4).cornerRadius(5)
                                    .foregroundColor(Color("purpleblue"))
                            }
                            
                        }.edgesIgnoringSafeArea(.top)
                        HStack {
                            Image(uiImage: self.playerStateVM.albumCover)
                                .resizable()
                                .frame(width: 30, height: 30)
                            VStack(alignment: .leading) {
                                Text("\(self.playerStateVM.song.name)")
                                    .font(.system(size: 15, weight: .bold))
                                Text("\(self.playerStateVM.song.artists[0])")
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
                Button(action: { self.showMenuSheet = true }) {
                    Image(systemName: "ellipsis")
                        .font(Font.system(.title))
                        .foregroundColor(self.colorScheme == .dark ? Color.white : Color.black)
                        .padding(20)
                }.sheet(isPresented: self.$showMenuSheet) {
                    MenuView(userVM: self.userVM, currentlyInSession: self.$currentlyInSession, showMenuSheet: self.$showMenuSheet)
                }
            }
            Spacer()
            HStack {
                Spacer()
                AddSongsBarView(userVM: userVM, searchResultListVM: searchResultListVM, isPlay: $isPlay, showAddSongSheet: $showAddSongSheet)
                Spacer()
            }.padding(.bottom)
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    
    @State static var currentlyInSession = true
    static var userVM = UserVM()
    
    static var previews: some View {
        Group {
            HomeView(userVM: userVM, currentlyInSession: $currentlyInSession) .environment(\.colorScheme, .light)
            HomeView(userVM: userVM, currentlyInSession: $currentlyInSession) .environment(\.colorScheme, .dark)
        }
    }
}

extension UIImage {
    func getPixelColor(pos: CGPoint) -> UIColor {
        
        let pixelData = self.cgImage!.dataProvider!.data
        let data: UnsafePointer<UInt8> = CFDataGetBytePtr(pixelData)
        
        let pixelInfo: Int = ((Int(self.size.width) * Int(pos.y)) + Int(pos.x)) * 4
        
        let r = CGFloat(data[pixelInfo]) / CGFloat(255.0)
        let g = CGFloat(data[pixelInfo+1]) / CGFloat(255.0)
        let b = CGFloat(data[pixelInfo+2]) / CGFloat(255.0)
        let a = CGFloat(data[pixelInfo+3]) / CGFloat(255.0)
        
        return UIColor(red: r, green: g, blue: b, alpha: a)
    }
}

extension TimeInterval {
    var minuteSecondMS: String {
        return String(format:"%d:%02d", minute, second)
    }
    var minute: Int {
        return Int((self/60).truncatingRemainder(dividingBy: 60))
    }
    var second: Int {
        return Int(truncatingRemainder(dividingBy: 60))
    }
    var millisecond: Int {
        return Int((self*1000).truncatingRemainder(dividingBy: 1000))
    }
}

extension Int {
    var msToSeconds: Double {
        return Double(self) / 1000
    }
}

