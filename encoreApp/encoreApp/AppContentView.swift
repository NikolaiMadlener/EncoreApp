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
    @EnvironmentObject var appState: AppState
    
    @State var showJoinSheet: Bool = false
    
    var joinedViaURL: Bool
    var sessionID: String
    
    var body: some View {
        return Group {
            ZStack {
                self.colorScheme == .dark ? Color("superdarkgray").edgesIgnoringSafeArea(.vertical) : Color.white.edgesIgnoringSafeArea(.vertical)
                
                if appState.session.currentlyInSession {
                    HomeView(appState: appState)
                }
                else {
                    LoginView(viewModel: .init())
                        .sheet(isPresented: self.$showJoinSheet) {
                            JoinViaURLView(viewModel: .init(), username: "", sessionID: self.sessionID)
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
