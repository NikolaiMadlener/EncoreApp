//
//  LoginViewModel.swift
//  encoreApp
//
//  Created by Nikolai Madlener on 28.02.22.
//  Copyright © 2022 NikolaiEtienne. All rights reserved.
//

import Foundation

// MARK: - ViewModel
extension LoginView {
    @MainActor class ViewModel: ObservableObject {
        
        // State
        @Published var username: String = ""
        @Published var scannedCode: String?
        @Published var invalidUsername: Bool = false
        @Published var showActivityIndicator: Bool = false
        
        @Published var showAuthSheet: Bool = false
        @Published var showScannerSheet: Bool = false
        
        @Published var showServerErrorAlert: Bool = false
        @Published var showWrongIDAlert: Bool = false
        @Published var showUsernameExistsAlert: Bool = false
        @Published var showNetworkErrorAlert: Bool = false
        
        // Misc
        @Dependency(\.loginService) private var loginService
        
        // Functions
        func checkUsernameInvalid() {
            invalidUsername = loginService.checkUsernameInvalid(username: username)
        }
        
        func createSession() async {
            self.checkUsernameInvalid()
            if invalidUsername {
                return
            }
            showActivityIndicator = true
            
            do {
                try await loginService.createSession(username: username)
                try await loginService.getClientToken()
                showActivityIndicator = false
                showAuthSheet = true
            }
            catch LoginError.invalidServerResponse {
                showActivityIndicator = false
                showServerErrorAlert = true
            }
            catch LoginError.unsupportedFormat {
                showActivityIndicator = false
                showServerErrorAlert = true
            }
            catch {
                showActivityIndicator = false
            }
        }
        
        func joinSession() {
            self.checkUsernameInvalid()
            if invalidUsername {
                return
            }
            showScannerSheet = true
        }
        
        func authorize() async {
            do {
                try await loginService.getAuthToken()
                try await loginService.getDeviceID()
                try await loginService.connectWithSpotify()
                showActivityIndicator = false
                //self.musicController.doConnect()
                //self.musicController.pausePlayback()
            }
            catch LoginError.invalidServerResponse {
                showActivityIndicator = false
                showServerErrorAlert = true
            }
            catch LoginError.unsupportedFormat {
                showActivityIndicator = false
                showServerErrorAlert = true
            }
            catch {
                showActivityIndicator = false
            }
        }
    }
}
