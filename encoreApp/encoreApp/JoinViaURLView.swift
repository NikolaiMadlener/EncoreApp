//
//  JoinViaURLView.swift
//  encoreApp
//
//  Created by Nikolai Madlener on 04.06.20.
//  Copyright © 2020 NikolaiEtienne. All rights reserved.
//

import SwiftUI

struct JoinViaURLView: View {
    @ObservedObject var user: User
    
    var sessionID: String
    @State var username = ""
    @State var secret: String = ""
    @State var showWrongIDAlert = false
    @Binding var currentlyInSession: Bool
    
    var body: some View {
        VStack {
            Spacer()
            //Text(sessionID)
            TextField("Enter your Name", text: self.$username)
                .padding(10)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.gray, lineWidth: 1)
            ).padding(.horizontal, 25)
            Spacer()
            Button(action: { self.joinSession(username: self.username) }) {
                Text("Join Session")
                    .padding(15)
                    .background( sessionID == "" ? Color("buttonDisabledGray") : Color("purpleblue") ).foregroundColor(sessionID == "" ? Color("lightgray") : Color.white).cornerRadius(25)
            }.disabled(username == "")
                .alert(isPresented: $showWrongIDAlert) {
                    Alert(title: Text("Session doesn't exist"),
                          message: Text(""),
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
                                //self.sessionID = userInfo["session_id"] as! String
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

struct JoinViaURLView_Previews: PreviewProvider {
    @State static var currentlyInSession = false
    static var previews: some View {
        JoinViaURLView(user: User(), sessionID: "123", currentlyInSession: $currentlyInSession)
    }
}
