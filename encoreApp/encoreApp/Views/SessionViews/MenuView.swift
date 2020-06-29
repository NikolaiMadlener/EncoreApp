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
    @ObservedObject var networkModel: NetworkModel = .shared
    @ObservedObject var userListVM: UserListVM
    
    @Binding var showMenuSheet: Bool
    @Binding var currentlyInSession: Bool
    @State var showAlert = false
    @State var showSessionExpiredAlert = false
    @State var showShareSheet: Bool = false
    
    init(currentlyInSession: Binding<Bool>, showMenuSheet: Binding<Bool>) {
        self.userListVM = UserListVM(userVM: UserVM())
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
                    
                    QRCodeView(url: "encoreApp://\(self.networkModel.userVM.sessionID)").padding(10)
                    
                    Text("Let your friends scan the QR code \nor share the Session-Link to let them join. ").font(.footnote).multilineTextAlignment(.center)
                    Button(action: { self.showShareSheet.toggle() }) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 50).frame(width: geo.size.width*0.9, height: 50).foregroundColor(self.colorScheme == .dark ? Color("darkgray") : Color("lightgray"))
                            HStack {
                                Text("Share Session-Link")
                                    .foregroundColor(self.colorScheme == .dark ? Color.white : Color.black)
                                    .font(.system(size: 15))
                                    .padding(.leading, 30)
                                Spacer()
                                Image(systemName: "square.and.arrow.up")
                                    .foregroundColor(self.colorScheme == .dark ? Color.white : Color.black)
                                    .font(.system(size: 20))
                                    .padding(.trailing, 30)
                            }
                        }.padding(10)
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
                                                Text("Host")
                                            }
                                            else if member.username == self.networkModel.userVM.username {
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
                }
                VStack {
                    Spacer()
                    Button(action: { self.networkModel.userVM.isAdmin ? (self.showAlert = true) : (self.leaveSession(username: self.networkModel.userVM.username)) }) {
                        Text(self.networkModel.userVM.isAdmin ? "Delete Session" : "Leave Session")
                            .padding(15)
                            .background(Color.red)
                            .foregroundColor(Color.white)
                            .cornerRadius(25)
                        
                    }.alert(isPresented: self.$showAlert) {
                        Alert(title: Text("Delete Session"),
                              message: Text("By Deleting the current Session all Members will be kicked."),
                              primaryButton: .destructive(Text("Delete"), action: {
                                self.deleteSession(username: self.networkModel.userVM.username)
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
                }
                
            }.sheet(isPresented: self.$showShareSheet) {
                ActivityViewController(activityItems: ["encoreApp://\(self.networkModel.userVM.sessionID)"] as [Any], applicationActivities: nil)
            }
        }
    }
    
    //    func getMembers(username: String) {
    //
    //        guard let url = URL(string: "https://api.encore-fm.com/users/"+"\(username)"+"/list") else {
    //            print("Invalid URL")
    //            return
    //        }
    //        var request = URLRequest(url: url)
    //
    //        print("secret: " + self.user.secret)
    //        print("sessionID: " + self.user.sessionID)
    //
    //        request.httpMethod = "GET"
    //        request.addValue(self.user.secret, forHTTPHeaderField: "Authorization")
    //        request.addValue(self.user.sessionID, forHTTPHeaderField: "Session")
    //
    //
    //        // HTTP Request Parameters which will be sent in HTTP Request Body
    //        //let postString = "userId=300&title=My urgent task&completed=false";
    //        // Set HTTP Request Body
    //        //request.httpBody = postString.data(using: String.Encoding.utf8);
    //        // Perform HTTP Request
    //        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
    //
    //            // Check for Error
    //            if let error = error {
    //                print("Error took place \(error)")
    //                return
    //            }
    //
    //            // Convert HTTP Response Data to a String
    //            if let data = data, let dataString = String(data: data, encoding: .utf8) {
    //                print("Response data string:\n \(dataString)")
    //
    //                do {
    //                    let decodedData = try JSONDecoder().decode([UserListElement].self, from: data)
    //                    DispatchQueue.main.async {
    //                        self.members = decodedData
    //                        print(self.members)
    //                        print()
    //                    }
    //                } catch {
    //                    print("Error")
    //                    self.showSessionExpiredAlert = true
    //                    self.currentlyInSession = false
    //                }
    //            }
    //            self.currentlyInSession = true
    //        }
    //        task.resume()
    //    }
    
    func deleteSession(username: String) {
        
        guard let url = URL(string: "https://api.encore-fm.com/admin/"+"\(username)"+"/deleteSession") else {
            print("Invalid URL")
            return
        }
        var request = URLRequest(url: url)
        
        print("secret: " + networkModel.userVM.secret)
        print("sessionID: " + networkModel.userVM.sessionID)
        
        request.httpMethod = "DELETE"
        request.addValue(networkModel.userVM.secret, forHTTPHeaderField: "Authorization")
        request.addValue(networkModel.userVM.sessionID, forHTTPHeaderField: "Session")
        
        
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
        
        print("secret: " + networkModel.userVM.secret)
        print("sessionID: " + networkModel.userVM.sessionID)
        
        request.httpMethod = "DELETE"
        request.addValue(networkModel.userVM.secret, forHTTPHeaderField: "Authorization")
        request.addValue(networkModel.userVM.sessionID, forHTTPHeaderField: "Session")
        
        
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
    @State static var currentlyInSession = false
    @State static var showMenuSheet = false
    
    static var previews: some View {
        MenuView(currentlyInSession: $currentlyInSession, showMenuSheet: $showMenuSheet)
    }
}