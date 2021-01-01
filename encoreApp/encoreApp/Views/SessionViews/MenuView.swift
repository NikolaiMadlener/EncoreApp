//
//  MenuView.swift
//  encoreApp
//
//  Created by Nikolai Madlener on 29.05.20.
//  Copyright © 2020 NikolaiEtienne. All rights reserved.
//

import SwiftUI

struct MenuView: View {
    @ObservedObject var userVM: UserVM
    @ObservedObject var userListVM: UserListVM
    @ObservedObject var pageViewModel: PageViewModel
    
    @Binding var showMenuSheet: Bool
    @Binding var currentlyInSession: Bool
    @State var showAlert = false
    @State var showSessionExpiredAlert = false
    @State var showShareSheet: Bool = false
    @State var showPopupQRCode: Bool = false
    
    init(userVM: UserVM, currentlyInSession: Binding<Bool>, showMenuSheet: Binding<Bool>, pageViewModel: PageViewModel) {
        self.userVM = userVM
        self.userListVM = UserListVM(userVM: userVM, sessionID: nil)
        self._currentlyInSession = currentlyInSession
        self._showMenuSheet = showMenuSheet
        self.pageViewModel = pageViewModel
        self.getMembers(username: self.userVM.username)
    }
    
    var body: some View {
        GeometryReader { geo in
            VStack(spacing: 0) {
                ZStack {
                    HStack {
                        homeButton
                        Spacer()
                    }
                    sessionTitle
                }
                
                membersList
                
                HStack {
                    shareLinkButton
                    leaveButton
                }.padding(.top, 10)
                .padding(.bottom, 15)
            }
            
            .sheet(isPresented: self.$showShareSheet) {
                ActivityViewController(activityItems: ["encoreApp://\(self.userVM.sessionID)"] as [Any], applicationActivities: nil)
            }.onAppear{
                
                print("Refresh Menuview")
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
    
    var homeButton: some View {
        Button(action: {
            withAnimation { self.pageViewModel.selectTabIndex = 0 }
        }) {
            Image(systemName: "arrow.left")
                .font(.system(size: 23, weight: .semibold))
                .foregroundColor(Color.white)
                .padding(.leading, 20)
        }.buttonStyle(PlainButtonStyle())
    }
    
    var sessionTitle: some View {
        Text("members.")
            .font(.system(size: 25, weight: .bold))
            .frame(maxWidth: .infinity)
            .foregroundColor(Color.white)
            .padding(.vertical, 20)
            .padding(.horizontal, 20)
    }
    
    var qrCode: some View {
        Button(action: {
            withAnimation { self.showPopupQRCode.toggle() }
        }) {
            QRCodeView(url: "encoreApp://\(self.userVM.sessionID)", size: 150).padding(10)
        }.buttonStyle(PlainButtonStyle())
        .alert(isPresented: self.$showSessionExpiredAlert) {
            Alert(title: Text("Session expired"),
                  message: Text("The Host has ended the Session."),
                  dismissButton: .destructive(Text("Leave"), action: {
                    self.currentlyInSession = false
                  }))
        }
        .padding(.bottom, 10)
    }
    
    var membersList: some View {
        VStack(spacing: 0) {
            GeometryReader { gp in
                ZStack {
                    ScrollView {
                        ForEach(self.userListVM.members.sorted(by: { $0.score > $1.score }), id: \.self) { member in
                            MemberCell(userVM: userVM, rank: (self.userListVM.members.sorted(by: { $0.score > $1.score }).firstIndex(of: member) ?? -1) + 1, member: member, isAdmin: member.is_admin)
                        }.animation(.easeInOut(duration: 0.3))
                    }
                    //fade out gradient
                    Rectangle()
                        .fill(
                            LinearGradient(gradient: Gradient(stops: [
                                .init(color: Color("superdarkgray").opacity(0.01), location: 0),
                                .init(color: Color("superdarkgray"), location: 1)
                            ]), startPoint: .top, endPoint: .bottom)
                        ).frame(height: 0.06 * gp.size.height)
                        .frame(maxHeight: .infinity, alignment: .bottom)
                }
            }
        }
    }
    
    var shareLinkButton: some View {
        Button(action: { withAnimation { self.showPopupQRCode.toggle() } }) {
            ZStack {
                RoundedRectangle(cornerRadius: 15).frame(maxWidth: .infinity, maxHeight: 50)
                    .foregroundColor(Color("purpleblue"))
                HStack {
                    Image(systemName: "person.crop.circle.badge.plus")
                    Text("Invite Friends")
                }.foregroundColor(Color.white)
                .font(.headline)
            }.padding(.leading, 10)
            .padding(.trailing, 5)
        }
    }
    
    var leaveButton: some View {
        Button(action: { self.userVM.isAdmin ? (self.showAlert = true) : (self.leaveSession(username: self.userVM.username)) }) {
            ZStack {
                RoundedRectangle(cornerRadius: 15).frame(maxWidth: .infinity, maxHeight: 50)
                    .foregroundColor(Color.red)
                HStack {
                    Image(systemName: self.userVM.isAdmin ? "trash.fill" : "chevron.left.circle")
                    Text(self.userVM.isAdmin ? "Delete Session" : "Leave Session")
                }.foregroundColor(Color.white)
                .font(.headline)
            }.padding(.leading, 5)
            .padding(.trailing, 10)
        }
        .alert(isPresented: self.$showAlert) {
            Alert(title: Text("Delete Session"),
                  message: Text("By deleting the current session all members will be kicked."),
                  primaryButton: .destructive(Text("Delete"), action: {
                    self.deleteSession(username: self.userVM.username)
                  }),
                  secondaryButton: .cancel(Text("Cancel"), action: {
                    self.showAlert = false
                  }))
        }
    }
    
    var popupQRView: some View {
        GeometryReader { geo in
            VStack(spacing: 0) {
                PopupQRCodeView(userVM: self.userVM, showPopupQRCode: self.$showPopupQRCode)
            }.frame(width: geo.size.width,
                    height: geo.size.height,
                    alignment: .center)
        }.background(
            Color.black.opacity(0.8)
                .edgesIgnoringSafeArea(.all)
                .onTapGesture {
                    self.showPopupQRCode.toggle()
                }
        )
    }
    
    func getMembers(username: String) {
        print("GET MEMBERS")
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
                print("Response data string leave:\n \(dataString)")
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
        MenuView(userVM: userVM, currentlyInSession: $currentlyInSession, showMenuSheet: $showMenuSheet, pageViewModel: PageViewModel())
    }
}
