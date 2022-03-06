//
//  JoinViaURLViewModel.swift
//  encoreApp
//
//  Created by Nikolai Madlener on 01.03.22.
//  Copyright © 2022 NikolaiEtienne. All rights reserved.
//

import Foundation

// MARK: - ViewModel
extension JoinViaURLView {
    @MainActor class ViewModel: ObservableObject {
        
        // State
        @Published var username: String = ""
        @Published var invalidUsername: Bool = false
        @Published var showActivityIndicator: Bool = false
        @Published var members: [UserListElement] = []
        @Published var showAlert: Bool = false
        var alertInfo: AlertInfo = AlertInfo(title: "", message: "")
    
        
        // Misc
        @Dependency(\.loginService) private var loginService
        @Dependency(\.sessionService) private var sessionService
        
        // Functions
        func joinSession(sessionID: String) async {
            do {
                try await loginService.joinSession(username: self.username, sessionID: sessionID)
                try await loginService.getClientToken()
                showActivityIndicator = false
            }
            catch LoginError.invalidServerResponse {
                showActivityIndicator = false
                alertInfo = AlertInfo(title: "Server Error", message: "")
                showAlert = true
            }
            catch LoginError.usernameAlreadyExists {
                showActivityIndicator = false
                alertInfo = AlertInfo(title: "Invalid Name", message: "A user with the given username already exists in this session.")
                showAlert = true
            }
            catch {
                showActivityIndicator = false
                alertInfo = AlertInfo(title: "Something went wrong", message: "Try again")
                showAlert = true
            }
        }
        
        func getMembers(sessionID: String) {
            sessionService.getMembers(sessionID: sessionID)
        }
    }
}
