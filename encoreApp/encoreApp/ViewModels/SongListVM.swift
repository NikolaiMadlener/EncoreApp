//
//  SongListVM.swift
//  encoreApp
//
//  Created by Nikolai Madlener on 16.06.20.
//  Copyright © 2020 NikolaiEtienne. All rights reserved.
//

import Foundation
import IKEventSource
import WidgetKit

class SongListVM: ObservableObject {
    @Published var songs: [Song] = []
    var serverURL: URL
    var userVM: UserVM
    var eventSource: EventSource
    var lastEventId: String?
    
    init(userVM: UserVM) {
        print("INIT SONGLISTVM")
        self.userVM = userVM
        
        serverURL = URL(string: "https://api.encore-fm.com/events/"+"\(userVM.username)"+"/\(userVM.sessionID)")!
        eventSource = EventSource(url: serverURL)
        
        eventSource.connect()
        
        eventSource.onComplete { [weak self] statusCode, reconnect, error in
            DispatchQueue.main.asyncAfter(deadline: .now()) { [weak self] in
                self?.eventSource.connect()
            }
        }
        
        eventSource.addEventListener("sse:playlist_change") { [weak self] id, event, dataString in
            print("eventListener Data:" + "(dataString)")
            // Convert HTTP Response Data to a String
            if let dataString = dataString {
                let data: Data? = dataString.data(using: .utf8)
                if let data = data {
                    do {
                        let decodedData = try JSONDecoder().decode([Song].self, from: data)
                        DispatchQueue.main.async {
                            self?.songs = decodedData
                            print("UPDATE SongList SSE")
                            print(self?.songs)
                            print()
                            
                            if #available(iOS 14.0, *) {
            
                                 do {
                                    let encoder = JSONEncoder()
                                    if let encoded = try? encoder.encode(decodedData) {
                                        let container = UserDefaults(suiteName:"group.com.bitkitApps.encore")
                                        container?.set(encoded, forKey: "sharedSongList")
                                    }
                                    
                                      WidgetCenter.shared.reloadAllTimelines()

                                      } catch {
                                        print("Unable to encode WidgetDay: \(error.localizedDescription)")
                                   }
                            } else {
                                // Fallback on earlier versions
                            }
                            
                            
                        }
                    } catch {
                        print("Error SSE playlist change")
                        
                    }
                }
            }
        }
    }
    
    func reconnect() {
        print("reconnect")
        //eventSource.connect(lastEventId: lastEventId)
        //lastEventId = eventSource.lastEventId
    }
}
