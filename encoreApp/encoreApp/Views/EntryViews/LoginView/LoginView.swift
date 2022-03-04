//
//  ContentView.swift
//  encoreApp
//
//  Created by Nikolai Madlener on 26.05.20.
//  Copyright © 2020 NikolaiEtienne. All rights reserved.
//

import SwiftUI
import SafariServices

// MARK: - View
struct LoginView: View {
    @StateObject var viewModel: ViewModel
    
    var body: some View {
        NavigationView {
            ZStack {
                VStack {
                    Spacer()
                    Image("vinyl")
                        .resizable()
                        .scaledToFit()
                        .offset(x:0,y:70)
                        .scaleEffect(x:1.3, y:1.3)
                }.ignoresSafeArea(.keyboard)
                
                VStack {
                    Text("encore.")
                        .font(.largeTitle)
                        .bold()
                    Spacer().frame(height: 40)
                    TextField("Enter your Name", text: self.$viewModel.username)
                        .padding(15)
                        .overlay(
                            RoundedRectangle(cornerRadius: 15)
                                .stroke(Color.gray, lineWidth: 1)
                        ).padding(.horizontal, 25)
                    if viewModel.invalidUsername {
                        Text("Name should be between 3 and 10 characters long and free of special characters and spaces.")
                            .font(.system(size: 12))
                            .foregroundColor(.red)
                            .padding(.horizontal, 25)
                    }
                    Spacer().frame(height: 20)
                    Group {
                        Button(action: {
                            viewModel.joinSession()
                        }) {
                            Text("Join Session")
                                        .modifier(ButtonHeavyModifier(isDisabled: viewModel.username.count < 1, backgroundColor: Color("purpleblue"), foregroundColor: Color.white))
                        }
                                .disabled(viewModel.username.count < 1)
                                .fullScreenCover(isPresented: self.$viewModel.showScannerSheet) {
                                    ScannerSheetView(viewModel: .init(showScannerSheet: $viewModel.showScannerSheet))
                        }
                        LabeledDivider(label: "or")
                        VStack {
                            ZStack {
                                Button(action: {
                                    Task.init {
                                        await self.viewModel.createSession()
                                    }
                                }) {
                                    ZStack {
                                        if !viewModel.showActivityIndicator {
                                            Text("Create Session")
                                        } else {
                                            ActivityIndicator()
                                                .frame(width: 20, height: 20).foregroundColor(Color("purpleblue"))
                                        }
                                    }
                                    .modifier(ButtonLightModifier(isDisabled: viewModel.username.count < 1, foregroundColor: Color("purpleblue")))
                                    
                                }.disabled(viewModel.username.count < 1)
                            }.sheet(isPresented: self.$viewModel.showAuthSheet, onDismiss: {
                                Task.init {
                                    await self.viewModel.authorize()
                                }
                            }) {
                                AuthenticationWebView(viewModel: .init(),
                                                      showAuthSheet: self.$viewModel.showAuthSheet,
                                                      showActivityIndicator: self.$viewModel.showActivityIndicator)
                            }
                        }
                        Spacer()
                    }
                }.alert(isPresented: $viewModel.showServerErrorAlert) {
                    Alert(title: Text("Server Error"),
                          message: Text(""),
                          dismissButton: .default(Text("OK"), action: { self.viewModel.showServerErrorAlert = false }))
                }.alert(isPresented: $viewModel.showWrongIDAlert) {
                    Alert(title: Text("Session doesn't exist"),
                          message: Text("Try again"),
                          dismissButton: .default(Text("OK"), action: { self.viewModel.showWrongIDAlert = false }))
                }.alert(isPresented: $viewModel.showUsernameExistsAlert) {
                    Alert(title: Text("Invalid Name"),
                          message: Text("A user with the given username already exists."),
                          dismissButton: .default(Text("OK"), action: { self.viewModel.showWrongIDAlert = false }))
                }.alert(isPresented: $viewModel.showNetworkErrorAlert) {
                    Alert(title: Text("Network Error"),
                          message: Text("The Internet connection appears to be offline."),
                          dismissButton: .default(Text("OK"), action: { self.viewModel.showWrongIDAlert = false }))
                }
            }
        }
    }
}


// MARK: - Preview

#if DEBUG
struct ContentView_Previews: PreviewProvider {
    @State static var signInSuccess = false
    @State static var sessionID = ""
    
    static var previews: some View {
        LoginView(viewModel: .init())
    }
}
#endif





