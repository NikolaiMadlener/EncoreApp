//
//  CustomLoginError.swift
//  encoreApp
//
//  Created by Nikolai Madlener on 01.03.22.
//  Copyright © 2022 NikolaiEtienne. All rights reserved.
//

import Foundation

enum LoginError: Error {
    case invalidServerResponse
    case unsupportedFormat
    case usernameAlreadyExists
    case sessionNotFound
    case noInternetConnection
}
