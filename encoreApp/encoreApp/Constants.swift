//
//  Constants.swift
//  encoreApp
//
//  Created by Etienne Köhler on 08.06.20.
//  Copyright © 2020 NikolaiEtienne. All rights reserved.
//

import Foundation

struct Constants {
    let SpotifyClientID = "a8be659c46584d1c818dadd8023a4f36"
    let SpotifyRedirectURL = URL(string: "encoreapp://spotify/callback")!

    lazy var configuration = SPTConfiguration(
      clientID: SpotifyClientID,
      redirectURL: SpotifyRedirectURL
    )
}
