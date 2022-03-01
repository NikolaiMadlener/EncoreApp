//
//  LoginService.swift
//  encoreApp
//
//  Created by Nikolai Madlener on 26.02.22.
//  Copyright © 2022 NikolaiEtienne. All rights reserved.
//

import Foundation
import SwiftUI

// MARK: - Service
struct LoginService {
    var appState = AppState.shared
    
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
    
    func createSession(username: String) async throws -> Void {
        let url = URL(string: "https://api.encore-fm.com/admin/"+"\(username)"+"/createSession")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        // make sure no network error occured
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw LoginError.invalidServerResponse
        }
        
        // make sure this JSON is in the format we expect
        guard let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] else {
            throw LoginError.unsupportedFormat
        }
        
        // try to read out a string array
        guard let userInfo = json["user_info"] as? [String: Any] else {
            throw LoginError.unsupportedFormat
        }
        
        DispatchQueue.main.async {
            self.appState.session.sessionID = userInfo["session_id"] as! String
            self.appState.session.secret = userInfo["secret"] as! String
            self.appState.session.auth_url = json["auth_url"] as! String
            self.appState.user.username = username
            self.appState.user.isAdmin = true
        }
        return
    }
    
    func joinSession(username: String, sessionID: String) async throws -> Void {
        let url = URL(string: "https://api.encore-fm.com/users/"+"\(username)"+"/join/"+"\(sessionID)")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        // make sure no network error occured
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw LoginError.invalidServerResponse
        }
        
        if let dataString = String(data: data, encoding: .utf8) {
            if dataString.starts(with: "{\"error") {
                if dataString.starts(with: "{\"error\":\"UserConflictError\"") {
                    throw LoginError.usernameAlreadyExists
                } else {
                    throw LoginError.sessionNotFound
                }
            }
        }
        
        // make sure this JSON is in the format we expect
        guard let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] else {
            throw LoginError.unsupportedFormat
        }
        
        guard let userInfo = json["user_info"] as? [String: Any] else {
            throw LoginError.unsupportedFormat
        }
        
        DispatchQueue.main.async {
            self.appState.session.sessionID = userInfo["session_id"] as! String
            self.appState.session.secret = userInfo["secret"] as! String
            self.appState.session.currentlyInSession = true
            self.appState.user.username = username
            self.appState.user.isAdmin = false
        }
        return
    }
    
    
    func getClientToken() async throws -> Void {
        let username = await appState.user.username
        let secret = await appState.session.secret
        let sessionID = await appState.session.sessionID
        
        let url = URL(string: "https://api.encore-fm.com/users/"+"\(username)"+"/clientToken")!
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue(secret, forHTTPHeaderField: "Authorization")
        request.addValue(sessionID, forHTTPHeaderField: "Session")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        // make sure no network error occured
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw LoginError.invalidServerResponse
        }
        
        // make sure this JSON is in the format we expect
        guard let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] else {
            throw LoginError.unsupportedFormat
        }
        
        DispatchQueue.main.async {
            self.appState.session.clientToken = json["access_token"] as! String
        }
        return
    }
    
    func getAuthToken() async throws -> Void {
        let username = await appState.user.username
        let secret = await appState.session.secret
        let sessionID = await appState.session.sessionID
        
        let url = URL(string: "https://api.encore-fm.com/users/"+"\(username)"+"/authToken")!
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue(secret, forHTTPHeaderField: "Authorization")
        request.addValue(sessionID, forHTTPHeaderField: "Session")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        // make sure no network error occured
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw LoginError.invalidServerResponse
        }
        
        // make sure this JSON is in the format we expect
        guard let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] else {
            throw LoginError.unsupportedFormat
        }
        
        DispatchQueue.main.async {
            self.appState.session.authToken = json["access_token"] as! String
            self.appState.session.currentlyInSession = true
        }
        return
    }
    
    func getDeviceID() async throws -> Void {
        let authToken = await appState.session.authToken
        
        let url = URL(string: "https://api.spotify.com/v1/me/player/devices")!
            
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("Bearer " + authToken, forHTTPHeaderField: "Authorization")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        // make sure no network error occured
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw LoginError.invalidServerResponse
        }
        
        // make sure this JSON is in the format we expect
        guard let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: [Device]] else {
            throw LoginError.unsupportedFormat
        }
        
        DispatchQueue.main.async {
            self.appState.session.deviceID = json["devices"]?.first(where: {$0.type == "Smartphone"})?.id ?? ""
        }
        return
    }
    
    func connectWithSpotify() async throws -> Void {
        let deviceID = await appState.session.deviceID
        let authToken = await appState.session.authToken
        let sessionID = await appState.session.sessionID
        
        let url = URL(string: "https://api.spotify.com/v1/me/player")!

        var request = URLRequest(url: url)
        let json: [String: Any] = ["device_ids": [deviceID],
                                   "play": true]
        let jsonData = try? JSONSerialization.data(withJSONObject: json)
        
        request.httpMethod = "PUT"
        request.addValue("Bearer " + authToken, forHTTPHeaderField: "Authorization")
        request.addValue(sessionID, forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData
    
        let (_, response) = try await URLSession.shared.data(for: request)
        
        // make sure no network error occured
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw LoginError.invalidServerResponse
        }
        return
    }
}

// MARK: - Injection
private struct LoginServiceKey: DependencyKey {
    static var currentValue: LoginService = LoginService()
}

extension DependencyValues {
    var loginService: LoginService {
        get { Self[LoginServiceKey.self] }
        set { Self[LoginServiceKey.self] = newValue }
    }
}
