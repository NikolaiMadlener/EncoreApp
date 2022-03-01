//
//  User.swift
//  encoreApp
//
//  Created by Nikolai Madlener on 01.03.22.
//  Copyright © 2022 NikolaiEtienne. All rights reserved.
//

import Foundation

struct User {
    var username: String
    var isAdmin: Bool
    
    init() {
        username = ""
        isAdmin = false
    }
}
