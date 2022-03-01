//
//  SuggestSongView.swift
//  encoreApp
//
//  Created by Nikolai Madlener on 15.06.20.
//  Copyright © 2020 NikolaiEtienne. All rights reserved.
//

import SwiftUI

struct SuggestSongView: View {
    @EnvironmentObject var appState: AppState
    
    @ObservedObject var searchResultListVM: SearchResultListVM
    @ObservedObject var songListVM: SongListVM
    @ObservedObject var playerStateVM: PlayerStateVM
    @State private var searchText : String = ""
    @State var showSessionExpiredAlert = false
    typealias JSONStandard = [String : AnyObject]
    
    init(searchResultListVM: SearchResultListVM, songListVM: SongListVM, playerStateVM: PlayerStateVM) {
        self.searchResultListVM = searchResultListVM
        self.songListVM = songListVM
        self.playerStateVM = playerStateVM
    }
    
    var body: some View {
        VStack(spacing: 0) {
            topBar.padding(.vertical)
            SearchBar(searchResultListVM: searchResultListVM, text: $searchText, songs: $searchResultListVM.items, placeholder: "Search")
            if searchResultListVM.items.isEmpty {
                VStack(alignment: .center) {
                    Spacer()
                    Group {
                        Text("find your favourite songs by ")
                        Text("artist, album or title.")
                    }.font(.system(size: 18, weight: .semibold))
                    .foregroundColor(Color("purpleblue"))
                    .padding(.horizontal)
                    .padding(.vertical, 2)
                    Spacer()
                    Spacer()
                }
            } else {
                List {
                    ForEach(searchResultListVM.items, id: \.self) { song in
                        SuggestSongCell(searchResultListVM: self.searchResultListVM, songListVM: self.songListVM, playerStateVM: self.playerStateVM, song: song)
                            .frame(height: 60)
                    }
                }.alert(isPresented: self.$showSessionExpiredAlert) {
                    Alert(title: Text("Session expired"),
                          message: Text("The host has ended the session."),
                          dismissButton: .destructive(Text("Leave"), action: {
                        self.appState.session.currentlyInSession = false
                          }))
                }.edgesIgnoringSafeArea(.all)
            }
            
            
        }.onAppear {
            self.getMembers(username: self.appState.user.username)
        }
    }
    
    var topBar: some View {
             ZStack {
                 RoundedRectangle(cornerRadius: 6)
                     .fill(Color.secondary)
                     .frame(width: 60, height: 4)
             }
         }
    
    func getMembers(username: String) {
        
        guard let url = URL(string: "https://api.encore-fm.com/users/"+"\(username)"+"/list") else {
            print("Invalid URL")
            return
        }
        var request = URLRequest(url: url)
        
        print("secret: " + self.appState.session.secret)
        print("sessionID: " + self.appState.session.sessionID)
        
        request.httpMethod = "GET"
        request.addValue(self.appState.session.secret, forHTTPHeaderField: "Authorization")
        request.addValue(self.appState.session.sessionID, forHTTPHeaderField: "Session")
        
        
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
                    let decodedData = try JSONDecoder().decode([UserListElement].self, from: data)
                    DispatchQueue.main.async {
                        
                    }
                } catch {
                    print("Error")
                    self.showSessionExpiredAlert = true
                    
                }
            }
            
        }
        task.resume()
    }
}

struct AddSongView_Previews: PreviewProvider {
    static var searchResultListVM = SearchResultListVM(username: "", secret: "", sessionID: "", clientToken: "")
    static var userListVM = UserListVM(username: "", sessionID: "")

    static var previews: some View {
        SuggestSongView(searchResultListVM: searchResultListVM, songListVM: SongListVM(username: "", sessionID: ""), playerStateVM: PlayerStateVM(username: "", sessionID: "", secret: ""))
    }
}
