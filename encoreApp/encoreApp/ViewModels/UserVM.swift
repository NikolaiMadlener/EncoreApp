//
//  UserVM.swift
//  encoreApp
//
//  Created by Nikolai Madlener on 28.02.22.
//  Copyright © 2022 NikolaiEtienne. All rights reserved.
//

import Foundation

public class UserVM: ObservableObject {
    
    @Published var username: String
    @Published var isAdmin: Bool
    @Published var sessionID: String
    @Published var secret: String
    @Published var clientToken: String
    @Published var authToken: String
    @Published var auth_url: String
    
    init(username: String, isAdmin: Bool, sessionID: String, secret: String, clientToken: String) {
        self.username = username
        self.isAdmin = isAdmin
        self.sessionID = sessionID
        self.secret = secret
        self.clientToken = clientToken
        self.authToken = ""
        self.auth_url = ""
    }
    
    init() {
        self.username = ""
        self.isAdmin = true
        self.sessionID = ""
        self.secret = ""
        self.clientToken = ""
        self.authToken = ""
        self.auth_url = ""
    }
}
