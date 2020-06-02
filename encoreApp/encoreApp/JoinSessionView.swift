//
//  JoinSessionView.swift
//  encoreApp
//
//  Created by Nikolai Madlener on 29.05.20.
//  Copyright © 2020 NikolaiEtienne. All rights reserved.
//

import SwiftUI

struct JoinSessionView: View {
    @ObservedObject var user: User
    var username: String
    @Binding var currentlyInSession: Bool
    @State var sessionID = ""
    @State var showWrongIDAlert = false
    @State var secret: String = ""
    
    var body: some View {
        VStack {
            Spacer()
            TextField("Enter Session ID", text: self.$sessionID)
                .padding(10)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.gray, lineWidth: 1)
            ).padding(.horizontal, 25)
            Spacer()
            Button(action: { self.joinSession(username: self.username) }) {
                Text("Join Session")
                    .padding(15)
                    .background( sessionID == "" ? Color("buttonDisabledGray") : Color("purpleblue") ).foregroundColor(sessionID == "" ? Color("lightgray") : Color.white).cornerRadius(25)//.shadow(radius: 5)
            }.disabled(sessionID == "")
                .padding(5)
                .alert(isPresented: $showWrongIDAlert) {
                    Alert(title: Text("ID doesn't exist"),
                          message: Text("Try again"),
                          dismissButton: .default(Text("OK"), action: { self.showWrongIDAlert = false }))
                    
            }
        }
    }
    
    func joinSession(username: String) {
        guard let url = URL(string: "https://api.encore-fm.com/users/"+"\(username)"+"/join/"+"\(sessionID)") else {
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
                if dataString.starts(with: "{\"error") {
                    self.showWrongIDAlert = true
                    return
                } else {
                    do {
                        // make sure this JSON is in the format we expect
                        if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                            // try to read out a string array
                            if let userInfo = json["user_info"] as? [String: Any] {
                                self.sessionID = userInfo["session_id"] as! String
                                self.secret = userInfo["secret"] as! String
                            }
                        }
                    } catch let error as NSError {
                        print("Failed to load: \(error.localizedDescription)")
                    }
                    DispatchQueue.main.async {
                        self.user.username = username
                        self.user.isAdmin = false
                        self.user.secret = self.secret
                        self.user.sessionID = self.sessionID
                        print(self.user.username)
                    }
                    self.showWrongIDAlert = false
                    self.currentlyInSession = true
                }
            }
        }
        task.resume()
    }
}

struct JoinSessionView_Previews: PreviewProvider {
    static var username = "Etienne"
    @State static var currentlyInSession = false
    static var user = User()
    
    static var previews: some View {
        JoinSessionView(user: self.user, username: self.username, currentlyInSession: self.$currentlyInSession)
    }
}
