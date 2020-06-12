//
//  UserListElement.swift
//  encoreApp
//
//  Created by Nikolai Madlener on 31.05.20.
//  Copyright © 2020 NikolaiEtienne. All rights reserved.
//

import Foundation

struct UserListElement: Codable, Hashable {

    var username: String
    var is_admin: Bool
    var score: Int
    var spotify_synchronized: Bool
//    var hashValue: Int {
//         return id.hashValue
//    }
    
    init(username: String, is_admin: Bool, score: Int, spotify_synchronized: Bool) {
        self.username = username
        self.is_admin = is_admin
        self.score = score
        self.spotify_synchronized = spotify_synchronized
    }
}

//extension UserListElement {
//    func hash(into hasher: inout Hasher) {
//        hasher.combine(username)
//    }
//}
