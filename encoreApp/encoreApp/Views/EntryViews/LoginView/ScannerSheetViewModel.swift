//
//  ScannerSheetViewModel.swift
//  encoreApp
//
//  Created by Nikolai Madlener on 28.02.22.
//  Copyright © 2022 NikolaiEtienne. All rights reserved.
//

import Foundation
import SwiftUI

// MARK: - ViewModel
extension ScannerSheetView {
    @MainActor class ViewModel: ObservableObject {
        
        // State
        var showScannerSheet: Binding<Bool>
        var sessionID: String = ""
        
        // Misc
        @Dependency(\.loginService) private var loginService
        @Dependency(\.appState) private var appState
        init(showScannerSheet: Binding<Bool>) {
            self.showScannerSheet = showScannerSheet
        }
        
        // Functions
        func joinSession() async {
            do {
                try await loginService.joinSession(username: appState[\.user.username], sessionID: self.sessionID)
                try await loginService.getClientToken()
            }
            catch LoginError.invalidServerResponse {
                
            }
            catch LoginError.unsupportedFormat {
               
            }
            catch {
                
            }
        }
        
        func scanCompletion(code: String) {
            self.showScannerSheet.wrappedValue = false
            if code.count > 12 {
                self.sessionID = code.substring(from: code.index(code.startIndex, offsetBy: 12))
            } else {
                self.sessionID = ""
            }  
        }
    }
}
