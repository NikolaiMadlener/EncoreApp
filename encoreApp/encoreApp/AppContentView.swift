//
//  AppContentView.swift
//  encoreApp
//
//  Created by Nikolai Madlener on 28.05.20.
//  Copyright © 2020 NikolaiEtienne. All rights reserved.
//

import SwiftUI

struct AppContentView: View {
    @Environment(\.colorScheme) var colorScheme
    @ObservedObject var userVM = UserVM()
    @State var currentlyInSession = false
    @State var showJoinSheet: Bool = false
    var joinedViaURL: Bool
    var sessionID: String
    
    var body: some View {
        return Group {
            ZStack {
                self.colorScheme == .dark ? Color("superdarkgray").edgesIgnoringSafeArea(.vertical) : Color.white.edgesIgnoringSafeArea(.vertical)
                
                if currentlyInSession {
                    HomeView(userVM: userVM, currentlyInSession: $currentlyInSession)
                }
                else {
                    LoginView(userVM: userVM, currentlyInSession: $currentlyInSession)
                        .sheet(isPresented: self.$showJoinSheet) {
                            JoinViaURLView(userVM: self.userVM, sessionID: self.sessionID, currentlyInSession: self.$currentlyInSession)
                    }
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
