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
    //@State var current_title_offset: CGFloat = 0
    @State var isPlay = true
    @State var value: Float = 0.8
    @State var offset = CGFloat()
    
    
    init(userVM: UserVM, currentlyInSession: Binding<Bool>) {
        self.userVM = userVM
        self._currentlyInSession = currentlyInSession
        self.songListVM = SongListVM(userVM: userVM)
        self.playerStateVM = PlayerStateVM(userVM: userVM)
        self.searchResultListVM = SearchResultListVM(userVM: userVM)
    }
    
    var body: some View {
        ZStack {
            ScrollView {
                GeometryReader { geo in
                    //                    Text("\(geo.frame(in: .global).minY)").offset(y: -geo.frame(in: .global).minY + self.offset)
                    Text("").onAppear {self.offset = geo.frame(in: .global).minY}
                    if (geo.frame(in: .global).minY > -150) {
                        VStack {
                            Spacer().frame(height: 20)
                            HStack {
                                Spacer()
                                CurrentSongView(playerStateVM: self.playerStateVM)
                                Spacer()
                            }
                            //                    ProgressBarView(playerStateVM: self.playerStateVM, isWide: false)
                            Spacer()
                        }
                    }
                    VStack(spacing: 0) {
                        Spacer().frame(height: 300)
                        
                        ForEach(self.songListVM.songs, id: \.self) { song in
                            SongListCell(userVM: self.userVM, song: song, rank: (self.songListVM.songs.firstIndex(of: song) ?? -1) + 1)
                                .frame(height: 80)
                            Divider()
                                .padding(.horizontal)
                        }
                        Spacer().frame(height: 50)
                    }.animation(.easeInOut(duration: 0.3))
                    
                    // for hiding Song Queue Layer above Song Title Layer
                    if (geo.frame(in: .global).minY <= -150) {
                        VStack {
                            Rectangle()
                                .frame(height: 60)
                                .foregroundColor(self.colorScheme == .dark ? Color(.black) : Color(.white))
                            Spacer()
                        }.edgesIgnoringSafeArea(.top).offset(y: -geo.frame(in: .global).minY)
                    }
                    
                    //Layer 2: Song Title Layer
                    if (geo.frame(in: .global).minY <= -150) {
                        VStack {
                            SongTitleBarView(playerStateVM: self.playerStateVM)
                                .onAppear(perform: simpleSuccessHaptic)
                            Spacer()
                        }.offset(y: -geo.frame(in: .global).minY + self.offset)
                    }
                    
                }
                .frame(height: (CGFloat(self.songListVM.songs.count * 77 + 380)))
            }
            
            if songListVM.songs.isEmpty {
                VStack(alignment: .center) {
                    Spacer()
                    
                    Text("tap + to add songs to session.")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(Color("purpleblue"))
                    Spacer()
                }
            }
            
            //Layer 3: Menu Layer
            self.menu_layer
        }//.onAppear{ self.playerStateVM.viewDidLoad() }
            // triggers updates on every second
            .onAppear{ self.playerStateVM.playerPause() }
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
                        .padding(25)
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
    
    func simpleSuccessHaptic() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
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

