//
//  Device.swift
//  encoreApp
//
//  Created by Nikolai Madlener on 26.02.22.
//  Copyright © 2022 NikolaiEtienne. All rights reserved.
//

import Foundation

struct Device: Codable, Hashable {
    
    var id: String
    var is_active: Bool
    var is_private_session: Bool
    var is_restricted: Bool
    var name: String
    var type: String
    var volume_percent: Int
    
    init(id: String,
         is_active: Bool,
         is_private_session: Bool,
         is_restricted: Bool,
         name: String,
         type: String,
         volume_percent: Int
    ) {
        self.id = id
        self.is_active = is_active
        self.is_private_session = is_private_session
        self.is_restricted = is_restricted
        self.name = name
        self.type = type
        self.volume_percent = volume_percent
        
    }
}

struct DeviceList: Codable, Hashable {
    var devices: [Device]
}

