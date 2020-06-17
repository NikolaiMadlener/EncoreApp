//
//  QRCodeView.swift
//  encoreApp
//
//  Created by Nikolai Madlener on 12.06.20.
//  Copyright © 2020 NikolaiEtienne. All rights reserved.
//

import SwiftUI
import CoreImage.CIFilterBuiltins

struct QRCodeView: View {
    let context = CIContext()
    let filter = CIFilter.qrCodeGenerator()
    var url: String
    
    var body: some View {
        Image(uiImage: generateQRCodeImage(url))
            .interpolation(.none)
            .resizable()
            .frame(width: 150, height: 150)
    }
    
    func generateQRCodeImage(_ url: String) -> UIImage {
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

struct QRCodeView_Previews: PreviewProvider {
    static let url = "encoreapp://test"
    
    static var previews: some View {
        QRCodeView(url: url)
    }
}
