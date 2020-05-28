//
//  AppContentView.swift
//  encoreApp
//
//  Created by Nikolai Madlener on 28.05.20.
//  Copyright © 2020 NikolaiEtienne. All rights reserved.
//

import SwiftUI

struct AppContentView: View {
    @State var signInSuccess = false

    var body: some View {
        return Group {
            if signInSuccess {
                HomeView()
            }
            else {
                ContentView(signInSuccess: $signInSuccess)
            }
        }
    }
}

struct AppContentView_Previews: PreviewProvider {
    static var previews: some View {
        AppContentView()
    }
}
