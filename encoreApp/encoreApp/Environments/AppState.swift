//
//  User.swift
//  encoreApp
//
//  Created by Nikolai Madlener on 31.05.20.
//  Copyright © 2020 NikolaiEtienne. All rights reserved.
//

import Foundation

@MainActor public class AppState: ObservableObject {
    static let shared = AppState()
    
    @Published var user: User
    @Published var session: Session
    
    init() {
        user = User()
        session = Session()
    }
}
