//
//  PopupQRCodeView.swift
//  encoreApp
//
//  Created by Etienne Köhler on 15.08.20.
//  Copyright © 2020 NikolaiEtienne. All rights reserved.
//

import SwiftUI

struct PopupQRCodeView: View {
    @ObservedObject var userVM: UserVM
    @State var showShareSheet: Bool = false
    @Binding var showPopupQRCode: Bool
    
    var body: some View {
        VStack {
            Text("Invite your friends")
                .font(.system(size: 25, weight: .bold))
                .foregroundColor(Color.black)
                .padding(.top)
            QRCodeView(url: "encoreApp://\(self.userVM.sessionID)", size: 180).padding(10)
            saveQRCodeButton
            shareQRCodeButton
            cancelButton
        }
        .background(Color.white)
        .cornerRadius(10)
        .frame(width: UIScreen.main.bounds.width * 0.73, height: UIScreen.main.bounds.height * 0.85)
        
        .sheet(isPresented: self.$showShareSheet) {
            ActivityViewController(activityItems: ["encoreApp://\(self.userVM.sessionID)"] as [Any], applicationActivities: nil)
        }
    }
    
    var saveQRCodeButton: some View {
        Button(action: {
            
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
        }.padding()
    }
    
    var cancelButton: some View {
        Button(action: {
            self.showPopupQRCode.toggle()
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
        PopupQRCodeView(userVM: UserVM(), showPopupQRCode: $show)
    }
}
