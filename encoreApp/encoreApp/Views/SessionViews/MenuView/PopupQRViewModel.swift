//
//  PopupQRViewModel.swift
//  encoreApp
//
//  Created by Nikolai Madlener on 02.03.22.
//  Copyright © 2022 NikolaiEtienne. All rights reserved.
//

import Foundation
import SwiftUI

// MARK: - ViewModel
extension PopupQRCodeView {
    @MainActor class ViewModel: ObservableObject {
        
        // State
        @Published var sessionID: String = ""
        @Published var showShareSheet: Bool = false
        var showPopupQRCode: Binding<Bool>

        let filter = CIFilter.qrCodeGenerator()
        let context = CIContext()
        
        // Misc
        @Dependency(\.appState) private var appState
        private var cancelBag = CancelBag()
        init(showPopupQRCode: Binding<Bool>) {
            self.showPopupQRCode = showPopupQRCode
            
            cancelBag.collect {
                appState.map(\.session.sessionID)
                    .removeDuplicates()
                    .assign(to: \.sessionID, on: self)
            }
        }
        
        // Function
        func generateQRCodeImage() -> UIImage {
            let url = "encoreApp://\(self.appState[\.session.sessionID])"
            let data = Data(url.utf8)
            filter.setValue(data, forKey: "inputMessage")
            
            if let qrCodeImage = filter.outputImage {
                if let qrCodeCGImage = context.createCGImage(qrCodeImage, from: qrCodeImage.extent) {
                    return UIImage(cgImage: qrCodeCGImage)
                }
            }
            return UIImage(systemName: "xmark") ?? UIImage()
        }
    }
}
