//
//  JoinViaURLView.swift
//  encoreApp
//
//  Created by Nikolai Madlener on 04.06.20.
//  Copyright © 2020 NikolaiEtienne. All rights reserved.
//

import SwiftUI

struct JoinViaURLView: View {
    @StateObject var viewModel: ViewModel
    var sessionID: String
    
    var body: some View {
        VStack {
            Text("Join \(viewModel.members.first(where: { $0.is_admin })?.username ?? "Host") Session.")
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
                    await self.viewModel.joinSession(sessionID: sessionID)
                }
            }) {
                ZStack {
                    if !viewModel.showActivityIndicator {
                        Text("Join Session")
                    } else {
                        ProgressView().progressViewStyle(CircularProgressViewStyle(tint: Color("purpleblue")))
                    }
                }
                .modifier(ButtonHeavyModifier(isDisabled: viewModel.username.count < 1, backgroundColor: Color("purpleblue"), foregroundColor: Color.white))
            }.padding(.bottom)
                .disabled(viewModel.username.count < 1)
                .alert(isPresented: $viewModel.showAlert) {
                    Alert(title: Text(viewModel.alertInfo.title),
                          message: Text(viewModel.alertInfo.message),
                          dismissButton: .default(Text("OK"), action: { self.viewModel.showAlert = false }))
                    
                    //                .alert(isPresented: $viewModel.showWrongIDAlert) {
                    //                    Alert(title: Text("Session doesn't exist"),
                    //                          message: Text(""),
                    //                          dismissButton: .default(Text("OK"), action: { self.viewModel.showWrongIDAlert = false }))
                    //            }
                    //                .alert(isPresented: $viewModel.showUsernameExistsAlert) {
                    //                    Alert(title: Text("Invalid Name"),
                    //                          message: Text("A user with the given username already exists."),
                    //                          dismissButton: .default(Text("OK"), action: { self.viewModel.showWrongIDAlert = false }))
                    //            }
                    //                .alert(isPresented: $viewModel.showNetworkErrorAlert) {
                    //                    Alert(title: Text("Network Error"),
                    //                          message: Text("The Internet connection appears to be offline."),
                    //                          dismissButton: .default(Text("OK"), action: { self.viewModel.showWrongIDAlert = false }))
                }.onAppear{
                    viewModel.getMembers(sessionID: sessionID)
                }
        }
    }
}

struct JoinViaURLView_Previews: PreviewProvider {
    static var previews: some View {
        JoinViaURLView(viewModel: .init(), sessionID: "")
    }
}
