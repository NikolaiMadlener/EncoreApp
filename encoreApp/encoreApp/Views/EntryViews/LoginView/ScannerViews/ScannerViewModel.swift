//
//  ScannerViewModel.swift
//  encoreApp
//
//  Created by Etienne Köhler on 22.12.20.
//  Copyright © 2020 NikolaiEtienne. All rights reserved.
//

import Foundation
import SwiftUI

class ScannerViewModel: ObservableObject {
    
    /// Defines how often we are going to try looking for a new QR-code in the camera feed.
    let scanInterval: Double = 1.0
    @ObservedObject var userVM: UserVM
    @Binding var currentlyInSession: Bool
    @Binding var showScannerSheet: Bool
    @Binding var showAuthSheet: Bool
    @Binding var scannedCode: String?
    @Binding var sessionID: String
    @Binding var username: String
    @Binding var secret: String
    @Binding var invalidUsername: Bool
    @Binding var showAlert: Bool
    @Binding var activeAlert: ActiveAlert
    
    @Published var torchIsOn: Bool = false
    @Published var lastQrCode: String?
    
    init(userVM: UserVM, currentlyInSession: Binding<Bool>, showScannerSheet: Binding<Bool>, showAuthSheet: Binding<Bool>, scannedCode: Binding<String?>, sessionID: Binding<String>, username: Binding<String>, secret: Binding<String>, invalidUsername: Binding<Bool>, showAlert: Binding<Bool>, activeAlert: Binding<ActiveAlert>) {
        self.userVM = userVM
        self._currentlyInSession = currentlyInSession
        self._showScannerSheet = showScannerSheet
        self._showAuthSheet = showAuthSheet
        self._scannedCode = scannedCode
        self._sessionID = sessionID
        self._username = username
        self._secret = secret
        self._invalidUsername = invalidUsername
        self._showAlert = showAlert
        self._activeAlert = activeAlert
    }
    
    func onFoundQrCode(_ code: String) {
        self.lastQrCode = code
        self.showScannerSheet = false
        if let lastQrCode = self.lastQrCode {
            if lastQrCode.count > 12 {
                self.sessionID = self.lastQrCode!.substring(from: self.lastQrCode!.index(self.lastQrCode!.startIndex, offsetBy: 12))
            } else {
                self.sessionID = ""
            }
        }
        self.joinSession(username: self.username)
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
                print("Error took placce \(error.localizedDescription)")
                if error.localizedDescription == "A data connection is not currently allowed." {
                    self.showAlert = true
                    self.activeAlert = .network
                }
                return
            }
            
            // Convert HTTP Response Data to a String
            if let data = data, let dataString = String(data: data, encoding: .utf8) {
                print("Response data string:\n \(dataString)")
                if dataString.starts(with: "{\"error") {
                    if dataString.starts(with: "{\"error\":\"UserConflictError\"") {
                        self.showAlert = true
                        self.activeAlert = .usernameExists
                    } else {
                        self.showAlert = true
                        self.activeAlert = .wrongID
                    }
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
                        self.showAlert = true
                        self.activeAlert = .wrongID
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
                print("Error took placcce \(error)")
                if error.localizedDescription == "A data connection is not currently allowed." {
                    self.showAlert = true
                    self.activeAlert = .network
                }
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