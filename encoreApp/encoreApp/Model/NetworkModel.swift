//
//  NetworkModel.swift
//  encoreApp
//
//  Created by Etienne Köhler on 24.06.20.
//  Copyright © 2020 NikolaiEtienne. All rights reserved.
//

import Foundation

public class NetworkModel: ObservableObject {
    static let shared = NetworkModel()
    @Published var userVM = UserVM()
    @Published var items: [SpotifySearchPayload.Tracks.Item] = []
    var authToken = ""
    var clientToken = ""
    var auth_url = ""
    typealias JSONStandard = [String : AnyObject]
    
    
    func getAuthToken() {
        print("AuthStart")
        guard let url = URL(string: "https://api.encore-fm.com/users/"+"\(userVM.username)"+"/authToken") else {
            print("Invalid URL")
            return
            
        }
        
        var request = URLRequest(url: url)
        
        request.httpMethod = "GET"
        request.addValue(userVM.secret, forHTTPHeaderField: "Authorization")
        request.addValue(userVM.sessionID, forHTTPHeaderField: "Session")
        print("AuthSecret:\(userVM.secret)")
        print("SessionID:\(userVM.sessionID)")
        print("Username:\(userVM.username)")
        
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
                print("Response data string authToken:\n \(dataString)")
                
                do {
                    if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                        // try to read out a string array
                        self.authToken = json["access_token"] as! String
                    }
                } catch {
                    print("Error")
                }
            }
        }
        task.resume()
        print("Got Token")
        print("AuthEnd")
    }
    
    func getClientToken() {
        print("AuthStart")
        guard let url = URL(string: "https://api.encore-fm.com/users/"+"\(userVM.username)"+"/clientToken") else {
            print("Invalid URL")
            return
            
        }
        
        var request = URLRequest(url: url)
        
        request.httpMethod = "GET"
        request.addValue(userVM.secret, forHTTPHeaderField: "Authorization")
        request.addValue(userVM.sessionID, forHTTPHeaderField: "Session")
        print("AuthSecret:\(userVM.secret)")
        print("SessionID:\(userVM.sessionID)")
        print("Username:\(userVM.username)")
        
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
                print("Response data string clientToken:\n \(dataString)")
                
                do {
                    if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                        // try to read out a string array
                        self.clientToken = json["access_token"] as! String
                    }
                } catch {
                    print("Error")
                }
            }
        }
        task.resume()
        print("Got Token")
        print("AuthEnd")
    }
    
    func searchSong(query: String) -> [String] {
        print("SearchStart")
        var songs: [String] = []
        guard var components = URLComponents(string: "https://api.spotify.com/v1/search") else {
            print("Invalid URL")
            return []
            
        }
        
        components.queryItems = [
            URLQueryItem(name: "q", value: query),
            URLQueryItem(name: "type", value: "track")
        ]
        var request = URLRequest(url: components.url!)
        
        print("ClientToken:\(clientToken)")
        request.httpMethod = "GET"
        request.addValue("Bearer "+clientToken, forHTTPHeaderField: "Authorization")
        
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
                print("Response data string songs:\n \(dataString)")
                
                do {
                    var readableJSON = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as! JSONStandard
                    print(readableJSON)
                    if let tracks = readableJSON["tracks"] as? JSONStandard {
                        if let items = tracks["items"] {
                            for index in 0..<items.count {
                                let item = items[index].value as! JSONStandard
                                let name = item["name"] as! String
                                songs.append(name)
                            }
                        }
                    }
                } catch {
                    print("Error")
                }
            }
        }
        task.resume()
        print("SearchEnd")
        print("Got Songs")
        return songs
    }
    
    func searchSong2(query: String) {
        print("SearchStart")
        var songs: [String] = []
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
        request.addValue("Bearer "+clientToken, forHTTPHeaderField: "Authorization")
        
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
            
            //var items: [Item] = []
            
            // Convert HTTP Response Data to a String
            if let data = data, let dataString = String(data: data, encoding: .utf8) {
                print("Response data string search:\n \(dataString)")
                
                do {
                    let decodedData = try JSONDecoder().decode(SpotifySearchPayload.self, from: data)
                    //print("Tracksdec:\(decodedData.tracks)")
                    
                    DispatchQueue.main.async {
                        self.items = decodedData.tracks.items
                        for item in self.items {
                            print(item.name)
                        }
                    }
                } catch {
                    print("Error Decode")
                }
            }
        }
        task.resume()
    }
}
