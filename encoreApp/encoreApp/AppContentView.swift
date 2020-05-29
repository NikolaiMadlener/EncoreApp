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

    var body: some View {
        return Group {
            if currentlyInSession {
                HomeView(signInSuccess: $currentlyInSession)
            }
            else {
                ContentView(currentlyInSession: $currentlyInSession)
            }
        }
    }
}

struct AppContentView_Previews: PreviewProvider {
    static var previews: some View {
        AppContentView()
    }
}
