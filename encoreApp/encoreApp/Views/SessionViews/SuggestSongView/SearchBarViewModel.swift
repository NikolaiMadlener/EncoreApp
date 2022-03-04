//
//  SearchBarViewModel.swift
//  encoreApp
//
//  Created by Nikolai Madlener on 02.03.22.
//  Copyright © 2022 NikolaiEtienne. All rights reserved.
//

import Foundation
import SwiftUI

// MARK: - ViewModel
extension SearchBar {
    @MainActor class ViewModel: ObservableObject {

        //State
        var items: Binding<[SpotifySearchPayload.Tracks.Item]>
        
        // Misc
        @Dependency(\.appState) private var appState
        init(items: Binding<[SpotifySearchPayload.Tracks.Item]>) {
            self.items = items
        }
        
        // Functions
        func searchSong(query: String) {
            let clientToken  = appState[\.session.clientToken]

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
                            self.items.wrappedValue = decodedData.tracks.items
                        }
                    } catch {
                        print("Error Decode")
                    }
                }
            }
            task.resume()
        }
    }
}
