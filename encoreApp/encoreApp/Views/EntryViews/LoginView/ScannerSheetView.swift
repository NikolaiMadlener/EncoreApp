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
    @StateObject var viewModel: ViewModel
    
    var body: some View {
        ZStack {
            CodeScannerView(
                codeTypes: [.qr],
                completion: { result in
                    if case let .success(code) = result {
                        viewModel.scanCompletion(code: code)
                        Task.init {
                            await self.viewModel.joinSession()
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
