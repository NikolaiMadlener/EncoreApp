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
    @StateObject var viewModel: ViewModel
    
    var body: some View {
        ZStack {
            ScrollView {
                GeometryReader { geo in
                    Text("")
                        .onAppear {self.viewModel.offset = geo.frame(in: .global).minY}
                    if (geo.frame(in: .global).minY > -220 && viewModel.song.name != "empty_song") {
                        VStack {
                            Spacer().frame(height: 20)
                            HStack {
                                Spacer()
                                CurrentSongView(viewModel: .init())
                                Spacer()
                            }
                            ProgressBarView(viewModel: .init(showMenuSheet: $viewModel.showMenuSheet, isWide: false))
                            Spacer()
                        }
                    }
                    
                    VStack(alignment: .leading, spacing: 0) {
                        Spacer().frame(height: 320)
                        ForEach(self.viewModel.songs, id: \.self) { song in
                            SongListCell(viewModel: .init(song: song, rank: (self.viewModel.songs.firstIndex(of: song) ?? -1) + 1))
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
                            SongTitleBarView(viewModel: .init())
                                .onAppear{self.viewModel.hapticEvent()}
                                .onDisappear{self.viewModel.hapticEvent()}
                            Spacer()
                        }.offset(y: -geo.frame(in: .global).minY + self.viewModel.offset)
                    }
                }
                .frame(height: (CGFloat(self.viewModel.songs.count * 77 + 380)))
            }
            
            if viewModel.songs.isEmpty {
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
        }.onAppear{
//            self.viewModel.playerPause()
            Task.init {
                await viewModel.setupSSE()
            }
        }
    }

    private var menu_layer: some View {
        VStack {
            HStack {
                Spacer()
                Button(action: { self.viewModel.showMenuSheet = true }) {
                    Image(systemName: "ellipsis")
                        .font(Font.system(.title))
                        .foregroundColor(self.colorScheme == .dark ? Color.white : Color.black)
                        .padding(25)
                }.sheet(isPresented: self.$viewModel.showMenuSheet) {
                    MenuView(viewModel: .init())
                }
            }

            Spacer()
            HStack {
                Spacer()
                AddSongsBarView(viewModel: .init(showAddSongSheet: $viewModel.showAddSongSheet))
                Spacer()
            }.padding(.bottom)
        }
    }
}

struct HomeView_Previews: PreviewProvider {

    static var previews: some View {
        Group {
            HomeView(viewModel: .init()).environment(\.colorScheme, .light)
            HomeView(viewModel :.init()).environment(\.colorScheme, .dark)
        }
    }
}
