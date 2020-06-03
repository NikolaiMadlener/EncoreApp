//
//  MenuView.swift
//  encoreApp
//
//  Created by Nikolai Madlener on 29.05.20.
//  Copyright © 2020 NikolaiEtienne. All rights reserved.
//

import SwiftUI

struct MenuView: View {
    @ObservedObject var user: User
    @Binding var currentlyInSession: Bool
    @State var showAlert = false
    @State var showSessionExpiredAlert = false
    @State var members: [UserListElement] = []
    
    var body: some View {
        VStack {
            Spacer().frame(height: 50)
            Image("qrcode").padding()
            Text("Copy the Session ID and share it with your Friends").font(.footnote)
            HStack {
                Text("\(self.user.sessionID)").font(.caption)
                Button(action: { UIPasteboard.general.string = self.user.sessionID }) {
                    Image(systemName: "doc.on.clipboard")
                    
                }
            }.padding(10)
                .overlay(
                    RoundedRectangle(cornerRadius: 20).stroke(Color.gray, lineWidth: 1)
            ).padding()
            VStack() {
                HStack {
                    Text("Members").font(.title)
                    Spacer()
                }.padding(.bottom, 5)
                ForEach(members, id: \.self) { member in
                    VStack {
                        HStack {
                            if member.is_admin {
                                Text("\(member.username)").bold()
                            } else {
                                Text("\(member.username)")
                            }
                            Spacer()
                            if member.is_admin {
                                Text("Host")
                            }
                            else if member.username == self.user.username {
                                Text("You")
                            }
                        }
                        Divider()
                    }
                }
            }.padding()
            Spacer()
            Button(action: { self.user.isAdmin ? (self.showAlert = true) : (self.leaveSession(username: self.user.username)) }) {
                Text( user.isAdmin ? "Delete Session" : "Leave Session")
                    .padding(15)
                    .background(Color.red)
                    .foregroundColor(Color.white)
                    .cornerRadius(25)
                
            }.alert(isPresented: $showAlert) {
                Alert(title: Text("Delete Session"),
                      message: Text("By Deleting the current Session all Members will be kicked."),
                      primaryButton: .destructive(Text("Delete"), action: {
                        self.deleteSession(username: self.user.username)
                      }),
                      secondaryButton: .cancel(Text("Cancel"), action: {
                        self.showAlert = false
                      }))
//            }.alert(isPresented: $showSessionExpiredAlert) {
//                Alert(title: Text("Session Expired"),
//                      message: Text("The Session was closed by the Host."),
//                      dismissButton: .default(Text("OK"))
//                )
            }.padding()
        }.onAppear{ print("onappear")
            self.getMembers(username: self.user.username) }
    }
    
    func getMembers(username: String) {
        
        guard let url = URL(string: "https://api.encore-fm.com/users/"+"\(username)"+"/list") else {
            print("Invalid URL")
            return
        }
        var request = URLRequest(url: url)
        
        print("secret: " + self.user.secret)
        print("sessionID: " + self.user.sessionID)
        
        request.httpMethod = "GET"
        request.addValue(self.user.secret, forHTTPHeaderField: "Authorization")
        request.addValue(self.user.sessionID, forHTTPHeaderField: "Session")
        
        
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
                        self.members = decodedData
                        print(self.members)
                        print()
                    }
                } catch {
                    print("Error")
                    self.showSessionExpiredAlert = true
                    self.currentlyInSession = false
                }
            }
            self.currentlyInSession = true
        }
        task.resume()
    }
    
    func deleteSession(username: String) {
        
        guard let url = URL(string: "https://api.encore-fm.com/admin/"+"\(username)"+"/deleteSession") else {
            print("Invalid URL")
            return
        }
        var request = URLRequest(url: url)
        
        print("secret: " + self.user.secret)
        print("sessionID: " + self.user.sessionID)
        
        request.httpMethod = "DELETE"
        request.addValue(self.user.secret, forHTTPHeaderField: "Authorization")
        request.addValue(self.user.sessionID, forHTTPHeaderField: "Session")
        
        
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
        
        print("secret: " + self.user.secret)
        print("sessionID: " + self.user.sessionID)
        
        request.httpMethod = "DELETE"
        request.addValue(self.user.secret, forHTTPHeaderField: "Authorization")
        request.addValue(self.user.sessionID, forHTTPHeaderField: "Session")
        
        
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
    @State static var signInSuccess = false
    @State static var sessionID = "b9b314695f504bfa66250d312ce5626d"
    static var user = User()
    
    static var previews: some View {
        MenuView(user: user, currentlyInSession: $signInSuccess)
    }
}
