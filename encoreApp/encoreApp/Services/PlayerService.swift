//
//  PlayerService.swift
//  encoreApp
//
//  Created by Nikolai Madlener on 04.03.22.
//  Copyright © 2022 NikolaiEtienne. All rights reserved.
//

import Foundation

// MARK: - Service
struct PlayerService {
    @Dependency(\.appState) private var appState
    
    func playerPlay() {
        let username = appState[\.user.username]
        let sessionID = appState[\.session.sessionID]
        let secret = appState[\.session.secret]
        
        guard let url = URL(string: "https://api.encore-fm.com/users/"+"\(username)"+"/player/play") else {
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
                //self.isPlay = true
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
        let username = appState[\.user.username]
        let sessionID = appState[\.session.sessionID]
        let secret = appState[\.session.secret]
        
        guard let url = URL(string: "https://api.encore-fm.com/users/"+"\(username)"+"/player/pause") else {
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
                //self.isPlay = false
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
    
    func playerSkipNext() {
        let username = appState[\.user.username]
        let sessionID = appState[\.session.sessionID]
        let secret = appState[\.session.secret]
        
        guard let url = URL(string: "https://api.encore-fm.com/users/"+"\(username)"+"/player/skip") else {
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
//                self.isPlay.wrappedValue = true
            }
        }
        task.resume()
    }
    
}
