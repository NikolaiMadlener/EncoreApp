//
//  HomeView.swift
//  encoreApp
//
//  Created by Nikolai Madlener on 26.05.20.
//  Copyright © 2020 NikolaiEtienne. All rights reserved.
//

import SwiftUI
import URLImage
import CoreHaptics

struct HomeView: View {
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var appState: AppState
    
    @ObservedObject var musicController: MusicController = .shared
    @ObservedObject var songListVM: SongListVM
    //@ObservedObject var userVM: UserVM
    @ObservedObject var playerStateVM: PlayerStateVM
    @ObservedObject var searchResultListVM: SearchResultListVM
    
    @State var showMenuSheet = false
    @State var showAddSongSheet = false
    //@State var current_title_offset: CGFloat = 0
    @State var isPlay = true
    @State var value: Float = 0.8
    @State var offset = CGFloat()
    @State private var engine: CHHapticEngine?
    
    
    init(appState: AppState) {
        self.songListVM = SongListVM(username: appState.user.username, sessionID: appState.session.sessionID)
        self.playerStateVM = PlayerStateVM(username: appState.user.username, sessionID: appState.session.sessionID, secret: appState.session.secret)
        self.searchResultListVM = SearchResultListVM(username: appState.user.username,
                                                     secret: appState.session.secret,
                                                     sessionID: appState.session.sessionID,
                                                     clientToken: appState.session.clientToken)
    }
    
    var body: some View {
        ZStack {
            ScrollView {
                GeometryReader { geo in
                    // Text("\(geo.frame(in: .global).minY)").offset(y: -geo.frame(in: .global).minY + self.offset)
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
                        ForEach(self.songListVM.songs, id: \.self) { song in
                            SongListCell(song: song, rank: (self.songListVM.songs.firstIndex(of: song) ?? -1) + 1)
                                .frame(height: 80)
                            Divider()
                                .padding(.horizontal)
                        }
                        Spacer().frame(height: 100)
                    }.animation(.easeInOut(duration: 0.3))
                    
                    // for hiding Song Queue Layer above Song Title Layer
                    if (geo.frame(in: .global).minY <= -220) {
                        VStack {
                            Rectangle()
                                .frame(height: 60)
                                .foregroundColor(self.colorScheme == .dark ? Color("superdarkgray") : Color(.white))
                            Spacer()
                        }.edgesIgnoringSafeArea(.top).offset(y: -geo.frame(in: .global).minY)
                    }
                    
                    //Layer 2: Song Title Layer
                    if (geo.frame(in: .global).minY <= -220) {
                        VStack {
                            SongTitleBarView(playerStateVM: self.playerStateVM)
                                .onAppear(perform: hapticEvent)
                                .onDisappear(perform: hapticEvent)
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
                        .font(.system(size: 19, weight: .semibold))
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
                    MenuView(username: appState.user.username,
                             sessionID: appState.session.sessionID,
                             playerStateVM: self.playerStateVM,
                             showMenuSheet: self.$showMenuSheet)
                }
            }

            Spacer()
            HStack {
                Spacer()
                AddSongsBarView(searchResultListVM: searchResultListVM, songListVM: songListVM, playerStateVM: playerStateVM, isPlay: $isPlay, showAddSongSheet: $showAddSongSheet)
                Spacer()
            }.padding(.bottom)
        }
    }
    
    func prepareHaptics() {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }

        do {
            self.engine = try CHHapticEngine()
            try engine?.start()
        } catch {
            print("There was an error creating the engine: \(error.localizedDescription)")
        }
    }
    
    func hapticEvent() {
        
        prepareHaptics()
        
        // make sure that the device supports haptics
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }
        var events = [CHHapticEvent]()

        // create one intense, sharp tap
        let intensity = CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.6)
        let sharpness = CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.5)
        let event = CHHapticEvent(eventType: .hapticTransient, parameters: [intensity, sharpness], relativeTime: 0)
        events.append(event)

        // convert those events into a pattern and play it immediately
        do {
            let pattern = try CHHapticPattern(events: events, parameters: [])
            let player = try engine?.makePlayer(with: pattern)
            try player?.start(atTime: 0)
        } catch {
            print("Failed to play pattern: \(error.localizedDescription).")
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var appState = AppState()
    
    static var previews: some View {
        Group {
            HomeView(appState: appState) .environment(\.colorScheme, .light)
            HomeView(appState: appState) .environment(\.colorScheme, .dark)
        }
    }
}
