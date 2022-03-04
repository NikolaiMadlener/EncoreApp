//
//  PlayListService.swift
//  encoreApp
//
//  Created by Nikolai Madlener on 01.03.22.
//  Copyright © 2022 NikolaiEtienne. All rights reserved.
//

import Foundation
import IKEventSource
import Kingfisher

// MARK: - Service
struct SSEService {
    @Dependency(\.appState) private var appState
    
    func setupEventSource() async -> Void {
        let username = appState[\.user.username]
        let sessionID = appState[\.session.sessionID]
        let serverURL = URL(string: "https://api.encore-fm.com/events/"+"\(username)/"+"\(sessionID)")!
        let eventSource = EventSource(url: serverURL)
        
        eventSource.connect()
        
        eventSource.onComplete { [self] statusCode, reconnect, error in
            DispatchQueue.main.asyncAfter(deadline: .now()) { [self] in
                eventSource.connect()
            }
        }
        
        eventSource.addEventListener("sse:user_list_change") { [self] id, event, dataString in
            print("eventListener Data userlist:" + "\(dataString)")
            // Convert HTTP Response Data to a String
            if let dataString = dataString {
                let data: Data? = dataString.data(using: .utf8)
                if let data = data {
                    do {
                        let decodedData = try JSONDecoder().decode([UserListElement].self, from: data)
                        DispatchQueue.main.async {
                            appState[\.members] = decodedData
                            print("UPDATE MemberList SSE")
                        }
                    } catch {
                        print("Error SSE user list change")
                    }
                }
            }
        }
        
        eventSource.addEventListener("sse:playlist_change") { [self] id, event, dataString in
            print("eventListener Data:" + "\(dataString)")
            // Convert HTTP Response Data to a String
            if let dataString = dataString {
                let data: Data? = dataString.data(using: .utf8)
                if let data = data {
                    do {
                        let decodedData = try JSONDecoder().decode([Song].self, from: data)
                        DispatchQueue.main.async {
                            appState[\.songs] = decodedData
                            print("UPDATE SongList SSE")
                        }
                    } catch {
                        print("Error SSE playlist change")
                        
                    }
                }
            }
        }
        
        eventSource.addEventListener("sse:player_state_change") { [self] id, event, dataString in
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
                                appState[\.player.progress] = decodedData.progress
//                                self?.calculatePlayBarPosition()
                                appState[\.player.song] = sng
                                appState[\.player.isPlaying] = decodedData.is_playing
//                                self?.syncProgressBar()
//
//                                if self?.isPlaying ?? false {
//                                    self?.playerPlay()
//                                } else {
//                                    self?.playerPause()
//                                }
                                
                                KingfisherManager.shared.retrieveImage(with: URL(string: sng.cover_url)!, options: nil, progressBlock: nil, completionHandler: { image, error, cacheType, imageURL in
                                    appState[\.player.albumCover] = image ?? UIImage(imageLiteralResourceName: "albumPlaceholder")
                                })
                                
                            } else {
                                appState[\.player.progress] = 0
                            }
                            
//                            print(self?.normalizedPlaybackPosition)
                            
                        }
                    } catch {
                        print("Error SSE player_state_change ")
                        
                    }
                }
            }
        }
    }
}

