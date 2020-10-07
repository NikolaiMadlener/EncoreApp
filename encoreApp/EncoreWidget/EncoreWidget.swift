//
//  EncoreWidget.swift
//  EncoreWidget
//
//  Created by Nikolai Madlener on 02.10.20.
//  Copyright © 2020 NikolaiEtienne. All rights reserved.
//

import WidgetKit
import SwiftUI

struct CurrentSongViewWidgetSmall: View {
    @Environment(\.colorScheme) var colorScheme
    var songEntry: Provider.Entry
    
    var body: some View {
        ZStack {
            VStack() {
                HStack {
                    Group{
                        Image(uiImage: songEntry.albumCover)
                            .resizable()
                            .frame(width: 85, height: 85)
                            .cornerRadius(10)
                            .shadow(radius: 5)
                    }
                    Spacer()
                }
                Spacer()
                HStack {
                    Text("\(self.songEntry.song.name)")
                        .font(.system(size: 14, weight: .bold))
                    Spacer()
                }
                HStack {
                    Text("\(self.songEntry.song.artists[0])")
                        .font(.system(size: 10, weight: .semibold))
                    Spacer()
                }
            }.padding()
            VStack {
                HStack {
                    Spacer()
                    
                    Image("AppIconImage")
                        .resizable()
                        .frame(width: 30, height: 30)
                        .cornerRadius(5)
                        .padding([.top, .trailing], 8)

                }
                Spacer()
            }
        }.background(colorScheme == .dark ? Color("superdarkgray") : Color.white)
    }
}

struct CurrentSongViewWidgetMedium: View {
    @Environment(\.colorScheme) var colorScheme
    var songEntry: Provider.Entry
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                HStack {
                    VStack {
                        HStack {
                            
                            Image(uiImage: songEntry.albumCover)
                                .resizable()
                                .frame(width: 85, height: 85)
                                .cornerRadius(15)
                                .shadow(radius: 5)
                            
                            Spacer()
                        }
                        Spacer()
                        HStack {
                            Text("\(self.songEntry.song.name)")
                                .font(.system(size: 14, weight: .bold))
                            Spacer()
                        }
                        HStack {
                            Text("\(self.songEntry.song.artists[0])")
                                .font(.system(size: 10, weight: .semibold))
                            Spacer()
                        }
                    }.padding()
                    //                    .frame(width: geo.size.width/2, height: geo.size.height, alignment: .leading)
                    
                    
                    VStack(alignment: .leading, spacing: 0) {
                        Text("Up Next").font(.system(size: 18, weight: .bold))
                        Spacer().frame(height: 5)
                        ForEach(songEntry.songList.prefix(3)) { song in
                            VStack(alignment: .leading, spacing: 0) {
                                Text(song.name).font(.system(size: 12, weight: .semibold))
                                Text(song.artists[0]).font(.system(size: 10))
                                Spacer().frame(height: 5)
                            }
                            
                        }
                        Spacer()
                    }.padding([.trailing, .bottom, .top]).frame(width: geo.size.width/2, height: geo.size.height, alignment: .leading)
                }
                VStack {
                    HStack {
                        Spacer()
                        
                        Image("AppIconImage")
                            .resizable()
                            .frame(width: 30, height: 30)
                            .cornerRadius(15)
                            .padding([.top, .trailing], 8)
                            
                    }
                    Spacer()
                }
            }.background(colorScheme == .dark ? Color("superdarkgray") : Color.white)
        }
    }
}


struct SongView: View {
    @Environment(\.widgetFamily) var family: WidgetFamily
    var songEntry: Provider.Entry
    
    
    @ViewBuilder
    var body: some View {
        switch family {
        case .systemSmall: CurrentSongViewWidgetSmall(songEntry: songEntry)
        case .systemMedium: CurrentSongViewWidgetMedium(songEntry: songEntry)
        //        case .systemLarge: CurrentSongViewWidgetLarge(songEntry: songEntry)
        default: CurrentSongViewWidgetSmall(songEntry: songEntry)
        }
    }
}


@main
struct MainWidget : Widget {
    
    var body: some WidgetConfiguration{
        
        StaticConfiguration(kind: "EncoreWidget", provider: Provider()) { songEntry in
            
            SongView(songEntry: songEntry)
        }
        // you can use anything..
        //.description(Text("Current Song"))
        .configurationDisplayName(Text("Current Song"))
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}


struct SongEntry: TimelineEntry {
    let date: Date
    let song: Song
    var albumCover: UIImage
    var songList: [Song]
}

struct Provider : TimelineProvider {
    let emptySong = Song(id: "-", name: "-", artists: ["-"], duration_ms: 0, cover_url: "-", album_name: "-", preview_url: "-", suggested_by: "-", score: 0, time_added: "-", upvoters: ["-"], downvoters: ["-"])
    
    func getSnapshot(in context: Context, completion: @escaping (SongEntry) -> Void) {
        let loadingData = SongEntry(date: Date(), song: emptySong, albumCover: UIImage(imageLiteralResourceName: "albumPlaceholder"), songList: [])
        
        completion(loadingData)
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<SongEntry>) -> Void) {
        var date = Date()
        let nextUpdate = Calendar.current.date(byAdding: .second, value: 15, to: date)
        
        let container = UserDefaults(suiteName:"group.com.bitkitApps.encore")
        if let sharedUserData = container?.object(forKey: "sharedUser") as? Data {
            let decoder = JSONDecoder()
            if let sharedUser = try? decoder.decode([String].self, from: sharedUserData) {
            } else {
                let entry = SongEntry(date: date, song: emptySong, albumCover: UIImage(imageLiteralResourceName: "albumPlaceholder"), songList: [emptySong])
                let timeline = Timeline(entries: [entry], policy: .after(Date().addingTimeInterval(20)))
                completion(timeline)
                return
            }
        } else {
            let entry = SongEntry(date: date, song: emptySong, albumCover: UIImage(imageLiteralResourceName: "albumPlaceholder"), songList: [emptySong])
            let timeline = Timeline(entries: [entry], policy: .after(Date().addingTimeInterval(20)))
            completion(timeline)
            return
        }
        
        getData { (modelData) in
            
            var sharedSongList = [emptySong]
            let container = UserDefaults(suiteName:"group.com.bitkitApps.encore")
            if let sharedSongListData = container?.object(forKey: "sharedSongList") as? Data {
                let decoder = JSONDecoder()
                if let songList = try? decoder.decode([Song].self, from: sharedSongListData) {
                    print(sharedSongList)
                    sharedSongList = songList
                }
                
            }
            
            
            
            var data = SongEntry(date: date, song: modelData.0, albumCover: modelData.1 ?? UIImage(imageLiteralResourceName: "albumPlaceholder"), songList: sharedSongList)
            
            
            guard let url = URL(string: data.song.cover_url) else {
                print("Invalid URL")
                return
            }
            
            let task = URLSession.shared.dataTask(with: url) { fetchedData, response, error in
                guard let fetchedData = fetchedData else { return }
                
                data.albumCover = UIImage(data: fetchedData) ?? UIImage(imageLiteralResourceName: "albumPlaceholder")
                
                
                
                let timeline = Timeline(entries: [data], policy: .after(Date().addingTimeInterval(20)))
                
                completion(timeline)
                
            }
            task.resume()
        }
    }
    
    func placeholder(in context: Context) -> SongEntry {
        let loadingData = SongEntry(date: Date(), song: emptySong, albumCover: UIImage(imageLiteralResourceName: "albumPlaceholder"), songList: [])
        
        return loadingData
    }
}


func getData(completion: @escaping ((Song, UIImage))-> ()){
    let container = UserDefaults(suiteName:"group.com.bitkitApps.encore")
    if let sharedUserData = container?.object(forKey: "sharedUser") as? Data {
        let decoder = JSONDecoder()
        if let sharedUser = try? decoder.decode([String].self, from: sharedUserData) {
            print(sharedUser)
            
            
            print("GET DATA WIDGET")
            guard let url = URL(string: "https://api.encore-fm.com/users/"+"\(sharedUser[0])"+"/player/state") else {
                print("Invalid URL")
                return
                
            }
            var request = URLRequest(url: url)
            
            request.httpMethod = "GET"
            request.addValue(sharedUser[1], forHTTPHeaderField: "Authorization")
            request.addValue(sharedUser[2], forHTTPHeaderField: "Session")
            
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
                        let decodedData = try JSONDecoder().decode(PlayerStateChangePayload.self, from: data)
                        
                        if let sng = decodedData.current_song {
                            var uiImage = UIImage(imageLiteralResourceName: "albumPlaceholder")
                            
                            completion((sng, uiImage))
                        }
                    } catch {
                        let sng = Song(id: "-", name: "-", artists: ["-"], duration_ms: 0, cover_url: "-", album_name: "-", preview_url: "-", suggested_by: "-", score: 0, time_added: "-", upvoters: ["-"], downvoters: ["-"])
                        let uiImage = UIImage(imageLiteralResourceName: "albumPlaceholder")
                        completion((sng, uiImage))
                        print("Error Player State VM")
                    }
                }
            }
            task.resume()
        }
    }
}


struct PlayerStateChangePayload: Codable, Hashable {
    var current_song: Song?
    var is_playing: Bool
    var progress: Int64
    var timestamp: String
    
    init(current_song: Song?, is_playing: Bool, progress: Int64, timestamp: String) {
        self.current_song = current_song
        self.is_playing = is_playing
        self.progress = progress
        self.timestamp = timestamp
    }
}

struct EncoreWidget_Previews: PreviewProvider {
    static var previews: some View {
        /*@START_MENU_TOKEN@*/Text("Hello, World!")/*@END_MENU_TOKEN@*/
    }
}
