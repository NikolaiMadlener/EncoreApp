//
//  SongListCellViewModel.swift
//  encoreApp
//
//  Created by Nikolai Madlener on 02.03.22.
//  Copyright © 2022 NikolaiEtienne. All rights reserved.
//

import Foundation
import SwiftUI

// MARK: - ViewModel
extension SongListCell {
    @MainActor class ViewModel: ObservableObject {
        
        // State
        @Published var voteState: VoteState = VoteState.NEUTRAL
        @Published var currentImage: Image = Image("albumPlaceholder")
        @Published var username: String = ""
        var song: Song
        var rank: Int
        
        // Misc
        @Dependency(\.appState) private var appState
        private var cancelBag = CancelBag()
        init(song: Song, rank: Int) {
            self.song = song
            self.rank = rank
            
            cancelBag.collect {
                appState.map(\.user.username)
                    .removeDuplicates()
                    .assign(to: \.username, on: self)
            }
        }
        
        // Functions
        func upvote() {
            let username = appState[\.user.username]
            let sessionID = appState[\.session.sessionID]
            let secret = appState[\.session.secret]
            
            guard let url = URL(string: "https://api.encore-fm.com/users/"+"\(username)"+"/vote/"+"\(self.song.id)"+"/up") else {
                print("Invalid URL")
                return
                
            }
            var request = URLRequest(url: url)
            
            request.httpMethod = "POST"
            request.addValue(secret, forHTTPHeaderField: "Authorization")
            request.addValue(sessionID, forHTTPHeaderField: "Session")
            
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
                        let decodedData = try JSONDecoder().decode([Song].self, from: data)
                        DispatchQueue.main.async {
                            
                        }
                    } catch {
                        print("Error Upvote")
                        //self.showSessionExpiredAlert = true
                        //self.currentlyInSession = false
                    }
                }
            }
            task.resume()
        }
        
        func downvote() {
            let username = appState[\.user.username]
            let sessionID = appState[\.session.sessionID]
            let secret = appState[\.session.secret]
            
            guard let url = URL(string: "https://api.encore-fm.com/users/"+"\(username)"+"/vote/"+"\(self.song.id)"+"/down") else {
                print("Invalid URL")
                return
            }
            var request = URLRequest(url: url)
            
            request.httpMethod = "POST"
            request.addValue(secret, forHTTPHeaderField: "Authorization")
            request.addValue(sessionID, forHTTPHeaderField: "Session")
            
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
                        let decodedData = try JSONDecoder().decode([[Song]].self, from: data)
                        DispatchQueue.main.async {
                            
                        }
                    } catch {
                        print("Error Downvote")
                        //self.showSessionExpiredAlert = true
                        //self.currentlyInSession = false
                    }
                }
            }
            task.resume()
        }
    }
}
