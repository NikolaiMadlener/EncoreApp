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
    @StateObject var viewModel: ViewModel
    
    var body: some View {
        return Group {
            ZStack {
                self.colorScheme == .dark ? Color("superdarkgray").edgesIgnoringSafeArea(.vertical) : Color.white.edgesIgnoringSafeArea(.vertical)
                
                if viewModel.currentlyInSession {
                    HomeView(viewModel: .init())
                }
                else {
                    LoginView(viewModel: .init())
                        .sheet(isPresented: self.$viewModel.showJoinSheet) {
                            JoinViaURLView(viewModel: .init(), sessionID: self.viewModel.sessionID)
                        }
                }
            }
        }.onAppear{ self.viewModel.showJoinSheet = self.viewModel.joinedViaURL }
    }
}

struct AppContentView_Previews: PreviewProvider {
    
    static var previews: some View {
        AppContentView(viewModel: .init(joinedViaURL: false, sessionID: ""))
    }
}
