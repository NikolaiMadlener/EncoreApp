//
//  SearchBar.swift
//  encoreApp
//
//  Created by Etienne Köhler on 20.06.20.
//  Copyright © 2020 NikolaiEtienne. All rights reserved.
//

import Foundation
import SwiftUI
import UIKit

struct SearchBar: UIViewRepresentable {
    
    @Binding var text: String
    @Binding var userVM: UserVM
    @Binding var songs: [Song]
    var placeholder: String
    
    class Coordinator: NSObject, UISearchBarDelegate {
        
        @ObservedObject var musicController: MusicController = .shared
        @Binding var text: String
        @Binding var userVM: UserVM
        @Binding var songs: [Song]
        var items: [ItemPayload] = []
        var authToken: String = ""
        typealias JSONStandard = [String : AnyObject]
        
        init(text: Binding<String>, userVM: Binding<UserVM>, songs: Binding<[Song]>) {
            _text = text
            _userVM = userVM
            _songs = songs
        }
        
        func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
            text = searchText
            print("Secret: \(userVM.secret)")
            print("Access: \(musicController.getAccessToken())")
            getAuthToken()
            searchSong(query: text)
            sleep(2)
            print("SONGS: \(items[0])")
        }
        
        func searchSong(query: String) -> [String] {
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
            
            request.httpMethod = "GET"
            request.addValue(self.userVM.secret, forHTTPHeaderField: "Authorization")
            
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
            return songs
        }
        
        func searchSong2(query: String) {
            guard let url = URL(string: "https://api.spotify.com/v1/search") else {
                print("Invalid URL")
                return
                
            }
            
            var request = URLRequest(url: url)
            
            request.httpMethod = "GET"
            request.addValue(self.userVM.secret, forHTTPHeaderField: "Authorization")
            
            // HTTP Request Parameters which will be sent in HTTP Request Body
            //let postString = "userId=300&title=My urgent task&completed=false";
            // Set HTTP Request Body
            //request.httpBody = postString.data(using: String.Encoding.utf8);
            // Perform HTTP Request
            let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
                print("Hellooo")
                // Check for Error
                if let error = error {
                    print("Error took place \(error)")
                    return
                }
                
                // Convert HTTP Response Data to a String
                if let data = data, let dataString = String(data: data, encoding: .utf8) {
                    print("Response data string add:\n \(dataString)")
                    
                    do {
                        let decodedData = try JSONDecoder().decode(SpotifySearchPayload.self, from: data)
                        DispatchQueue.main.async {
                            if let tracks = decodedData.tracks {
                                self.items = tracks.items
                            }
                        }
                    } catch {
                        print("Error")
                    }
                }
            }
            task.resume()
        }
        
        func getAuthToken() {
            guard let url = URL(string: "https://api.encore-fm.com/users/"+"\(userVM.username)"+"/authToken") else {
                print("Invalid URL")
                return
                
            }
            
            var request = URLRequest(url: url)
            
            request.httpMethod = "GET"
            request.addValue(self.userVM.secret, forHTTPHeaderField: "Authorization")
            request.addValue(self.userVM.sessionID, forHTTPHeaderField: "Session")
            print("AuthSecret:\(self.userVM.secret)")
            print("SessionID:\(self.userVM.sessionID)")
            
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
                    print("Response data string add:\n \(dataString)")
                    
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
        }
    }
    
    
    
    
    func makeCoordinator() -> SearchBar.Coordinator {
        return Coordinator(text: $text, userVM: $userVM, songs: $songs)
    }
    
    func makeUIView(context: UIViewRepresentableContext<SearchBar>) -> UISearchBar {
        let searchBar = UISearchBar(frame: .zero)
        searchBar.delegate = context.coordinator
        searchBar.searchBarStyle = .minimal
        searchBar.autocapitalizationType = .none
        searchBar.placeholder = placeholder
        return searchBar
    }
    
    func updateUIView(_ uiView: UISearchBar, context: UIViewRepresentableContext<SearchBar>) {
        uiView.text = text
    }
}

