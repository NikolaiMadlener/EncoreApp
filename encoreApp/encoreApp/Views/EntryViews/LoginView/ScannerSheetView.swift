//
//  ScannerSheetView.swift
//  encoreApp
//
//  Created by Etienne Köhler on 19.07.20.
//  Copyright © 2020 NikolaiEtienne. All rights reserved.
//

import SwiftUI
import CodeScanner

// MARK: - View
struct ScannerSheetView: View {
    //@Environment(\.presentationMode) var presentationMode
    @ObservedObject var viewModel: ViewModel
    @EnvironmentObject var appState: AppState
   
//    @Binding var currentlyInSession: Bool
//    @Binding var showScannerSheet: Bool
//    @Binding var showAuthSheet: Bool
//    @Binding var scannedCode: String?
//    @Binding var sessionID: String
//    @Binding var username: String
//    @Binding var secret: String
//    @Binding var invalidUsername: Bool
//    @Binding var showWrongIDAlert: Bool
//    @Binding var showUsernameExistsAlert: Bool
//    @Binding var showNetworkErrorAlert: Bool
    
    var body: some View {
        ZStack {
            CodeScannerView(
                codeTypes: [.qr],
                completion: { result in
                    if case let .success(code) = result {
                        viewModel.scanCompletion(code: code)
                        Task.init {
                            await self.viewModel.joinSession(username: appState.user.username, sessionID: viewModel.sessionID)
                        }
                        
                    }
                }
            )
            
            VStack {
                Text("Scan the session's QR code to join")
                    .padding(10)
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(Color.white)
                    .background(Color("purpleblue"))
                    .cornerRadius(10)
                    .padding(.top, 40)
                Spacer()
                Button(action: { viewModel.showScannerSheet.wrappedValue = false }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(Color("purpleblue"))
                        .font(.system(size: 50, weight: .semibold))
                        .padding()
                }
            }
        }.edgesIgnoringSafeArea(.all)
    }
}
