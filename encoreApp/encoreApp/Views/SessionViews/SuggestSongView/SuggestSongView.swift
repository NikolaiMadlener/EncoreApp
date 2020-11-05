//
//  SuggestSongView.swift
//  encoreApp
//
//  Created by Nikolai Madlener on 15.06.20.
//  Copyright © 2020 NikolaiEtienne. All rights reserved.
//

import SwiftUI

struct SuggestSongView: View {
    @ObservedObject var searchResultListVM: SearchResultListVM
    @ObservedObject var userVM: UserVM
    @ObservedObject var songListVM: SongListVM
    @ObservedObject var playerStateVM: PlayerStateVM
    @State private var searchText : String = ""
    @State var showSessionExpiredAlert = false
    @Binding var currentlyInSession: Bool
    typealias JSONStandard = [String : AnyObject]
    
    init(searchResultListVM: SearchResultListVM, userVM: UserVM, songListVM: SongListVM, playerStateVM: PlayerStateVM, currentlyInSession: Binding<Bool>) {
        self.searchResultListVM = searchResultListVM
        self.userVM = userVM
        self.songListVM = songListVM
        self.playerStateVM = playerStateVM
        self._currentlyInSession = currentlyInSession
    }
    
    var body: some View {
        VStack(spacing: 0) {
            topBar.padding(.vertical)
            SearchBar(searchResultListVM: searchResultListVM, userVM: userVM, text: $searchText, songs: $searchResultListVM.items, placeholder: "Search")
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
                            self.currentlyInSession = false
                          }))
                }.edgesIgnoringSafeArea(.all)
            }
            
            
        }.onAppear {
            self.getMembers(username: self.userVM.username)
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
        
        print("secret: " + self.userVM.secret)
        print("sessionID: " + self.userVM.sessionID)
        
        request.httpMethod = "GET"
        request.addValue(self.userVM.secret, forHTTPHeaderField: "Authorization")
        request.addValue(self.userVM.sessionID, forHTTPHeaderField: "Session")
        
        
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
    static var userVM = UserVM()
    static var searchResultListVM = SearchResultListVM(userVM: userVM)
    static var userListVM = UserListVM(userVM: userVM, sessionID: nil)
    @State static var currentlyInSession = true
    static var previews: some View {
        SuggestSongView(searchResultListVM: searchResultListVM, userVM: userVM, songListVM: SongListVM(userVM: UserVM()), playerStateVM: PlayerStateVM(userVM: userVM), currentlyInSession: $currentlyInSession)
    }
}
