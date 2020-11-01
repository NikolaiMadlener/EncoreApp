//
//  LoginAlertsModifier.swift
//  encoreApp
//
//  Created by Etienne Köhler on 01.11.20.
//  Copyright © 2020 NikolaiEtienne. All rights reserved.
//

import Foundation
import SwiftUI

struct LoginAlertsModifier: ViewModifier {
    @Binding var showServerErrorAlert: Bool
    @Binding var showWrongIDAlert: Bool
    @Binding var showUsernameExistsAlert: Bool
    @Binding var showNetworkErrorAlert: Bool
    
    func body(content: Content) -> some View {
        content
            .alert(isPresented: $showServerErrorAlert) {
                serverError
            }.alert(isPresented: $showWrongIDAlert) {
                sessionIDError
            }.alert(isPresented: $showUsernameExistsAlert) {
                invalidNameError
            }.alert(isPresented: $showNetworkErrorAlert) {
                networkError
            }
    }
    
    var serverError: Alert {
        Alert(title: Text("Server Error"),
              message: Text(""),
              dismissButton: .default(Text("OK"), action: { self.showServerErrorAlert = false }))
    }
    
    var sessionIDError: Alert {
        Alert(title: Text("Session doesn't exist"),
              message: Text("Try again"),
              dismissButton: .default(Text("OK"), action: { self.showWrongIDAlert = false }))
    }
    
    var invalidNameError: Alert {
        Alert(title: Text("Invalid Name"),
              message: Text("A user with the given username already exists."),
              dismissButton: .default(Text("OK"), action: { self.showWrongIDAlert = false }))
    }
    
    var networkError: Alert {
        Alert(title: Text("Network Error"),
              message: Text("The Internet connection appears to be offline."),
              dismissButton: .default(Text("OK"), action: { self.showWrongIDAlert = false }))
    }
}
