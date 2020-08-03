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
    @ObservedObject var musicController: MusicController = .shared
    @ObservedObject var songListVM: SongListVM
    @ObservedObject var userVM: UserVM
    @ObservedObject var playerStateVM: PlayerStateVM
    @ObservedObject var searchResultListVM: SearchResultListVM
    
    @State var showMenuSheet = false
    @State var showAddSongSheet = false
    @Binding var currentlyInSession: Bool
    @State var current_title_offset: CGFloat = 0
    @State var isPlay = true
    @State var value: Float = 0.8
    
    
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
            .onAppear{ self.playerStateVM.playerPause() }
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
            if (self.current_title_offset > -260) {
                VStack {
                    HStack {
                        Spacer()
                        CurrentSongView(playerStateVM: self.playerStateVM)
                        Spacer()
                    }
                    ProgressBarView(playerStateVM: self.playerStateVM, isWide: false)
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
                    MenuView(userVM: self.userVM, playerStateVM: self.playerStateVM, currentlyInSession: self.$currentlyInSession, showMenuSheet: self.$showMenuSheet)
                }
            }
            Spacer()
            HStack {
                Spacer()
                AddSongsBarView(userVM: userVM, searchResultListVM: searchResultListVM, songListVM: songListVM, playerStateVM: playerStateVM, isPlay: $isPlay, showAddSongSheet: $showAddSongSheet, currentlyInSession: $currentlyInSession)
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

