////
////  AuthView.swift
////  encoreApp
////
////  Created by Etienne Köhler on 22.06.20.
////  Copyright © 2020 NikolaiEtienne. All rights reserved.
////
//
//import SwiftUI
//
//struct AuthenticationView: View {
//    @ObservedObject var viewModel = AuthenticationViewModel()
//    @Binding var currentlyInSession: Bool
////    var hasShownAuthView = false
////    var showAuthView = false {   //Call getAuthToken() when AuthenticationSheet has been closed
////        didSet {
////            print("GetAuthToken:sav\(showAuthView), hsav\(hasShownAuthView)")
////            if !self.showAuthView && self.hasShownAuthView {
////                print("GetAuthToken")
////                networkModel.getAuthToken()
////            }
////            print("GetAuthTokenDone")
////        }
////    }
//    
//    var body: some View {
//        ZStack {
//            Image("entryBackground")
//                .resizable()
//                .aspectRatio(contentMode: .fill)
//                .edgesIgnoringSafeArea(.all).offset(x: 0, y: 50)
//            VStack {
//                Spacer().frame(height: 80)
//                Image("SpotifyBlack")
//                    .resizable()
//                    .frame(width: 80, height: 80, alignment: .center)
//                Spacer().frame(height: 50)
//                Text("Sign in to Spotify to play the sessions music")
//                    .font(.footnote)
//                Button(action: {
//                    self.viewModel.showAuthView = true
//                    self.viewModel.hasShownAuthView = true
//                }) {
//                    Text("Connect with Spotify")
//                        .font(.headline)
//                        .padding(10)
//                }
//                Spacer().frame(height: 50)
//                Button(action: {
//                    self.currentlyInSession = true
//                }) {
//                    Text("Create Session")
//                        .modifier(RoundButtonModifier(isDisabled: networkModel.clientToken == "", backgroundColor: Color("purpleblue"), foregroundColor: Color.white))
//                }.disabled(networkModel.clientToken == "")
//                Spacer()
//            }
//            .sheet(isPresented: self.$viewModel.showAuthView) {
//                AuthenticationSheet(url:URL(string: self.networkModel.auth_url)!)   //Error when username.count < 3
//            }
//        }
//    }
//}
//
//struct AuthView_Previews: PreviewProvider {
//    @State static var currentlyInSession = false
//    @State static var auth_url = "url"
//    static var previews: some View {
//        AuthenticationView(currentlyInSession: $currentlyInSession)
//    }
//}
