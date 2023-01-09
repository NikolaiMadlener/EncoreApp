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
    @ObservedObject var musicController: MusicController = .shared
    @ObservedObject var songListVM: SongListVM
    @ObservedObject var userVM: UserVM
    @ObservedObject var playerStateVM: PlayerStateVM
    @ObservedObject var searchResultListVM: SearchResultListVM
    @ObservedObject var pageViewModel: PageViewModel
    
    @State var showMenuSheet = false
    @State var showAddSongSheet = false
    @Binding var currentlyInSession: Bool
    //@State var current_title_offset: CGFloat = 0
    @State var isPlay = true
    @State var value: Float = 0.8
    @State var offset = CGFloat()
    @State var showSongTitleBar = false
    
    
    init(userVM: UserVM, currentlyInSession: Binding<Bool>, pageViewModel: PageViewModel) {
        self.userVM = userVM
        self._currentlyInSession = currentlyInSession
        self.songListVM = SongListVM(userVM: userVM)
        self.searchResultListVM = SearchResultListVM(userVM: userVM)
        self.playerStateVM = PlayerStateVM(userVM: userVM)
        self.pageViewModel = pageViewModel
    }
    
    var body: some View {
        ZStack {
            ScrollView {
                GeometryReader { geo in
                    Text("")
                        .onAppear {self.offset = geo.frame(in: .global).minY}
                    if (geo.frame(in: .global).minY > -220 && playerStateVM.song.name != "empty_song") {
                        VStack {
                            Spacer().frame(height: 20)
                            HStack {
                                Spacer()
                                CurrentSongView(playerStateVM: self.playerStateVM)
                                Spacer()
                            }
                            ProgressBarView(playerStateVM: self.playerStateVM, showMenuSheet: $showMenuSheet, isWide: false)
                            Spacer()
                        }
                    }
                        
                    VStack(alignment: .leading, spacing: 0) {
                        Spacer().frame(height: 320)
                        if !songListVM.songs.isEmpty {
                            Text("up next.")
                                .font(.system(size: 25, weight: .bold))
                                .foregroundColor(Color("fontLightGray"))
                                .padding(.leading, 8)
                                .padding(.bottom, 5)
                        }
                        ForEach(self.songListVM.songs, id: \.self) { song in
                            SongListCell(userVM: self.userVM, song: song, rank: (self.songListVM.songs.firstIndex(of: song) ?? -1) + 1)
                        }
                        
                    }.animation(.easeInOut(duration: 0.3))
                    
                    //Control Visablilty of SongTitleBarView
                    if (geo.frame(in: .global).minY <= -220) {
                        Text("")
                            .onAppear {
                                self.showSongTitleBar = true
                            }
                    } else {
                        Text("")
                            .onAppear {
                                self.showSongTitleBar = false
                            }
                    }
                }
                .frame(height: (CGFloat(self.songListVM.songs.count * 90 + 350)))
            }
            
            self.menu_layer
            
            VStack {
                if showSongTitleBar {
                    SongTitleBarView(playerStateVM: self.playerStateVM)
                        .transition(.move(edge: .top))
                        .animation(.default)
                }
                Spacer()
            }
            
            if songListVM.songs.isEmpty {
                VStack(alignment: .center) {
                    Spacer()
                    if playerStateVM.song.name != "empty_song" {
                        Spacer()
                    }
                    Text("tap + to add songs to session.")
                        .font(.system(size: 19, weight: .semibold))
                        .foregroundColor(Color("purpleblue"))
                    Spacer()
                }
            }
        }//.onAppear{ self.playerStateVM.viewDidLoad() }
            // triggers updates on every second
            .onAppear{ self.playerStateVM.playerPause() }
        
    }
    
    
    //MARK: Layer 3: Menu Layer
    private var menu_layer: some View {
        VStack {
            HStack {
                Spacer()
                Button(action: {
                    withAnimation {
                        self.pageViewModel.selectTabIndex = 1
                    }
                }) {
                    Image(systemName: "arrow.right")
                        .font(.system(size: 23, weight: .semibold))
                        .foregroundColor(Color.white)
                        .padding(.vertical, 19)
                        .padding(.trailing, 20)
                }
            }
            Spacer()
            HStack {
                Spacer()
                AddSongsBarView(userVM: userVM, searchResultListVM: searchResultListVM, songListVM: songListVM, playerStateVM: playerStateVM, isPlay: $isPlay, showAddSongSheet: $showAddSongSheet, currentlyInSession: $currentlyInSession)
                Spacer()
            }.padding(.bottom, 10)
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    
    @State static var currentlyInSession = true
    static var userVM = UserVM()
    
    static var previews: some View {
        HomeView(userVM: userVM, currentlyInSession: $currentlyInSession, pageViewModel: PageViewModel())
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

