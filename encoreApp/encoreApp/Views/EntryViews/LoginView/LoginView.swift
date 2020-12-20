//
//  ContentView.swift
//  encoreApp
//
//  Created by Nikolai Madlener on 26.05.20.
//  Copyright © 2020 NikolaiEtienne. All rights reserved.
//

import SwiftUI
import SafariServices

struct LoginView: View {
    
    // MARK: Stored Instance Properties
    @ObservedObject var userVM: UserVM
    @ObservedObject var musicController: MusicController = .shared
    @Binding var currentlyInSession: Bool
    @State var username: String = ""
    @State var sessionID: String = ""
    @State var secret: String = ""
    @State var showScannerSheet = false
    @State var showAuthSheet = false
    @State var scannedCode: String?
    @State var invalidUsername = false
    @State var auth_url: String = ""
    @State var sessionCreated: Bool? = false
    @State var deviceID = ""
    @State var showActivityIndicator = false
    @State var showServerErrorAlert = false
    @State var showWrongIDAlert = false
    @State var showUsernameExistsAlert = false
    @State var showNetworkErrorAlert = false
    
    
    // MARK: Computed Instance Properties
    var background: some View {
        Group {
            if #available(iOS 14.0, *) {
                VStack {
                    Spacer()
                    Image("entryBackground")
                        .resizable()
                        .scaledToFit()
                        .offset(x:0,y:70)
                        .scaleEffect(x:1.3, y:1.3)
                }.ignoresSafeArea(.keyboard)
            } else {
                VStack {
                    Spacer()
                    Image("entryBackground")
                        .resizable()
                        .scaledToFit()
                        .offset(x:0,y:70)
                        .scaleEffect(x:1.3, y:1.3)
                }
            }
        }
    }
    
    var title: some View {
        Text("encore.")
            .font(.largeTitle)
            .foregroundColor(.white)
            .bold()
    }
    
    var nameTextField: some View {
        Group {
            Spacer().frame(height: 40)
            TextField("Enter your Name", text: self.$username)
                .padding(15)
                .overlay(
                    RoundedRectangle(cornerRadius: 15)
                        .stroke(Color.gray, lineWidth: 1)
                ).padding(.horizontal, 25)
            if invalidUsername {
                Text("Name should be between 3 and 10 characters long and free of special characters and spaces.")
                    .font(.system(size: 12))
                    .foregroundColor(.red)
                    .padding(.horizontal, 25)
            }
            Spacer().frame(height: 20)
        }
    }
    
    var joinButton: some View {
        Group {
            if #available(iOS 14.0, *) {
                Button(action: {
                        if self.checkUsernameInvalid(username: self.username) {
                            self.invalidUsername = true
                        } else {
                            self.showScannerSheet = true
                            self.invalidUsername = false
                        }}) {
                    Text("Join Session")
                        .modifier(ButtonHeavyModifier(isDisabled: username.count < 1, backgroundColor: Color("purpleblue"), foregroundColor: Color.white))
                }
                .disabled(username.count < 1)
                .fullScreenCover(isPresented: self.$showScannerSheet) {
                    ScannerSheetView(userVM: self.userVM, currentlyInSession: self.$currentlyInSession, showScannerSheet: self.$showScannerSheet, showAuthSheet: self.$showAuthSheet, scannedCode: self.$scannedCode, sessionID: self.$sessionID, username: self.$username, secret: self.$secret, invalidUsername: self.$invalidUsername, showWrongIDAlert: self.$showWrongIDAlert, showUsernameExistsAlert: self.$showUsernameExistsAlert, showNetworkErrorAlert: self.$showNetworkErrorAlert)
                }
            } else {
                Button(action: {
                        if self.checkUsernameInvalid(username: self.username) {
                            self.invalidUsername = true
                        } else {
                            self.showScannerSheet = true
                            self.invalidUsername = false
                        }}) {
                    Text("Join Session")
                        .modifier(ButtonHeavyModifier(isDisabled: username.count < 1, backgroundColor: Color("purpleblue"), foregroundColor: Color.white))
                }
                .disabled(username.count < 1)
                .sheet(isPresented: self.$showScannerSheet) {
                    ScannerSheetView(userVM: self.userVM, currentlyInSession: self.$currentlyInSession, showScannerSheet: self.$showScannerSheet, showAuthSheet: self.$showAuthSheet, scannedCode: self.$scannedCode, sessionID: self.$sessionID, username: self.$username, secret: self.$secret, invalidUsername: self.$invalidUsername, showWrongIDAlert: self.$showWrongIDAlert, showUsernameExistsAlert: self.$showUsernameExistsAlert, showNetworkErrorAlert: self.$showNetworkErrorAlert)
                }
            }
        }
    }
    
    var createButton: some View {
        VStack {
            Button(action: {
                self.createSession(username: self.username)
            }) {
                ZStack {
                    if !showActivityIndicator {
                        Text("Create Session")
                    } else {
                        ActivityIndicator()
                            .frame(width: 20, height: 20).foregroundColor(Color("purpleblue"))
                    }
                }
                .modifier(ButtonLightModifier(isDisabled: username.count < 1, foregroundColor: Color("purpleblue")))
                
            }.disabled(username.count < 1)
            .sheet(isPresented: self.$showAuthSheet, onDismiss: {
                
                self.getAuthToken()
                self.showActivityIndicator = false
            }) {
                AuthenticationWebView(webVM: WebVM(link: self.userVM.auth_url), showAuthSheet: self.$showAuthSheet, showActivityIndicator: self.$showActivityIndicator)
            }
        }
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color("superdarkgray").edgesIgnoringSafeArea(.all)
                background
                VStack {
                    title
                    nameTextField
                    joinButton
                    LabeledDivider(label: "or")
                    createButton
                    Spacer()
                }
                .modifier(LoginAlertsModifier(showServerErrorAlert: $showServerErrorAlert, showWrongIDAlert: $showWrongIDAlert, showUsernameExistsAlert: $showUsernameExistsAlert, showNetworkErrorAlert: $showNetworkErrorAlert))
            }
        }
    }
    
    // MARK: Instance Methods
    func checkUsernameInvalid(username: String) -> Bool {
        let range = NSRange(location: 0, length: username.utf16.count)
        let regex = try! NSRegularExpression(pattern: "[A-Za-z][A-Za-z][A-Za-z][A-Za-z]*")
        if regex.firstMatch(in: username, options: [], range: range) == nil {
            return true
        }
        if username.contains("ä") || username.contains("ö") || username.contains("ü") ||
            username.contains("Ä") || username.contains("Ö") || username.contains("Ü") ||
            username.count > 10 {
            return true
        }
        return false
    }
    
    func createSession(username: String) {
        if checkUsernameInvalid(username: username) {
            invalidUsername = true
            return
        } else {
            invalidUsername = false
        }
        self.showActivityIndicator = true
        guard let url = URL(string: "https://api.encore-fm.com/admin/"+"\(username)"+"/createSession") else {
            print("Invalid URL")
            return
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        var auth_url = ""
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let error = error {
                print("Error took place \(error)")
                print(error.localizedDescription)
                if error.localizedDescription == "The Internet connection appears to be offline." {
                    self.showNetworkErrorAlert = true
                }
                self.showActivityIndicator = false
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
                    self.showActivityIndicator = false
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
                                self.showActivityIndicator = false
                                self.musicController.doConnect()
                                self.musicController.pausePlayback()
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
                    print("DEVICES")
                    print(deviceList["devices"])
                    self.deviceID = deviceList["devices"]?.first(where: {$0.type == "Smartphone"})?.id ?? ""
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
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let error = error {
                print("Error took place \(error)")
                return
            }
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
        LoginView(userVM: userVM, currentlyInSession: $signInSuccess)
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


