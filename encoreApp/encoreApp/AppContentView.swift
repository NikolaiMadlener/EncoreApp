//
//  AppContentView.swift
//  encoreApp
//
//  Created by Nikolai Madlener on 28.05.20.
//  Copyright © 2020 NikolaiEtienne. All rights reserved.
//

import SwiftUI

struct AppContentView: View {
    @ObservedObject var networkModel: NetworkModel = .shared
    @State var currentlyInSession = false
    @State var showJoinSheet: Bool = false
    var joinedViaURL: Bool
    var sessionID: String
    
    var body: some View {
        return Group {
                if currentlyInSession {
                    HomeView(currentlyInSession: $currentlyInSession)
                }
                else {
                    ContentView(currentlyInSession: $currentlyInSession)
                        .sheet(isPresented: self.$showJoinSheet) {
                            JoinViaURLView(sessionID: self.sessionID, currentlyInSession: self.$currentlyInSession)
                    }
                }
        }.onAppear{ self.showJoinSheet = self.joinedViaURL }
    }
}

struct AppContentView_Previews: PreviewProvider {

    static var previews: some View {
        AppContentView(joinedViaURL: false, sessionID: "")
    }
}
