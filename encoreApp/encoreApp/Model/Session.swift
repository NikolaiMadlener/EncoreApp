//
//  Session.swift
//  encoreApp
//
//  Created by Nikolai Madlener on 01.03.22.
//  Copyright © 2022 NikolaiEtienne. All rights reserved.
//

import Foundation

struct Session {
    var sessionID: String
    var secret: String
    var clientToken: String
    var authToken: String
    var auth_url: String
    var currentlyInSession: Bool
    var deviceID: String
    
    init() {
        sessionID = ""
        secret = ""
        clientToken = ""
        authToken = ""
        auth_url = ""
        currentlyInSession = false
        deviceID = ""
    }
}
