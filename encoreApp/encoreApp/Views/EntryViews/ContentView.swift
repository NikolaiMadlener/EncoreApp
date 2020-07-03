//
//  ContentView.swift
//  encoreApp
//
//  Created by Nikolai Madlener on 26.05.20.
//  Copyright © 2020 NikolaiEtienne. All rights reserved.
//

import SwiftUI
import CodeScanner
import SafariServices

struct ContentView: View {
    @ObservedObject var userVM: UserVM
    @Binding var currentlyInSession: Bool
    @State var username: String = ""
    @State var sessionID: String = ""
    @State var secret: String = ""
    
    @State var showServerErrorAlert = false
    @State var showWrongIDAlert = false
    
    @State var showScannerSheet = false
    @State var scannedCode: String?
    
    @State var showAuthSheet = false
    
    @State var invalidUsername = false
    
    @State var auth_url: String = ""
    @State var sessionCreated: Bool? = false
    
    @State var deviceID = ""
    
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
                    Spacer().frame(height: 100)
                    TextField("Enter your Name", text: self.$username)
                        .padding(10)
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(Color.gray, lineWidth: 1)
                    ).padding(.horizontal, 25)
                    if invalidUsername {
                        Text("Name should at least be three characters long and free of special characters and spaces.")
                            .font(.system(size: 12))
                            .foregroundColor(.red)
                            .padding([.horizontal, .bottom])
                    }
                    Group {
                        Button(action: { if self.checkUsernameInvalid(username: self.username) {
                            self.invalidUsername = true
                        } else {
                            self.showScannerSheet = true
                            self.invalidUsername = false
                            }}) {
                                Text("Join Session")
                                    .modifier(RoundButtonModifier(isDisabled: username.count < 1, backgroundColor: Color("darkgray"), foregroundColor: Color.white))
                        }.disabled(username.count < 1)
                            .padding(5)
                            .sheet(isPresented: self.$showScannerSheet) {
                                self.scannerSheet
                        }
                        Spacer().frame(height: 40)
                        Text("Or create a new one and invite your Friends").font(.footnote)
                        VStack {
                            //                            NavigationLink(destination: AuthenticationView(currentlyInSession: self.$currentlyInSession), tag: true, selection: $sessionCreated) {
                            //                                EmptyView()
                            //                            }
                            Button(action: {
                                self.createSession(username: self.username)
                            }) {
                                Text("Create Session")
                                    .font(.headline)
                                    .foregroundColor(username.count < 1 ? Color("lightgray") : Color("purpleblue"))
                            }.disabled(username.count < 1)
                                .padding(5)
                                .sheet(isPresented: self.$showAuthSheet, onDismiss: {
                                    self.getAuthToken()
                                }) {
                                    AuthenticationSheet(url: URL(string: self.userVM.auth_url)!, showAuthSheet: self.$showAuthSheet)
                            }
                            //                            Button(action: {
                            //                                                self.showAuthSheet = true
                            //
                            //                                            }) {
                            //                                                Text("Connect with Spotify")
                            //                                                    .font(.headline)
                            //                                                    .padding(10)
                            //                                            }
                        }
                        Spacer()
                    }.animation(.default)
                }
                .alert(isPresented: $showServerErrorAlert) {
                    Alert(title: Text("Server Error"),
                          message: Text(""),
                          dismissButton: .default(Text("OK"), action: { self.showServerErrorAlert = false }))
                }.alert(isPresented: $showWrongIDAlert) {
                    Alert(title: Text("Session doesn't exist"),
                          message: Text("Try again"),
                          dismissButton: .default(Text("OK"), action: { self.showWrongIDAlert = false }))
                    
                }
            }
        }
    }
    
    
    var scannerSheet : some View {
        ZStack {
            CodeScannerView(
                codeTypes: [.qr],
                completion: { result in
                    if case let .success(code) = result {
                        self.scannedCode = code
                        self.showScannerSheet = false
                        if let scannedCode = self.scannedCode {
                            if scannedCode.count > 12 {
                                self.sessionID = self.scannedCode!.substring(from: self.scannedCode!.index(self.scannedCode!.startIndex, offsetBy: 12))
                            } else {
                                self.sessionID = ""
                            }
                        }
                        self.joinSession(username: self.username)
                    }
            }
            )
            
            VStack {
                Button(action: { self.showScannerSheet = false }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.white)
                        .font(.largeTitle)
                        .padding()
                }
                Text("Scan the Session's QR code to join")
                Spacer()
            }
        }
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
    
    func joinSession(username: String) {
        if checkUsernameInvalid(username: username) {
            invalidUsername = true
            return
        } else {
            invalidUsername = false
        }
        
        guard let url = URL(string: "https://api.encore-fm.com/users/"+"\(username)"+"/join/"+"\(sessionID)") else {
            print("Invalid URL")
            return
            
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
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
                            self.currentlyInSession = true
                        }
                    } catch let error as NSError {
                        print("Failed to load: \(error.localizedDescription)")
                        self.showWrongIDAlert = true
                    }
                    DispatchQueue.main.async {
                        self.userVM.username = username
                        self.userVM.isAdmin = false
                        self.userVM.secret = self.secret
                        self.userVM.sessionID = self.sessionID
                        self.currentlyInSession = true
                        self.getClientToken()
                    }
                    self.currentlyInSession = true
                }
            }
        }
        task.resume()
    }
    
    func createSession(username: String) {
        if checkUsernameInvalid(username: username) {
            invalidUsername = true
            return
        } else {
            invalidUsername = false
        }
        
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
        var auth_url = ""
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
                        
                        self.auth_url = json["auth_url"] as! String
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
                self.userVM.auth_url = self.auth_url
                
                self.getClientToken()
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
                            self.showAuthSheet = true
                        }
                    }
                } catch {
                    print("Error Get Client Token")
                }
            }
        }
        task.resume()
    }
    
    func getAuthToken() {
        guard let url = URL(string: "https://api.encore-fm.com/users/"+"\(userVM.username)"+"/authToken") else {
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
                print("Response data string authToken:\n \(dataString)")
                do {
                    if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                        DispatchQueue.main.async {
                            self.userVM.authToken = json["access_token"] as? String ?? ""
                            if self.userVM.authToken == "" {
                                self.currentlyInSession = false
                            } else {
                                self.currentlyInSession = true
                            }
                            self.getDeviceID()
                        }
                    }
                } catch {
                    print("Error get Auth Token")
                }
            }
        }
        task.resume()
    }
    
    func getDeviceID() {
        guard let url = URL(string: "https://api.spotify.com/v1/me/player/devices") else {
            print("Invalid URL")
            return
            
        }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("Bearer " + userVM.authToken, forHTTPHeaderField: "Authorization")
        
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            // Check for Error
            if let error = error {
                print("Error took place \(error)")
                return
            }
            
            
            // Convert HTTP Response Data to a String
            if let data = data, let dataString = String(data: data, encoding: .utf8) {
                print("Response data string device:\n \(dataString)")
                do {
                    let deviceList = try JSONDecoder().decode([String: [Device]].self, from: data)
                    print(deviceList["devices"])
                    self.deviceID = deviceList["devices"]?.first?.id ?? ""
                    self.connectWithSpotify()
                } catch {
                    print("Error get Device ID")
                }
            }
            
        }
        task.resume()
    }
    
    func connectWithSpotify() {
        guard let url = URL(string: "https://api.spotify.com/v1/me/player") else {
            print("Invalid URL")
            return
            
        }
        var request = URLRequest(url: url)
        let json: [String: Any] = ["device_ids": [deviceID],
                                   "play": true]
        let jsonData = try? JSONSerialization.data(withJSONObject: json)
        
        request.httpMethod = "PUT"
        request.addValue("Bearer " + userVM.authToken, forHTTPHeaderField: "Authorization")
        request.addValue(userVM.sessionID, forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData
        
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

struct Device: Codable, Hashable {
    
    var id: String
    var is_active: Bool
    var is_private_session: Bool
    var is_restricted: Bool
    var name: String
    var type: String
    var volume_percent: Int
    
    init(id: String,
         is_active: Bool,
         is_private_session: Bool,
         is_restricted: Bool,
         name: String,
         type: String,
         volume_percent: Int
    ) {
        self.id = id
        self.is_active = is_active
        self.is_private_session = is_private_session
        self.is_restricted = is_restricted
        self.name = name
        self.type = type
        self.volume_percent = volume_percent
        
    }
}

struct DeviceList: Codable, Hashable {
    var devices: [Device]
}


