//
//  SearchResultListVM.swift
//  encoreApp
//
//  Created by Etienne Köhler on 24.06.20.
//  Copyright © 2020 NikolaiEtienne. All rights reserved.
//

import Foundation

class SearchResultListVM: ObservableObject {
    var userVM: UserVM
    @Published var items: [SpotifySearchPayload.Tracks.Item] = []
    @Published var showNetworkAlert = false
    var authToken = ""
    var auth_url = ""
    typealias JSONStandard = [String : AnyObject]
    
    init(userVM: UserVM) {
        self.userVM = userVM
    }
    
    func getAuthToken() {
        guard let url = URL(string: "https://api.encore-fm.com/users/"+"\(userVM.username)"+"/authToken") else {
            print("Invalid URL")
            return
            
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue(userVM.secret, forHTTPHeaderField: "Authorization")
        request.addValue(userVM.sessionID, forHTTPHeaderField: "Session")
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            // Check for Error
            if let error = error {
                print("Error took place \(error)")
                return
            }
            
            // Convert HTTP Response Data to a String
            if let data = data, let dataString = String(data: data, encoding: .utf8) {
                print("Response data string authToken:\n \(dataString)")
                do {
                    if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                        self.authToken = json["access_token"] as! String
                    }
                } catch {
                    print("Error")
                }
            }
        }
        task.resume()
    }
    
    func suggestSong(songID: String) {
        guard let url = URL(string: "https://api.encore-fm.com/users/"+"\(userVM.username)"+"/suggest/"+"\(songID)") else {
            print("Invalid URL")
            return
            
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue(userVM.secret, forHTTPHeaderField: "Authorization")
        request.addValue(userVM.sessionID, forHTTPHeaderField: "Session")
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            // Check for Error
            if let error = error {
                print("Error took place \(error)")
                DispatchQueue.main.async {
                    self.showNetworkAlert = true
                }
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
    
    func searchSong(query: String) {
        print("CLIENTTOKEN\(userVM.clientToken)")
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
        request.addValue("Bearer "+userVM.clientToken, forHTTPHeaderField: "Authorization")
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            // Check for Error
            if let error = error {
                print("Error took place \(error)")
                DispatchQueue.main.async {
                    self.showNetworkAlert = true
                }
                return
            }
            
            // Convert HTTP Response Data to a String
            if let data = data, let dataString = String(data: data, encoding: .utf8) {
                print("Response data string search:\n \(dataString)")
                do {
                    let decodedData = try JSONDecoder().decode(SpotifySearchPayload.self, from: data)
                    DispatchQueue.main.async {
                        self.items = decodedData.tracks.items
                    }
                } catch {
                    print("Error Decode")
                }
            }
        }
        task.resume()
    }
}
