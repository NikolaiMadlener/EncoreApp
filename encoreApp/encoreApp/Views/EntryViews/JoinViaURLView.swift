//
//  JoinViaURLView.swift
//  encoreApp
//
//  Created by Nikolai Madlener on 04.06.20.
//  Copyright © 2020 NikolaiEtienne. All rights reserved.
//

import SwiftUI

struct JoinViaURLView: View {
    @EnvironmentObject var appState: AppState
    @ObservedObject var viewModel: ViewModel
    @ObservedObject var userListVM: UserListVM
    var sessionID: String
   
    init(viewModel: ViewModel, username: String, sessionID: String) {
        self.userListVM = UserListVM(username: username, sessionID: sessionID)
        self.sessionID = sessionID
        self.viewModel = viewModel
    }
    
    var body: some View {
        VStack {
            Text("encore.")
                .font(.system(size: 30, weight: .bold))
                .padding(.bottom, 10)
            Spacer().frame(height: 40)
            TextField("Enter your Name", text: self.$viewModel.username)
            .padding(15)
            .overlay(
                RoundedRectangle(cornerRadius: 15)
                    .stroke(Color.gray, lineWidth: 1)
            ).padding(.horizontal, 25)
            if viewModel.invalidUsername {
                Text("Name should be between three and 10 characters long and free of special characters and spaces.")
                    .font(.system(size: 12))
                    .foregroundColor(.red)
                    .padding(.horizontal, 25)
            }
            Spacer().frame(height: 20)
            Button(action: {
                Task.init {
                    await self.viewModel.joinSession(username: self.viewModel.username, sessionID: sessionID)
                }
            }) {
                ZStack {
                    if !viewModel.showActivityIndicator {
                        Text("Join Session")
                    } else {
                        ActivityIndicator()
                            .frame(width: 20, height: 20).foregroundColor(Color.white)
                    }
                }
                .modifier(ButtonHeavyModifier(isDisabled: viewModel.username.count < 1, backgroundColor: Color("purpleblue"), foregroundColor: Color.white))
            }.padding(.bottom)
                .disabled(viewModel.username.count < 1)
                .alert(isPresented: $viewModel.showWrongIDAlert) {
                    Alert(title: Text("Session doesn't exist"),
                          message: Text(""),
                          dismissButton: .default(Text("OK"), action: { self.viewModel.showWrongIDAlert = false }))
            }
                .alert(isPresented: $viewModel.showUsernameExistsAlert) {
                    Alert(title: Text("Invalid Name"),
                          message: Text("A user with the given username already exists."),
                          dismissButton: .default(Text("OK"), action: { self.viewModel.showWrongIDAlert = false }))
            }
                .alert(isPresented: $viewModel.showNetworkErrorAlert) {
                    Alert(title: Text("Network Error"),
                          message: Text("The Internet connection appears to be offline."),
                          dismissButton: .default(Text("OK"), action: { self.viewModel.showWrongIDAlert = false }))
            }
        }
    }
}

struct JoinViaURLView_Previews: PreviewProvider {
    static var previews: some View {
        JoinViaURLView(viewModel: .init(), username: "", sessionID: "")
    }
}
