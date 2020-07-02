//
//  SongListVM.swift
//  encoreApp
//
//  Created by Nikolai Madlener on 16.06.20.
//  Copyright © 2020 NikolaiEtienne. All rights reserved.
//

import Foundation
import IKEventSource

class SongListVM: ObservableObject {
    @Published var songs: [Song] = []
    var serverURL: URL
    var userVM: UserVM
    var eventSource: EventSource
    
    init(userVM: UserVM) {
        self.userVM = userVM
        
        serverURL = URL(string: "https://api.encore-fm.com/events/"+"\(userVM.username)"+"/\(userVM.sessionID)")!
        eventSource = EventSource(url: serverURL)
        
        eventSource.connect()
        
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
                        }
                    } catch {
                        print("Error SSE playlist change")
                        
                    }
                }
            }
        }
    }
}
