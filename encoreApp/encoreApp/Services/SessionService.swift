//
//  SessionService.swift
//  encoreApp
//
//  Created by Nikolai Madlener on 04.03.22.
//  Copyright © 2022 NikolaiEtienne. All rights reserved.
//

import Foundation

// MARK: - Service
struct SessionService {
    @Dependency(\.appState) private var appState
    
    func getMembers(sessionID: String? = nil) {
        let username = appState[\.user.username]
        let sessionID = sessionID ?? appState[\.session.sessionID]
        let secret = appState[\.session.secret]
        
        guard let url = URL(string: "https://api.encore-fm.com/users/"+"\(username)"+"/list") else {
            print("Invalid URL")
            return
        }
        var request = URLRequest(url: url)
        
        request.httpMethod = "GET"
        request.addValue(secret, forHTTPHeaderField: "Authorization")
        request.addValue(sessionID, forHTTPHeaderField: "Session")
        
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
                    let decodedData = try JSONDecoder().decode([UserListElement].self, from: data)
                    DispatchQueue.main.async {
                        self.appState[\.members] = decodedData
                    }
                } catch {
//                    self.showSessionExpiredAlert = true
                }
            }
        }
        task.resume()
    }
    
    func deleteSession() {
        let username = appState[\.user.username]
        let sessionID = appState[\.session.sessionID]
        let secret = appState[\.session.secret]
        
        guard let url = URL(string: "https://api.encore-fm.com/admin/"+"\(username)"+"/deleteSession") else {
            print("Invalid URL")
            return
        }
        var request = URLRequest(url: url)
        
        request.httpMethod = "DELETE"
        request.addValue(secret, forHTTPHeaderField: "Authorization")
        request.addValue(sessionID, forHTTPHeaderField: "Session")

        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            
            // Check for Error
            if let error = error {
                print("Error took place \(error)")
                return
            }
            
            // Convert HTTP Response Data to a String
            if let data = data, let dataString = String(data: data, encoding: .utf8) {
                print("Response data string:\n \(dataString)")
            }
            DispatchQueue.main.async {
                self.appState[\.session.currentlyInSession] = false
            }
        }
        task.resume()
    }
    
    func leaveSession() {
        let username = appState[\.user.username]
        let sessionID = appState[\.session.sessionID]
        let secret = appState[\.session.secret]
        
        guard let url = URL(string: "https://api.encore-fm.com/users/"+"\(username)"+"/leave") else {
            print("Invalid URL")
            return
        }
        var request = URLRequest(url: url)
        
        request.httpMethod = "DELETE"
        request.addValue(secret, forHTTPHeaderField: "Authorization")
        request.addValue(sessionID, forHTTPHeaderField: "Session")
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            
            // Check for Error
            if let error = error {
                print("Error took place \(error)")
                return
            }
            
            // Convert HTTP Response Data to a String
            if let data = data, let dataString = String(data: data, encoding: .utf8) {
                print("Response data string leave:\n \(dataString)")
            }
            
            DispatchQueue.main.async {
                self.appState[\.session.currentlyInSession] = false
            }
        }
        task.resume()
    }
}

