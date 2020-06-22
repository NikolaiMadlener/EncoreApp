//
//  AuthView.swift
//  encoreApp
//
//  Created by Etienne Köhler on 22.06.20.
//  Copyright © 2020 NikolaiEtienne. All rights reserved.
//

import SwiftUI

struct AuthView: View {
    @State var showAuthView = false
    @State var hasShownAuthView = false
    @Binding var auth_url: String
    @Binding var currentlyInSession: Bool
    
    var body: some View {
        VStack {
            Button(action: {
                self.showAuthView.toggle()
            }) {
                Text("Authorize")
            }
            Spacer()
            Button(action: {
                self.currentlyInSession = true
            }) {
                Text("Create Session")
            }.disabled(self.showAuthView || !self.hasShownAuthView)
        }
        .sheet(isPresented: self.$showAuthView) {
            AuthSheet(url:URL(string: self.auth_url)!, hasShownAuthView: self.$hasShownAuthView)
        }
        
        //When sheet is dismissed -> currentlyInSession = true
    }
}

struct AuthView_Previews: PreviewProvider {
    @State static var currentlyInSession = false
    @State static var auth_url = "url"
    static var previews: some View {
        AuthView(auth_url: $auth_url, currentlyInSession: $currentlyInSession)
    }
}
