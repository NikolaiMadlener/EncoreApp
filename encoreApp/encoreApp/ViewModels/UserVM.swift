//
//  User.swift
//  encoreApp
//
//  Created by Nikolai Madlener on 31.05.20.
//  Copyright © 2020 NikolaiEtienne. All rights reserved.
//

import Foundation

public class UserVM: ObservableObject {
    @Published var username: String
    @Published var isAdmin: Bool
    @Published var sessionID: String
    @Published var secret: String
    
    init(username: String, isAdmin: Bool, sessionID: String, secret: String) {
        self.username = username
        self.isAdmin = isAdmin
        self.sessionID = sessionID
        self.secret = secret
    }
    
    init() {
        self.username = ""
        self.isAdmin = true
        self.sessionID = ""
        self.secret = ""
    }
}
