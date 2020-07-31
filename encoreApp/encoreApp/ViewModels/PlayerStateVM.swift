//
//  PlayerStateVM.swift
//  encoreApp
//
//  Created by Nikolai Madlener on 17.06.20.
//  Copyright © 2020 NikolaiEtienne. All rights reserved.
//

import Foundation
import IKEventSource
import Kingfisher
import SwiftUI

class PlayerStateVM: ObservableObject {
    @ObservedObject var musicController: MusicController = .shared
    @Published var song: Song
    @Published var progress: Int64
    @Published var isPlaying: Bool
    @Published var normalizedPlaybackPosition: CGFloat = 0
    @Published var albumCover: UIImage = UIImage(imageLiteralResourceName: "albumPlaceholder")
    @Published var songTimestamp_ms: CGFloat = 0
    var serverURL: URL
    var userVM: UserVM
    var eventSource: EventSource
    var timer = Timer()
    
    
    var appRemote: SPTAppRemote? {
        get {
            return (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.appRemote
        }
    }
    var defaultCallback: SPTAppRemoteCallback {
        get {
            return { [weak self] _, error in
                if let error = error {
                    //display error
                }
//                self?.getPlayerState()
            }
        }
    }
    
    init(userVM: UserVM) {
        print("INIT PlayerStateVM")
        var emptySong = Song(id: "0", name: "", artists: [""], duration_ms: 1, cover_url: "https://musicnotesbox.com/media/catalog/product/7/3/73993_image.png", album_name: "", preview_url: "", suggested_by: "", score: 0, time_added: "", upvoters: [], downvoters: [])
        song = emptySong
        progress = 0
        isPlaying = false
        self.userVM = userVM
        
        serverURL = URL(string: "https://api.encore-fm.com/events/"+"\(userVM.username)"+"/\(userVM.sessionID)")!
        eventSource = EventSource(url: serverURL)
        
        eventSource.connect()
        
        eventSource.onComplete { [weak self] statusCode, reconnect, error in
            DispatchQueue.main.asyncAfter(deadline: .now()) { [weak self] in
                self?.eventSource.connect()
            }
        }
        
        eventSource.addEventListener("sse:player_state_change") { [weak self] id, event, dataString in
            // Convert HTTP Response Data to a String
            if let dataString = dataString {
                print("\\")
                dataString.replacingOccurrences(of: "\\", with: "")
                print("eventListener Data Playerstate:" + "\(dataString)")
                let data: Data? = dataString.data(using: .utf8)
                if let data = data {
                    do {
                        let decodedData = try JSONDecoder().decode(PlayerStateChangePayload.self, from: data)
                        DispatchQueue.main.async {
                            print("Update Player State")
                            print(decodedData)
                            print("currentsong: " + "\(decodedData.current_song)")
                            
                            if let sng = decodedData.current_song {
                                self?.progress = decodedData.progress
                                self?.calculatePlayBarPosition()
                                self?.song = sng
                                self?.isPlaying = decodedData.is_playing
                                self?.syncProgressBar()
                                
                                self?.musicController.startPlayback()
                                
                                
//                                if userVM.isAdmin {
//                                    self?.appRemote?.authorizeAndPlayURI("spotify:track:" + "\(String(describing: sng.id))")
//
//                                    if decodedData.is_playing == false {
//                                        self?.appRemote?.playerAPI?.pause(self?.defaultCallback)
//                                    } else {
//                                        self?.appRemote?.playerAPI?.resume(self?.defaultCallback)
//                                    }
//                                }
                                
                                KingfisherManager.shared.retrieveImage(with: URL(string: sng.cover_url)!, options: nil, progressBlock: nil, completionHandler: { image, error, cacheType, imageURL in
                                    self?.albumCover = image ?? UIImage(imageLiteralResourceName: "albumPlaceholder")
                                })
                                
                            } else {
                                self?.progress = 0
                            }
                            
                            print(self?.normalizedPlaybackPosition)
                            
                        }
                    } catch {
                        print("Error SSE player_state_change ")
                        
                    }
                }
            }
        }
    }
    
    func calculatePlayBarPosition() {
        var numerator = CGFloat(self.progress ?? 1)
        var denominator = CGFloat(Int(self.song.duration_ms ?? 1))
        self.normalizedPlaybackPosition = numerator / denominator
        print("SongName\(self.song.name)")
        print("Progress\(numerator)")
        print("Durations\(self.song.duration_ms)")
        print("Valuee\(self.normalizedPlaybackPosition)")
    }
    
    func syncProgressBar() {
        print("STATEe: \(isPlaying)")
        songTimestamp_ms = CGFloat(progress)
    }
    
    func getPlayerState() {
        guard let url = URL(string: "https://api.encore-fm.com/users/"+"\(userVM.username)"+"/player/state") else {
            print("Invalid URL")
            return
            
        }
        var request = URLRequest(url: url)
        
        request.httpMethod = "GET"
        request.addValue(self.userVM.secret, forHTTPHeaderField: "Authorization")
        request.addValue(self.userVM.sessionID, forHTTPHeaderField: "Session")
        
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
                    DispatchQueue.main.async {
                        if let sng = decodedData.current_song {
                            self.progress = decodedData.progress
                            self.calculatePlayBarPosition()
                            
                        } else {
                            self.progress = 0
                        }
   
//                        if self.userVM.isAdmin {
//                            
//                            if decodedData.is_playing == false {
//                                self.appRemote?.playerAPI?.pause(self.defaultCallback)
//                            } else {
//                                self.appRemote?.playerAPI?.resume(self.defaultCallback)
//                            }
//                        }
                    }
                } catch {
                    print("Error Player State VM")
                }
            }
        }
        task.resume()
    }
    
    func viewDidLoad() {               // Use for the app's interface
        scheduledTimerWithTimeInterval()
    }
    
    func scheduledTimerWithTimeInterval(){
        // Scheduling timer to Call the function "updateCounting" with the interval of 1 seconds
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.updatePlayerState), userInfo: nil, repeats: true)
    }
    
    @objc func updatePlayerState(){
        //getPlayerState()
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
