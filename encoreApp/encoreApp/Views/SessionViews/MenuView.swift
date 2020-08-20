//
//  MenuView.swift
//  encoreApp
//
//  Created by Nikolai Madlener on 29.05.20.
//  Copyright © 2020 NikolaiEtienne. All rights reserved.
//

import SwiftUI

struct MenuView: View {
    @Environment(\.colorScheme) var colorScheme
    @ObservedObject var userVM: UserVM
    @ObservedObject var userListVM: UserListVM
    @ObservedObject var playerStateVM: PlayerStateVM
    
    @Binding var showMenuSheet: Bool
    @Binding var currentlyInSession: Bool
    @State var showAlert = false
    @State var showSessionExpiredAlert = false
    @State var showShareSheet: Bool = false
    
    init(userVM: UserVM, playerStateVM: PlayerStateVM, currentlyInSession: Binding<Bool>, showMenuSheet: Binding<Bool>) {
        self.userVM = userVM
        self.userListVM = UserListVM(userVM: userVM)
        self.playerStateVM = playerStateVM
        self._currentlyInSession = currentlyInSession
        self._showMenuSheet = showMenuSheet
    }
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                VStack {
                    Button(action: { self.showMenuSheet = false }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(self.colorScheme == .dark ? Color("darkgray") : Color("lightgray"))
                            .font(.largeTitle)
                            .padding()
                    }
                    
                    QRCodeView(url: "encoreApp://\(self.userVM.sessionID)").padding(10)
                    
                    Text("Let your friends scan the QR code \nor share the Session-Link to let them join. ").font(.footnote).multilineTextAlignment(.center)
                    Button(action: { self.showShareSheet.toggle() }) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 15).frame(maxWidth: .infinity, maxHeight: 50).foregroundColor(self.colorScheme == .dark ? Color("darkgray") : Color("lightgray"))
                            HStack {
                                Text("Share Session-Link")
                                    .foregroundColor(self.colorScheme == .dark ? Color.white : Color.black)
                                    .font(.system(size: 15))
                                    .padding(.leading)
                                Spacer()
                                Image(systemName: "square.and.arrow.up")
                                    .foregroundColor(self.colorScheme == .dark ? Color.white : Color.black)
                                    .font(.system(size: 20))
                                    .padding(.trailing)
                            }
                        }.padding(.horizontal, 25)
                    }
                    VStack() {
                        List {
                            VStack {
                                ForEach(self.userListVM.members, id: \.self) { member in
                                    VStack {
                                        HStack {
                                            if member.is_admin {
                                                Text("\(member.username)").bold()
                                            } else {
                                                Text("\(member.username)")
                                            }
                                            Spacer()
                                            if member.is_admin {
                                                Image(systemName: "music.house")
                                            }
                                            else if member.username == self.userVM.username {
                                                Text("You")
                                            }
                                        }
                                        Divider()
                                    }
                                }
                            }
                            
                        }.padding()
                            .onAppear{ UITableView.appearance().separatorColor = .clear }
                    }
                    Spacer()
                }.alert(isPresented: self.$showSessionExpiredAlert) {
                    Alert(title: Text("Session expired"),
                          message: Text("The Host has ended the Session."),
                          dismissButton: .destructive(Text("Leave"), action: {
                            self.currentlyInSession = false
                          }))
                }.padding(.vertical)
                VStack {
                    Spacer()
                    Button(action: { self.userVM.isAdmin ? (self.showAlert = true) : (self.leaveSession(username: self.userVM.username)) }) {
                        Text(self.userVM.isAdmin ? "Delete Session" : "Leave Session")
                            .modifier(ButtonHeavyModifier(isDisabled: false, backgroundColor: Color.red, foregroundColor: Color.white))
                        
                    }.alert(isPresented: self.$showAlert) {
                        Alert(title: Text("Delete Session"),
                              message: Text("By Deleting the current Session all Members will be kicked."),
                              primaryButton: .destructive(Text("Delete"), action: {
                                self.playerStateVM.playerPause()
                                self.deleteSession(username: self.userVM.username)
                              }),
                              secondaryButton: .cancel(Text("Cancel"), action: {
                                self.showAlert = false
                              }))
                    }.padding(.vertical)
                    
                }
                
            }.sheet(isPresented: self.$showShareSheet) {
                ActivityViewController(activityItems: ["encoreApp://\(self.userVM.sessionID)"] as [Any], applicationActivities: nil)
            }.onAppear{
                self.getMembers(username: self.userVM.username)
            }
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
    
    func deleteSession(username: String) {
        
        guard let url = URL(string: "https://api.encore-fm.com/admin/"+"\(username)"+"/deleteSession") else {
            print("Invalid URL")
            return
        }
        var request = URLRequest(url: url)
        
        print("secret: " + userVM.secret)
        print("sessionID: " + userVM.sessionID)
        
        request.httpMethod = "DELETE"
        request.addValue(userVM.secret, forHTTPHeaderField: "Authorization")
        request.addValue(userVM.sessionID, forHTTPHeaderField: "Session")
        
        
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
            }
            self.currentlyInSession = false
        }
        task.resume()
    }
    
    func leaveSession(username: String) {
        
        guard let url = URL(string: "https://api.encore-fm.com/users/"+"\(username)"+"/leave") else {
            print("Invalid URL")
            return
        }
        var request = URLRequest(url: url)
        
        print("secret: " + userVM.secret)
        print("sessionID: " + userVM.sessionID)
        
        request.httpMethod = "DELETE"
        request.addValue(userVM.secret, forHTTPHeaderField: "Authorization")
        request.addValue(userVM.sessionID, forHTTPHeaderField: "Session")
        
        
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
            }
            self.currentlyInSession = false
        }
        task.resume()
    }
}

struct MenuView_Previews: PreviewProvider {
    static var userVM = UserVM()
    static var playerStateVM = PlayerStateVM(userVM: userVM)
    @State static var currentlyInSession = false
    @State static var showMenuSheet = false
    
    static var previews: some View {
        MenuView(userVM: userVM, playerStateVM: playerStateVM, currentlyInSession: $currentlyInSession, showMenuSheet: $showMenuSheet)
    }
}
