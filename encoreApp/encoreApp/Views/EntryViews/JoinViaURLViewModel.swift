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
        
        @Published var showServerErrorAlert: Bool = false
        @Published var showWrongIDAlert: Bool = false
        @Published var showUsernameExistsAlert: Bool = false
        @Published var showNetworkErrorAlert: Bool = false
        
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
                showServerErrorAlert = true
            }
            catch LoginError.usernameAlreadyExists {
                showActivityIndicator = false
                showUsernameExistsAlert = true
            }
            catch {
                showActivityIndicator = false
                showWrongIDAlert = true
            }
        }
        
        func getMembers(sessionID: String) {
            sessionService.getMembers(sessionID: sessionID)
        }
    }
}
