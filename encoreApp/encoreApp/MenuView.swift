//
//  MenuView.swift
//  encoreApp
//
//  Created by Nikolai Madlener on 29.05.20.
//  Copyright © 2020 NikolaiEtienne. All rights reserved.
//

import SwiftUI

struct MenuView: View {
    @Binding var currentlyInSession: Bool
    @State var showAlert = false
    
    var body: some View {
        VStack {
            Spacer().frame(height: 50)
            Image("qrcode").padding()
            Spacer()
            Button(action: { self.showAlert = true }) {
                // if Host
                Text("Delete Session")
                    .padding(15)
                    .background(Color.red)
                    .foregroundColor(Color.white)
                    .cornerRadius(25)
                // else Button Text should be "Leave Session"
                // TODO
                
            }.alert(isPresented: $showAlert) {
                    Alert(title: Text("Delete Session"),
                          message: Text("By Deleting the current Session all Members will be kicked."),
                          primaryButton: .destructive(Text("Delete"), action: {
                            self.currentlyInSession = false
                            //TODO: API call to Server to delete session there
                          }),
                          secondaryButton: .cancel(Text("Cancel"), action: {
                            self.showAlert = false
                          }))
            }
        }
    }
}

struct MenuView_Previews: PreviewProvider {
    @State static var signInSuccess = false
    
    static var previews: some View {
        MenuView(currentlyInSession: $signInSuccess)
    }
}
