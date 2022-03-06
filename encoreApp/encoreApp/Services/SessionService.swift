//
//  SessionService.swift
//  encoreApp
//
//  Created by Nikolai Madlener on 04.03.22.
//  Copyright © 2022 NikolaiEtienne. All rights reserved.
//

import Foundation
import SwiftUI

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
    
    func upvote(songID: String) {
        let username = appState[\.user.username]
        let sessionID = appState[\.session.sessionID]
        let secret = appState[\.session.secret]
        
        guard let url = URL(string: "https://api.encore-fm.com/users/"+"\(username)"+"/vote/"+"\(songID)"+"/up") else {
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
    
    func downvote(songID: String) {
        let username = appState[\.user.username]
        let sessionID = appState[\.session.sessionID]
        let secret = appState[\.session.secret]
        
        guard let url = URL(string: "https://api.encore-fm.com/users/"+"\(username)"+"/vote/"+"\(songID)"+"/down") else {
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
    
    func suggestSong(songID: String) {
        let username = appState[\.user.username]
        let sessionID = appState[\.session.sessionID]
        let secret = appState[\.session.secret]
        
        guard let url = URL(string: "https://api.encore-fm.com/users/"+"\(username)"+"/suggest/"+"\(songID)") else {
            print("Invalid URL")
            return
            
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
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
                    let decodedData = try JSONDecoder().decode(Song.self, from: data)
                    print("Successfully post of suggest song: \(decodedData.name)")
                } catch {
                    print("Error suggest Song")
                }
            }
        }
        task.resume()
    }
    
//    func searchSong(query: String) async throws -> [SpotifySearchPayload.Tracks.Item] {
//        let clientToken  = appState[\.session.clientToken]
//        var result: [SpotifySearchPayload.Tracks.Item] = []
//        
//        guard var components = URLComponents(string: "https://api.spotify.com/v1/search") else {
//            print("Invalid URL")
//            return []
//        }
//        components.queryItems = [
//            URLQueryItem(name: "q", value: query),
//            URLQueryItem(name: "type", value: "track")
//        ]
//        var request = URLRequest(url: components.url!)
//        request.httpMethod = "GET"
//        request.addValue("Bearer " + clientToken, forHTTPHeaderField: "Authorization")
//
//        let (data, response) = try await URLSession.shared.data(for: request)
//        
//        // make sure no network error occured
//        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
//            throw LoginError.invalidServerResponse
//        }
//        
//        // make sure this JSON is in the format we expect
//        guard let json = try JSONSerialization.jsonObject(with: data, options: []) as? SpotifySearchPayload else {
//            throw LoginError.unsupportedFormat
//        }
//        
//        return json.tracks.items
//    }
    
    func searchSong(query: String, binding: Binding<[SpotifySearchPayload.Tracks.Item]>){
        let clientToken  = appState[\.session.clientToken]
        var binding: Binding<[SpotifySearchPayload.Tracks.Item]> = binding
        
        guard var components = URLComponents(string: "https://api.spotify.com/v1/search") else {
            print("Invalid URL")
            return
        }
        
        components.queryItems = [
            URLQueryItem(name: "q", value: query),
            URLQueryItem(name: "type", value: "track")
        ]
        var request = URLRequest(url: components.url!)
        request.httpMethod = "GET"
        request.addValue("Bearer " + clientToken, forHTTPHeaderField: "Authorization")
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            // Check for Error
            if let error = error {
                print("Error took place \(error)")
                return
            }
            
            // Convert HTTP Response Data to a String
            if let data = data, let dataString = String(data: data, encoding: .utf8) {
                print("Response data string search:\n \(dataString)")
                do {
                    let decodedData = try JSONDecoder().decode(SpotifySearchPayload.self, from: data)
                    DispatchQueue.main.async {
                        binding.wrappedValue = decodedData.tracks.items
                    }
                } catch {
                    print("Error Decode")
                }
            }
        }
        task.resume()
    }
}

