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
    
    @ObservedObject var musicController: MusicController = .shared
    @ObservedObject var songListVM: SongListVM
    @ObservedObject var user: User
    
    @State var presentMenuSheet = false
    @State var showAddSongSheet = false
    @Binding var currentlyInSession: Bool
    @State var current_title_offset: CGFloat = 0
    @State var isPlay = false
    @State var songs: [Song] = []
    
    init(user: User, currentlyInSession: Binding<Bool>) {
        self.user = user
        self._currentlyInSession = currentlyInSession
        songListVM = SongListVM(userVM: user)
    }
    
    var body: some View {
        ZStack {
            //Layer 1: Song Queue Layer
            songQueue_layer
            
            //Layer 2: Song Title Layer
            songTitleBar_layer
            
            //Layer 3: Menu Layer
            menu_layer
        }.onAppear{ self.musicController.viewDidLoad() } // triggers updates on every second
    }
    
    
    //MARK: Layer 1: Song Queue Layer
    private var songQueue_layer: some View {
        var albumWidth = self.musicController.currentAlbumImage.size.width
        var uiColorTopLeft = self.musicController.currentAlbumImage.getPixelColor(pos: CGPoint(x: albumWidth * 0.2,y: albumWidth * 0.2))
        var uiColorBottomRight = self.musicController.currentAlbumImage.getPixelColor(pos: CGPoint(x: albumWidth * 0.8, y: albumWidth * 0.8))
        var uiColorBottomLeft = self.musicController.currentAlbumImage.getPixelColor(pos: CGPoint(x: albumWidth * 0.2,y: albumWidth * 0.8))
        var uiColorTopRight = self.musicController.currentAlbumImage.getPixelColor(pos: CGPoint(x: albumWidth * 0.8, y: albumWidth * 0.2))
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
                            HStack {
                                Spacer()
                                VStack {
                                    if self.colorScheme == .dark {
                                        Image(uiImage: self.musicController.currentAlbumImage)
                                            .resizable()
                                            .frame(width: 180, height: 180)
                                            .cornerRadius(10)
                                    } else {
                                        Image(uiImage: self.musicController.currentAlbumImage)
                                            .resizable()
                                            .frame(width: 180, height: 180)
                                            .cornerRadius(10)
                                            .shadow(color: Color(uiColorTopLeft).opacity(0.1), radius: 8, x: -10, y: -10)
                                            .shadow(color: Color(uiColorTopRight).opacity(0.1), radius: 8, x: 10, y: -10)
                                            .shadow(color: Color(uiColorBottomLeft).opacity(0.1), radius: 8, x: -10, y: 10)
                                            .shadow(color: Color(uiColorBottomRight).opacity(0.1), radius: 8, x: 10, y: 10)
                                            .blendMode(.multiply)
                                    }
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
                        ForEach(self.songListVM.songs, id: \.self) { song in
                            VStack {
                                SongListCell(user: self.user, song: song, rank: (self.songs.firstIndex(of: song) ?? -1) + 1)
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
                            Image(uiImage: self.musicController.currentAlbumImage)
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
                        Button(action: { self.showAddSongSheet = true
                            // add 2 hardcoded songs - remove later
                            self.suggestSong(songID: "6rqhFgbbKwnb9MLmUQDhG6")
                            self.suggestSong(songID: "32ftxJzxMPgUFCM6Km9WTS")
                        }) {
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
                    Button(action: { self.showAddSongSheet = true
                        // add 2 hardcoded songs - remove later
                        self.suggestSong(songID: "6rqhFgbbKwnb9MLmUQDhG6")
                        self.suggestSong(songID: "32ftxJzxMPgUFCM6Km9WTS")
                    }) {
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
    
    func suggestSong(songID: String) {
        guard let url = URL(string: "https://api.encore-fm.com/users/"+"\(user.username)"+"/suggest/"+"\(songID)") else {
            print("Invalid URL")
            return
            
        }
        var request = URLRequest(url: url)
        
        request.httpMethod = "POST"
        request.addValue(self.user.secret, forHTTPHeaderField: "Authorization")
        request.addValue(self.user.sessionID, forHTTPHeaderField: "Session")
        
        // HTTP Request Parameters which will be sent in HTTP Request Body
        //let postString = "userId=300&title=My urgent task&completed=false";
        // Set HTTP Request Body
        //request.httpBody = postString.data(using: String.Encoding.utf8);
        // Perform HTTP Request
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            
            // Check for Error
            if let error = error {
                print("Error took place \(error)")
                return
            }
            
            
            // Convert HTTP Response Data to a String
            if let data = data, let dataString = String(data: data, encoding: .utf8) {
                print("Response data string:\n \(dataString)")
                
                do {
                    let decodedData = try JSONDecoder().decode(Song.self, from: data)
                    DispatchQueue.main.async {
                        print("Successfully post of suggest song")
                        
                    }
                } catch {
                    print("Error")
                }
            }
        }
        task.resume()
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
