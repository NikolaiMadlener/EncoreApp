//
//  MenuViewModel.swift
//  encoreApp
//
//  Created by Nikolai Madlener on 02.03.22.
//  Copyright © 2022 NikolaiEtienne. All rights reserved.
//

import Foundation

// MARK: - ViewModel
extension MenuView {
    @MainActor class ViewModel: ObservableObject {
        
        // State
        @Published var showDeleteAlert: Bool = false
        @Published var showLeaveAlert: Bool = false
        @Published var showSessionExpiredAlert: Bool = false
        @Published var showShareSheet: Bool = false
        @Published var showPopupQRCode: Bool = false
        @Published var sessionID: String = ""
        @Published var members: [UserListElement] = []
        @Published var currentlyInSession: Bool = true
        @Published var currentUser: String = ""
        @Published var isUserAdmin: Bool = false
        
        // Misc
        @Dependency(\.appState) private var appState
        @Dependency(\.sessionService) private var sessionService
        private var cancelBag = CancelBag()
        init() {
            cancelBag.collect {
                appState.map(\.session.sessionID)
                    .removeDuplicates()
                    .assign(to: \.sessionID, on: self)
                appState.map(\.members)
                    .removeDuplicates()
                    .assign(to: \.members, on: self)
                $currentlyInSession
                    .sink { self.appState[\.session.currentlyInSession] = $0 }
                appState.map(\.session.currentlyInSession)
                    .removeDuplicates()
                    .assign(to: \.currentlyInSession, on: self)
                appState.map(\.user.username)
                    .removeDuplicates()
                    .assign(to: \.currentUser, on: self)
                appState.map(\.user.isAdmin)
                    .removeDuplicates()
                    .assign(to: \.isUserAdmin, on: self)
            }
        }
        
        // Functions
        func getMembers() {
            sessionService.getMembers()
        }
        
        func deleteSession() {
            sessionService.deleteSession()
        }
        
        func leaveSession() {
            sessionService.leaveSession()
        }
        
        func showAlert() {
            if isUserAdmin {
                self.showDeleteAlert = true
            } else {
                self.showLeaveAlert = true
            }
        }
    }
}
