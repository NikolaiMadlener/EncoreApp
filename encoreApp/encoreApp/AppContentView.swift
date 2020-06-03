//
//  AppContentView.swift
//  encoreApp
//
//  Created by Nikolai Madlener on 28.05.20.
//  Copyright © 2020 NikolaiEtienne. All rights reserved.
//

import SwiftUI

struct AppContentView: View {
    @ObservedObject var user = User()
    @State var currentlyInSession = false

    var body: some View {
        return Group {
            if currentlyInSession {
                HomeView(user: user, currentlyInSession: $currentlyInSession)
            }
            else {
                ContentView(currentlyInSession: $currentlyInSession, user: self.user)
            }
        }
    }
}

struct AppContentView_Previews: PreviewProvider {
    static var previews: some View {
        AppContentView()
    }
}
