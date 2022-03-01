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
    @EnvironmentObject var appState: AppState
    
    @ObservedObject var userListVM: UserListVM
    @ObservedObject var playerStateVM: PlayerStateVM
    
    @Binding var showMenuSheet: Bool
    @State var showAlert = false
    @State var showSessionExpiredAlert = false
    @State var showShareSheet: Bool = false
    @State var showPopupQRCode: Bool = false
    
    init(username: String, sessionID: String, playerStateVM: PlayerStateVM, showMenuSheet: Binding<Bool>) {
        self.userListVM = UserListVM(username: username, sessionID: sessionID)
        self.playerStateVM = playerStateVM
        self._showMenuSheet = showMenuSheet
    }
    
    var body: some View {
        GeometryReader { geo in
            
            VStack(spacing: 0) {
                topBar
                
                sessionTitle
                
                qrCode
                
                shareLinkButton
                
                VStack {
                    membersList
                    Spacer()
                }.modifier(BlueCardModifier())
                
                leaveButton
            }
            
            .sheet(isPresented: self.$showShareSheet) {
                ActivityViewController(activityItems: ["encoreApp://\(self.appState.session.sessionID)"] as [Any], applicationActivities: nil)
            }.onAppear{
                self.getMembers(username: self.appState.user.username)
            }
            
            if self.showPopupQRCode {
                popupQRView
            }
        }
    }
    
    var topBar: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 6)
                .fill(Color.secondary)
                .frame(width: 60, height: 4)
        }.padding()
    }
    
    var sessionTitle: some View {
        Text("\(userListVM.members.first(where: { $0.is_admin })?.username ?? "Host")'s session")
            .overlay(
                Rectangle()
                    .foregroundColor(Color("purpleblue"))
                    .frame(height: 2)
                    .cornerRadius(100)
                    .offset(y: 2), alignment: .bottom)
            .font(.system(size: 25, weight: .bold))
            .padding(.bottom, 10)
    }
    
    var qrCode: some View {
        Button(action: {
            withAnimation { self.showPopupQRCode.toggle() }
        }) {
            QRCodeView(url: "encoreApp://\(self.appState.session.sessionID)", size: 150).padding(10)
        }.buttonStyle(PlainButtonStyle())
        .alert(isPresented: self.$showSessionExpiredAlert) {
            Alert(title: Text("Session expired"),
                  message: Text("The Host has ended the Session."),
                  dismissButton: .destructive(Text("Leave"), action: {
                self.appState.session.currentlyInSession = false
                  }))
        }
        .padding(.bottom, 10)
    }
    
    var shareLinkButton: some View {
        Button(action: { self.showShareSheet.toggle() }) {
            ZStack {
                RoundedRectangle(cornerRadius: 15).frame(maxWidth: .infinity, maxHeight: 50)
                    .foregroundColor(self.colorScheme == .dark ? Color("darkgray") : Color("lightgray"))
                HStack {
                    Text("Share Invite Link")
                        .foregroundColor(self.colorScheme == .dark ? Color.white : Color.black)
                        .font(.headline)
                        .padding(.leading)
                    Spacer()
                    Image(systemName: "square.and.arrow.up")
                        .foregroundColor(self.colorScheme == .dark ? Color.white : Color.black)
                        .font(.system(size: 20, weight: .medium))
                        .padding(.trailing)
                }
            }.padding(.horizontal, 20)
        }
    }
    
    var membersList: some View {
        VStack(spacing: 0) {
            HStack {
                Spacer()
                Text("Leaderboard")
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundColor(Color("purpleblue"))
                    .padding(10)
                Spacer()
            }
            ScrollView {
                VStack {
                    ForEach(self.userListVM.members.sorted(by: { $0.score > $1.score }), id: \.self) { member in
                        HStack {
                            Text("\((self.userListVM.members.sorted(by: { $0.score > $1.score }).firstIndex(of: member) ?? -1) + 1)")
                                .font(.system(size: 17, weight: .light))
                            if member.username == self.appState.user.username {
                                Text("\(member.username)").font(.system(size: 17, weight: .semibold))
                            } else {
                                Text("\(member.username)").font(.system(size: 17, weight: .medium))
                            }
                            Spacer()
                            Text("\(member.score)").font(.system(size: 17, weight: .semibold))
                            Image(systemName: "heart")
                                .font(.system(size: 15, weight: .semibold))
                        }.foregroundColor(self.colorScheme == .dark ? Color.white : Color.black)
                        Divider()
                    }
                    Spacer().frame(height: 10)
                }.padding(.horizontal, 30)
            }
        }
    }
    
    var leaveButton: some View {
        Button(action: { self.appState.user.isAdmin ? (self.showAlert = true) : (self.leaveSession(username: self.appState.user.username)) }) {
            Text(self.appState.user.isAdmin ? "Delete Session" : "Leave Session")
                .modifier(ButtonHeavyModifier(isDisabled: false, backgroundColor: Color.red, foregroundColor: Color.white))
        }.padding(.bottom)
        .alert(isPresented: self.$showAlert) {
            Alert(title: Text("Delete Session"),
                  message: Text("By deleting the current session all members will be kicked."),
                  primaryButton: .destructive(Text("Delete"), action: {
                    self.playerStateVM.playerPause()
                self.deleteSession(username: self.appState.user.username)
                  }),
                  secondaryButton: .cancel(Text("Cancel"), action: {
                    self.showAlert = false
                  }))
        }
    }
    
    var popupQRView: some View {
        GeometryReader { geo in
            VStack(spacing: 0) {
                PopupQRCodeView(showPopupQRCode: self.$showPopupQRCode)
            }.frame(width: geo.size.width,
                    height: geo.size.height,
                    alignment: .center)
        }.background(
            Color.black.opacity(0.5)
                .edgesIgnoringSafeArea(.all)
                .onTapGesture {
                    self.showPopupQRCode.toggle()
                }
        )
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
    
    func deleteSession(username: String) {
        
        guard let url = URL(string: "https://api.encore-fm.com/admin/"+"\(username)"+"/deleteSession") else {
            print("Invalid URL")
            return
        }
        var request = URLRequest(url: url)
        
        print("secret: " + appState.session.secret)
        print("sessionID: " + appState.session.sessionID)
        
        request.httpMethod = "DELETE"
        request.addValue(appState.session.secret, forHTTPHeaderField: "Authorization")
        request.addValue(appState.session.sessionID, forHTTPHeaderField: "Session")
        
        
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
            DispatchQueue.main.async {
                self.appState.session.currentlyInSession = false
            }
            
        }
        task.resume()
    }
    
    func leaveSession(username: String) {
        
        guard let url = URL(string: "https://api.encore-fm.com/users/"+"\(username)"+"/leave") else {
            print("Invalid URL")
            return
        }
        var request = URLRequest(url: url)
        
        print("secret: " + appState.session.secret)
        print("sessionID: " + appState.session.sessionID)
        
        request.httpMethod = "DELETE"
        request.addValue(appState.session.secret, forHTTPHeaderField: "Authorization")
        request.addValue(appState.session.sessionID, forHTTPHeaderField: "Session")
        
        
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
                print("Response data string leave:\n \(dataString)")
            }
            
            DispatchQueue.main.async {
                self.appState.session.currentlyInSession = false
            }
        }
        task.resume()
    }
}

struct MenuView_Previews: PreviewProvider {
    static var playerStateVM = PlayerStateVM(username: "", sessionID: "", secret: "")
    @State static var showMenuSheet = false
    
    static var previews: some View {
        MenuView(username: "", sessionID: "", playerStateVM: playerStateVM, showMenuSheet: $showMenuSheet)
    }
}
