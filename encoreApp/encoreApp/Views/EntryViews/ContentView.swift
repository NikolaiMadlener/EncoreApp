//
//  ContentView.swift
//  encoreApp
//
//  Created by Nikolai Madlener on 26.05.20.
//  Copyright © 2020 NikolaiEtienne. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var userVM: UserVM
    @Binding var currentlyInSession: Bool
    @State var username: String = ""
    @State var sessionID: String = ""
    @State var secret: String = ""
    @State var showServerErrorAlert = false
    
    var body: some View {
        NavigationView {
            ZStack {
                Image("entryBackground")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .edgesIgnoringSafeArea(.all).offset(x: 0, y: 50)
                VStack {
                    Spacer().frame(height: 50)
                    Text("encore.")
                        .font(.largeTitle)
                        .bold()
                    Spacer().frame(height: 150)
                    TextField("Enter your Name", text: self.$username)
                        .padding(10)
                        //.background(Color.clear)
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(Color.gray, lineWidth: 1)
                    ).padding(.horizontal, 25)
                    NavigationLink(destination: JoinSessionView(userVM: self.userVM, username: self.username, currentlyInSession: self.$currentlyInSession)) {
                        Text("Join Session")
                            .padding(15)
                            .background( username == "" ? Color("buttonDisabledGray") : Color("darkgray") ).foregroundColor(username == "" ? Color("lightgray") : Color.white).cornerRadius(25)
                    }.disabled(username == "")
                        .padding(5)
                    Spacer().frame(height: 50)
                    Text("Or create a new one and invite your Friends").font(.footnote)
                    Button(action: { self.createSession(username: self.username) }) {
                        Text("Create Session")
                            .font(.headline)
                            .foregroundColor(username == "" ? Color("lightgray") : Color("purpleblue"))
                            .cornerRadius(25)
                    }.disabled(username == "")
                        .padding(5)
                    Spacer()
                }
                .alert(isPresented: $showServerErrorAlert) {
                        Alert(title: Text("Server Error"),
                              message: Text(""),
                              dismissButton: .default(Text("OK"), action: { self.showServerErrorAlert = false }))
                }
            }
        }
    }
    
    func createSession(username: String) {
        guard let url = URL(string: "https://api.encore-fm.com/admin/"+"\(username)"+"/createSession") else {
            print("Invalid URL")
            return
        }
        var request = URLRequest(url: url)
        
        request.httpMethod = "POST"
        
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
                    // make sure this JSON is in the format we expect
                    if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                        // try to read out a string array
                        if let userInfo = json["user_info"] as? [String: Any] {
                            self.sessionID = userInfo["session_id"] as! String
                            self.secret = userInfo["secret"] as! String
                        }
                        self.currentlyInSession = true
                    }
                } catch let error as NSError {
                    print("Failed to load: \(error.localizedDescription)")
                    self.showServerErrorAlert = true
                }
                
            }
            DispatchQueue.main.async {
                self.userVM.username = username
                self.userVM.isAdmin = true
                self.userVM.secret = self.secret
                self.userVM.sessionID = self.sessionID
                print(self.userVM.username)
            }
        }
        task.resume()
    }
}

struct ContentView_Previews: PreviewProvider {
    @State static var signInSuccess = false
    @State static var sessionID = ""
    static var userVM = UserVM()
    
    static var previews: some View {
        ContentView(userVM: userVM, currentlyInSession: $signInSuccess)
    }
}
