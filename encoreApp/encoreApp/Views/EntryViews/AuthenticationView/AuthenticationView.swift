//
//  AuthView.swift
//  encoreApp
//
//  Created by Etienne Köhler on 22.06.20.
//  Copyright © 2020 NikolaiEtienne. All rights reserved.
//

import SwiftUI

struct AuthenticationView: View {
    @State var showAuthView = false
    @State var hasShownAuthView = false
    @Binding var auth_url: String
    @Binding var currentlyInSession: Bool
    
    var body: some View {
        ZStack {
            Image("entryBackground")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .edgesIgnoringSafeArea(.all).offset(x: 0, y: 50)
            VStack {
                Spacer().frame(height: 80)
                Image("SpotifyBlack")
                    .resizable()
                    .frame(width: 80, height: 80, alignment: .center)
                Spacer().frame(height: 50)
                Text("Sign in to Spotify to play the sessions music")
                    .font(.footnote)
                Button(action: {
                    self.showAuthView.toggle()
                }) {
                    Text("Connect with Spotify")
                        .font(.headline)
                        .padding(10)
                }
                Spacer().frame(height: 50)
                Button(action: {
                    self.currentlyInSession = true
                }) {
                    Text("Create Session")
                        .modifier(RoundButtonModifier(isDisabled: self.showAuthView || !self.hasShownAuthView, backgroundColor: Color("purpleblue"), foregroundColor: Color.white))
                }.disabled(self.showAuthView || !self.hasShownAuthView)
                Spacer()
                
            }
            .sheet(isPresented: self.$showAuthView) {
                AuthenticationSheet(url:URL(string: self.auth_url)!, hasShownAuthView: self.$hasShownAuthView)
            }
        }
    }
}

struct AuthView_Previews: PreviewProvider {
    @State static var currentlyInSession = false
    @State static var auth_url = "url"
    static var previews: some View {
        AuthenticationView(auth_url: $auth_url, currentlyInSession: $currentlyInSession)
    }
}
