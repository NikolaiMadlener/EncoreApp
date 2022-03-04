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
    @Environment(\.colorScheme) var colorScheme
    @StateObject var viewModel: ViewModel
    
    var body: some View {
        VStack {
            Text("Invite your friends")
                .font(.system(size: 25, weight: .bold))
                .foregroundColor(self.colorScheme == .dark ? Color.white : Color.black)
                .padding(.top)
            QRCodeView(url: "encoreApp://\(self.viewModel.sessionID)", size: 180)
                .padding(10)
                .modifier(BlueCardModifier(color: Color.white))
                
            multipleButtons
            cancelButton
        }.background(Color(uiColor: .systemGray6))
        .cornerRadius(20)
        .frame(width: UIScreen.main.bounds.width * 0.75, height: UIScreen.main.bounds.height * 0.85)
        .sheet(isPresented: self.$viewModel.showShareSheet) {
            ActivityViewController(activityItems: ["encoreApp://\(self.viewModel.sessionID)"] as [Any], applicationActivities: nil)
        }
    }
    
    var multipleButtons: some View {
        VStack(spacing: 0) {
            saveQRCodeButton
            Divider()
            shareQRCodeButton
        }.modifier(BlueCardModifier())
    }
    
    var saveQRCodeButton: some View {
        Button(action: {
            UIImageWriteToSavedPhotosAlbum(self.viewModel.generateQRCodeImage(), nil, nil, nil)
        }) {
            HStack {
                Text("Save QR Code")
                    .font(.headline)
                    .padding(.leading)
                Spacer()
                Image(systemName: "square.and.arrow.down")
                    .font(.system(size: 20, weight: .medium))
                    .padding(.trailing)
            }.foregroundColor(Color("purpleblue"))
        }.padding(10)
    }
    
    var shareQRCodeButton: some View {
        Button(action: {
            self.viewModel.showShareSheet.toggle()
        }) {
            HStack {
                Text("Share Invite Link")
                    .font(.headline)
                    .padding(.leading)
                Spacer()
                Image(systemName: "square.and.arrow.up")
                    .font(.system(size: 20, weight: .medium))
                    .padding(.trailing)
            }.foregroundColor(Color("purpleblue"))
        }.padding(10)
    }
    
    var cancelButton: some View {
        Button(action: {
            self.viewModel.showPopupQRCode.wrappedValue.toggle()
        }) {
            Text("Cancel")
                .font(.headline)
                .foregroundColor(Color("purpleblue"))
                .padding(.bottom)
        }
    }
}

struct PopupQRCodeView_Previews: PreviewProvider {
    @State static var show = false
    static var previews: some View {
        PopupQRCodeView(viewModel: .init(showPopupQRCode: $show))
    }
}
