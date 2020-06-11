//
//  SSE.swift
//  encoreApp
//
//  Created by Nikolai Madlener on 11.06.20.
//  Copyright © 2020 NikolaiEtienne. All rights reserved.
//

import Foundation
import IKEventSource

class SSE: ObservableObject {
    @Published var members: [UserListElement] = []
    var serverURL: URL
    var user: User
    var eventSource: EventSource
    
    init(user: User) {
        self.user = user
        
        serverURL = URL(string: "https://api.encore-fm.com/events/"+"\(user.username)/"+"\(user.sessionID)")!
        eventSource = EventSource(url: serverURL)
        
        eventSource.connect()
        
        eventSource.addEventListener("sse:user_list_change") { [weak self] id, event, dataString in
            print("eventListener Data:" + "\(dataString)")
            // Convert HTTP Response Data to a String
            if let dataString = dataString {
                let data: Data? = dataString.data(using: .utf8)
                if let data = data {
                    do {
                        let decodedData = try JSONDecoder().decode([UserListElement].self, from: data)
                        DispatchQueue.main.async {
                            self?.members = decodedData
                            
                            print()
                        }
                    } catch {
                        print("Error")
                        
                    }
                }
            }  
        }
    }
}
