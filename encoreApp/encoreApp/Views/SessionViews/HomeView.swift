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
    @ObservedObject var networkModel: NetworkModel = .shared
    @ObservedObject var musicController: MusicController = .shared
    @ObservedObject var songListVM: SongListVM
    @ObservedObject var playerStateVM: PlayerStateVM
    
    @State var showMenuSheet = false
    @State var showAddSongSheet = false
    @Binding var currentlyInSession: Bool
    @State var current_title_offset: CGFloat = 0
    @State var isPlay = true
    
    init(currentlyInSession: Binding<Bool>, userVM: UserVM) {
        self._currentlyInSession = currentlyInSession
        self.songListVM = SongListVM(userVM: userVM)
        self.playerStateVM = PlayerStateVM(userVM: userVM)
    }
    
    var body: some View {
        ZStack {
            //Layer 1: Song Queue Layer
            songQueue_layer
            
            //Layer 2: Song Title Layer
            songTitleBar_layer
            
            //Layer 3: Menu Layer
            menu_layer
        }//.onAppear{ self.musicController.viewDidLoad() } // triggers updates on every second
            .onAppear {
                //self.songListVM = SongListVM(userVM: networkModel.userVM)
                //self.playerStateVM = PlayerStateVM(userVM: networkModel.userVM)       //Temporary!!
                self.playerStateVM.viewDidLoad()
                
        }
    }
    
    
    //MARK: Layer 1: Song Queue Layer
    private var songQueue_layer: some View {
        var albumWidth = self.musicController.currentAlbumImage.size.width
        func uiColorTopLeft(image: UIImage) -> UIColor {
            return image.getPixelColor(pos: CGPoint(x: albumWidth * 0.2,y: albumWidth * 0.2))
        }
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
                                    //                                    if self.colorScheme == .dark {
                                    //                                        Image(uiImage: self.musicController.currentAlbumImage)
                                    //                                            .resizable()
                                    //                                            .frame(width: 180, height: 180)
                                    //                                            .cornerRadius(10)
                                    //                                    } else {
                                    //                                        Image(uiImage: self.musicController.currentAlbumImage)
                                    //                                            .resizable()
                                    //                                            .frame(width: 180, height: 180)
                                    //                                            .cornerRadius(10)
                                    //                                            .shadow(color: Color(uiColorTopLeft).opacity(0.1), radius: 8, x: -10, y: -10)
                                    //                                            .shadow(color: Color(uiColorTopRight).opacity(0.1), radius: 8, x: 10, y: -10)
                                    //                                            .shadow(color: Color(uiColorBottomLeft).opacity(0.1), radius: 8, x: -10, y: 10)
                                    //                                            .shadow(color: Color(uiColorBottomRight).opacity(0.1), radius: 8, x: 10, y: 10)
                                    //                                            .blendMode(.multiply)
                                    //                                    }
                                    URLImage(URL(string: self.playerStateVM.song.cover_url)!,
                                             placeholder: Image("albumPlaceholder"),
                                             content: {
                                                
                                                $0.image
                                                    .resizable()
                                                    .frame(width: 180, height: 180)
                                                    .cornerRadius(10)
//                                                    .shadow(color: uiColorTopLeft(image: $0.image).opacity(0.1), radius: 8, x: -10, y: -10)
//                                                    .shadow(color: Color(uiColorTopRight).opacity(0.1), radius: 8, x: 10, y: -10)
//                                                    .shadow(color: Color(uiColorBottomLeft).opacity(0.1), radius: 8, x: -10, y: 10)
//                                                    .shadow(color: Color(uiColorBottomRight).opacity(0.1), radius: 8, x: 10, y: 10)
                                                
                                    })
                                    
                                    
                                    Text("\(/*self.musicController.trackName*/ self.self.playerStateVM.song.name ?? "No Song")")
                                        .font(.system(size: 25, weight: .bold))
                                    Text("\(/*self.musicController.artistName*/ self.self.playerStateVM.song.artists[0] ?? "No Artist")")
                                        .font(.system(size: 20, weight: .semibold))
                                }
                                Spacer()
                            }
                            VStack(spacing: 5) {
                                ZStack(alignment: .leading) {
                                    Rectangle()
                                        .frame(width: geom.size.width * 0.8, height: 4)
                                        .foregroundColor(self.colorScheme == .dark ? Color("darkgray") : Color.gray)
                                        .cornerRadius(5)
                                    Rectangle()
                                        .frame(width: (/*self.musicController*/self.playerStateVM.normalizedPlaybackPosition * geom.size.width * 0.8), height: 4)
                                        .foregroundColor(Color("purpleblue"))
                                        .cornerRadius(5)
                                }
                                HStack {
                                    Text(/*self.musicController.playerState?.playbackPosition*/Int(self.playerStateVM.progress).msToSeconds.minuteSecondMS.description ?? "--:--").font(.system(size: 10))
                                    Spacer()
                                    Text("-" + (Int(self.musicController.playerState?.track.duration ?? 0) - (self.musicController.playerState?.playbackPosition ?? 0)).msToSeconds.minuteSecondMS.description).font(.system(size: 10))
                                }.frame(width: geom.size.width * 0.8)
                            }.padding(.bottom)
                            Spacer()
                        }
                    }
                    
                    VStack {
                        if (self.current_title_offset <= -260) {
                            Spacer().frame(height: 300)
                        }
                        ForEach(self.songListVM.songs, id: \.self) { song in
                            VStack {
                                SongListCell(song: song, rank: (self.songListVM.songs.firstIndex(of: song) ?? -1) + 1)
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
                            // later this will be the playbar
                            ZStack(alignment: .leading) {
                                Rectangle()
                                    .frame(width: geo.size.width, height: 3)
                                    .foregroundColor(self.colorScheme == .dark ? Color("darkgray") : Color.gray)
                                Rectangle()
                                    .frame(width: (self.musicController.normalizedPlaybackPosition! * geo.size.width), height: 4).cornerRadius(5)
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
                Button(action: { self.showMenuSheet = true }) {
                    Image(systemName: "ellipsis")
                        .font(Font.system(.title))
                        .foregroundColor(self.colorScheme == .dark ? Color.white : Color.black)
                }.padding()
                    .sheet(isPresented: self.$showMenuSheet) {
                        MenuView(currentlyInSession: self.$currentlyInSession, showMenuSheet: self.$showMenuSheet)
                }
            }
            Spacer()
            HStack {
                Spacer()
                if self.networkModel.userVM.isAdmin {
                    HStack {
                        Button(action: {
                            //self.musicController.playMusic()
                            self.isPlay ? self.playerPause() : self.playerPlay()
                            
                            
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
                            SuggestSongView()
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
                        SuggestSongView()
                    }
                }
                Spacer()
            }.padding(.bottom)
        }
    }
    
    func playerPlay() {
        guard let url = URL(string: "https://api.encore-fm.com/users/"+"\(networkModel.userVM.username)"+"/player/play") else {
            print("Invalid URL")
            return
            
        }
        var request = URLRequest(url: url)
        
        request.httpMethod = "POST"
        request.addValue(self.networkModel.userVM.secret, forHTTPHeaderField: "Authorization")
        request.addValue(self.networkModel.userVM.sessionID, forHTTPHeaderField: "Session")
        
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
                self.isPlay = true
//                do {
//                    let decodedData = try JSONDecoder().decode(Song.self, from: data)
//                    DispatchQueue.main.async {
//                        print("Successfully post of player play")
//                        
//                    }
//                } catch {
//                    print("Error")
//                }
            }
        }
        task.resume()
    }
    
    func playerPause() {
        guard let url = URL(string: "https://api.encore-fm.com/users/"+"\(networkModel.userVM.username)"+"/player/pause") else {
            print("Invalid URL")
            return
            
        }
        var request = URLRequest(url: url)
        
        request.httpMethod = "POST"
        request.addValue(self.networkModel.userVM.secret, forHTTPHeaderField: "Authorization")
        request.addValue(self.networkModel.userVM.sessionID, forHTTPHeaderField: "Session")
        
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
                self.isPlay = false
//                do {
//                    let decodedData = try JSONDecoder().decode(String.self, from: data)
//                    DispatchQueue.main.async {
//                        print("Successfully post of player pause")
//
//                    }
//                } catch {
//                    print("Error")
//                }
            }
        }
        task.resume()
    }
}

struct HomeView_Previews: PreviewProvider {
    
    @State static var currentlyInSession = true
    static var userVM = UserVM()
    
    static var previews: some View {
        Group {
            HomeView(currentlyInSession: $currentlyInSession, userVM: userVM) .environment(\.colorScheme, .light)
            
            HomeView(currentlyInSession: $currentlyInSession, userVM: userVM) .environment(\.colorScheme, .dark)
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

//extension Image {
//    func getPixelColor(pos: CGPoint) -> UIColor {
//
//        let pixelData = self.cgImage!.dataProvider!.data
//        let data: UnsafePointer<UInt8> = CFDataGetBytePtr(pixelData)
//
//        let pixelInfo: Int = ((Int(self.size.width) * Int(pos.y)) + Int(pos.x)) * 4
//
//        let r = CGFloat(data[pixelInfo]) / CGFloat(255.0)
//        let g = CGFloat(data[pixelInfo+1]) / CGFloat(255.0)
//        let b = CGFloat(data[pixelInfo+2]) / CGFloat(255.0)
//        let a = CGFloat(data[pixelInfo+3]) / CGFloat(255.0)
//
//        return UIColor(red: r, green: g, blue: b, alpha: a)
//    }
//}

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
