//
//  JoinViaURLView.swift
//  encoreApp
//
//  Created by Nikolai Madlener on 04.06.20.
//  Copyright © 2020 NikolaiEtienne. All rights reserved.
//

import SwiftUI

struct JoinViaURLView: View {
    @ObservedObject var userVM: UserVM
    
    var sessionID: String
    @State var username = ""
    @State var secret: String = ""
    @State var showWrongIDAlert = false
    @Binding var currentlyInSession: Bool
    @State var invalidUsername = false
    @State var showActivityIndicator = false
    @State var showUsernameExistsAlert = false
    @State var showNetworkErrorAlert = false
    
    var body: some View {
        VStack {
            Spacer().frame(height: 200)
            //Text(sessionID)
            TextField("Enter your Name", text: self.$username)
            .padding(15)
            .overlay(
                RoundedRectangle(cornerRadius: 15)
                    .stroke(Color.gray, lineWidth: 1)
            ).padding(.horizontal, 25)
            if invalidUsername {
                Text("Name should be between three and 10 characters long and free of special characters and spaces.")
                    .font(.system(size: 12))
                    .foregroundColor(.red)
                    .padding(.horizontal, 25)
            }
            Spacer()
            Button(action: { self.joinSession(username: self.username) }) {
                ZStack {
                    if !showActivityIndicator {
                        Text("Join Session")
                    } else {
                        ActivityIndicator()
                            .frame(width: 20, height: 20).foregroundColor(Color.white)
                    }
                }
                     .modifier(ButtonHeavyModifier(isDisabled: username.count < 1, backgroundColor: Color("purpleblue"), foregroundColor: Color.white))
            }.padding(.bottom)
                .disabled(username.count < 1)
                .alert(isPresented: $showWrongIDAlert) {
                    Alert(title: Text("Session doesn't exist"),
                          message: Text(""),
                          dismissButton: .default(Text("OK"), action: { self.showWrongIDAlert = false }))
            }
            .alert(isPresented: $showUsernameExistsAlert) {
                    Alert(title: Text("Invalid Name"),
                          message: Text("A user with the given username already exists."),
                          dismissButton: .default(Text("OK"), action: { self.showUsernameExistsAlert = false }))
            }
            .alert(isPresented: $showNetworkErrorAlert) {
                    Alert(title: Text("Network Error"),
                          message: Text("The Internet connection appears to be offline."),
                          dismissButton: .default(Text("OK"), action: { self.showNetworkErrorAlert = false }))
            }
            
        }
    }
    
    func joinSession(username: String) {
        if checkUsernameInvalid(username: username) {
            invalidUsername = true
            return
        } else {
            invalidUsername = false
        }
        self.showActivityIndicator = true
        
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
                if error.localizedDescription == "The Internet connection appears to be offline." {
                    self.showNetworkErrorAlert = true
                }
                self.showActivityIndicator = false
                return
            }
            
            
            // Convert HTTP Response Data to a String
            if let data = data, let dataString = String(data: data, encoding: .utf8) {
                print("Response data string:\n \(dataString)")
                if dataString.starts(with: "{\"error") {
                    if dataString.starts(with: "{\"error\":\"UserConflictError\"") {
                        self.showUsernameExistsAlert = true
                    } else {
                        self.showWrongIDAlert = true
                    }
                    self.showActivityIndicator = false
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
                        self.showActivityIndicator = false
                    }
                    DispatchQueue.main.async {
                        self.userVM.username = username
                        self.userVM.isAdmin = false
                        self.userVM.secret = self.secret
                        self.userVM.sessionID = self.sessionID
                        self.showActivityIndicator = false
                        
                        self.getClientToken()
                    }
                    self.showWrongIDAlert = false
                    self.currentlyInSession = true
                }
            }
        }
        task.resume()
    }
    
    func getClientToken() {
        var clientToken = ""
        guard let url = URL(string: "https://api.encore-fm.com/users/"+"\(userVM.username)"+"/clientToken") else {
            print("Invalid URL")
            return
            
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue(userVM.secret, forHTTPHeaderField: "Authorization")
        request.addValue(userVM.sessionID, forHTTPHeaderField: "Session")
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            // Check for Error
            if let error = error {
                print("Error took place \(error)")
                return
            }
            
            // Convert HTTP Response Data to a String
            if let data = data, let dataString = String(data: data, encoding: .utf8) {
                print("Response data string clientToken:\n \(dataString)")
                do {
                    if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                        clientToken = json["access_token"] as! String
                        DispatchQueue.main.async {
                            self.userVM.clientToken = clientToken
                            //self.showAuthSheet = true
                        }
                    }
                } catch {
                    print("Error Get Client Token")
                }
            }
        }
        task.resume()
    }
    
    func checkUsernameInvalid(username: String) -> Bool {
        let range = NSRange(location: 0, length: username.utf16.count)
        let regex = try! NSRegularExpression(pattern: "[A-Za-z][A-Za-z][A-Za-z][A-Za-z]*")
        if regex.firstMatch(in: username, options: [], range: range) == nil {
            return true
        }
        if username.contains("ä") || username.contains("ö") || username.contains("ü") ||
            username.contains("Ä") || username.contains("Ö") || username.contains("Ü") {
            return true
        }
        return false
    }
}

struct JoinViaURLView_Previews: PreviewProvider {
    @State static var currentlyInSession = false
    static var userVM = UserVM()
    static var previews: some View {
        JoinViaURLView(userVM: userVM, sessionID: "123", currentlyInSession: $currentlyInSession)
    }
}
