//
//  AppContentView.swift
//  encoreApp
//
//  Created by Nikolai Madlener on 28.05.20.
//  Copyright © 2020 NikolaiEtienne. All rights reserved.
//

import SwiftUI

struct AppContentView: View {
    @State var currentlyInSession = false
    @State var sessionID = ""

    var body: some View {
        return Group {
            if currentlyInSession {
                HomeView(currentlyInSession: $currentlyInSession, sessionID: $sessionID)
            }
            else {
                ContentView(currentlyInSession: $currentlyInSession, sessionID: $sessionID)
            }
        }
    }
}

struct AppContentView_Previews: PreviewProvider {
    static var previews: some View {
        AppContentView()
    }
}
