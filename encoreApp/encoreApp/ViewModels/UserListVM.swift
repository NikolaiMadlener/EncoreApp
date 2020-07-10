//
//  SSE.swift
//  encoreApp
//
//  Created by Nikolai Madlener on 11.06.20.
//  Copyright © 2020 NikolaiEtienne. All rights reserved.
//

import Foundation
import IKEventSource

class UserListVM: ObservableObject {
    @Published var members: [UserListElement] = []
    var serverURL: URL
    var userVM: UserVM
    var eventSource: EventSource
    
    init(userVM: UserVM) {
        self.userVM = userVM
        
        serverURL = URL(string: "https://api.encore-fm.com/events/"+"\(userVM.username)/"+"\(userVM.sessionID)")!
        eventSource = EventSource(url: serverURL)
        
        eventSource.connect()
        
        eventSource.onComplete { [weak self] statusCode, reconnect, error in
            DispatchQueue.main.asyncAfter(deadline: .now()) { [weak self] in
                self?.eventSource.connect()
            }
        }
        
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
                        print("Error SSE user list change")
                        
                    }
                }
            }  
        }
    }
}
