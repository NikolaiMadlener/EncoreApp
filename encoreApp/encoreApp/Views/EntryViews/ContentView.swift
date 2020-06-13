//
//  ContentView.swift
//  encoreApp
//
//  Created by Nikolai Madlener on 26.05.20.
//  Copyright © 2020 NikolaiEtienne. All rights reserved.
//

import SwiftUI
import CodeScanner

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
                    if username.count > 0 && username.count < 3 {
                        Text("The Name should at least be three characters long.")
                            .font(.footnote)
                            .foregroundColor(.red)
                    }
                    Group {
                        Button(action: { self.showScannerSheet = true }) {
                            Text("Join Session")
                                .padding(15)
                                .background( username.count < 3 ? Color("buttonDisabledGray") : Color("darkgray") ).foregroundColor(username == "" ? Color("lightgray") : Color.white).cornerRadius(25)
                        }.disabled(username.count < 3)
                            .padding(5)
                            
                        Spacer().frame(height: 50)
                        Text("Or create a new one and invite your Friends").font(.footnote)
                        Button(action: { self.createSession(username: self.username) }) {
                            Text("Create Session")
                                .font(.headline)
                                .foregroundColor(username.count < 3 ? Color("lightgray") : Color("purpleblue"))
                                .cornerRadius(25)
                        }.disabled(username.count < 3)
                            .padding(5)
                        Spacer()
                    }.animation(.default)
                }.sheet(isPresented: self.$showScannerSheet) {
                    ZStack {
                        self.scannerSheet
                        VStack {
                            Text("Scan the Session's QR code to join").padding()
                            Spacer()
                        }
                    }
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
        CodeScannerView(
            codeTypes: [.qr],
            completion: { result in
                if case let .success(code) = result {
                    self.scannedCode = code
                    self.showScannerSheet = false
                    self.sessionID = self.scannedCode!.substring(from: self.scannedCode!.index(self.scannedCode!.startIndex, offsetBy: 12))
                    self.joinSession(username: self.username)
                }
        }
        )
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
                        print(self.userVM.username)
                    }
                }
            }
        }
        task.resume()
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
