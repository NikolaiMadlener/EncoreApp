//
//  PopupQRView.swift
//  encoreApp
//
//  Created by Etienne Köhler on 03.10.20.
//  Copyright © 2020 NikolaiEtienne. All rights reserved.
//

import SwiftUI
import CoreImage.CIFilterBuiltins

struct PopupQRCodeView: View {
    @ObservedObject var userVM: UserVM
    @State var showShareSheet: Bool = false
    @Binding var showPopupQRCode: Bool
    let filter = CIFilter.qrCodeGenerator()
    let context = CIContext()
    
    var body: some View {
        VStack {
            Text("scan this qr code.")
                .font(.system(size: 25, weight: .bold))
                .foregroundColor(Color.white)
                .padding(.top)
            QRCodeView(url: "encoreApp://\(self.userVM.sessionID)", size: 180).padding(10)
            LabeledDivider(label: "or")
            shareQRCodeButton
            cancelButton
        }.background(Color("superdarkgray"))
        .cornerRadius(20)
        .frame(width: UIScreen.main.bounds.width * 0.9, height: UIScreen.main.bounds.height * 0.8)
        .sheet(isPresented: self.$showShareSheet) {
            ActivityViewController(activityItems: ["encoreApp://\(self.userVM.sessionID)"] as [Any], applicationActivities: nil)
        }
    }
    
    var saveQRCodeButton: some View {
        Button(action: {
            UIImageWriteToSavedPhotosAlbum(self.generateQRCodeImage("encoreApp://\(self.userVM.sessionID)"), nil, nil, nil)
        }) {
            Text("Save QR Code")
                .modifier(ButtonHeavyModifier(isDisabled: false, backgroundColor: Color("purpleblue"), foregroundColor: Color.white))
        }.padding(.horizontal)
    }
    
    var shareQRCodeButton: some View {
        Button(action: {
            self.showShareSheet.toggle()
        }) {
            Text("Share Invite Link")
                .modifier(ButtonHeavyModifier(isDisabled: false, backgroundColor: Color("purpleblue"), foregroundColor: Color.white))
        }.padding(10)
    }
    
    var cancelButton: some View {
        Button(action: {
            self.showPopupQRCode.toggle()
        }) {
            Text("Cancel")
                .font(.headline)
                .foregroundColor(Color("fontLightGray"))
                .padding(.bottom)
        }
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

struct PopupQRCodeView_Previews: PreviewProvider {
    @State static var show = false
    static var previews: some View {
        PopupQRCodeView(userVM: UserVM(), showPopupQRCode: $show)
    }
}
