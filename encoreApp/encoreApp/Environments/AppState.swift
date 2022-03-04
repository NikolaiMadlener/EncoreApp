//
//  User.swift
//  encoreApp
//
//  Created by Nikolai Madlener on 31.05.20.
//  Copyright © 2020 NikolaiEtienne. All rights reserved.
//

import Foundation

struct AppState {
    var user: User
    var session: Session
    var player: Player
    var members: [UserListElement]
    var songs: [Song]
    
    init() {
        user = User()
        session = Session()
        player = Player()
        members = []
        songs = []
    }
}
