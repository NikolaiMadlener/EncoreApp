//
//  ContentView.swift
//  encoreApp
//
//  Created by Nikolai Madlener on 26.05.20.
//  Copyright © 2020 NikolaiEtienne. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    @State var username: String = ""
    @Binding var currentlyInSession: Bool
    @Binding var sessionID: String

    var body: some View {
        NavigationView {
            VStack {
                Spacer().frame(height: 50)
                Text("encore.")
                    .font(.largeTitle)
                    .bold()
                Spacer().frame(height: 200)
                TextField("Enter your Name", text: self.$username)
                    .padding(5)
                    .background(Color("lightgray"))
                    .cornerRadius(5)
                    .padding()
                Button(action: { self.createSession(username: self.username) }) {
                    Text("Create Session")
                        .padding(15)
                        .background( username == "" ? Color("buttonDisabledGray") : Color("darkgray") ).foregroundColor(username == "" ? Color("lightgray") : Color.white).cornerRadius(25)//.shadow(radius: 5)
                    }.disabled(username == "")
                    .padding(5)
                NavigationLink(destination: JoinSessionView(username: self.username, currentlyInSession: self.$currentlyInSession)) {
                    Text("Join Session")
                        .padding(15)
                        .background( username == "" ? Color("buttonDisabledGray") : Color("darkgray") ).foregroundColor(username == "" ? Color("lightgray") : Color.white).cornerRadius(25)//.shadow(radius: 5)
                }.disabled(username == "")
                .padding(5)
                Spacer()
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
                            }
                        }
                    } catch let error as NSError {
                        print("Failed to load: \(error.localizedDescription)")
                    }
                    
                }
            
            
            
            self.currentlyInSession = true
        }
        task.resume()
    }
}

struct ContentView_Previews: PreviewProvider {
    @State static var signInSuccess = false
    @State static var sessionID = ""
    
    static var previews: some View {
        ContentView(currentlyInSession: $signInSuccess, sessionID: $sessionID)
    }
}
