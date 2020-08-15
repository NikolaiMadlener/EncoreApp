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
    
    var body: some View {
        VStack {
            Text("Invite your friends").font(.title).bold().padding(.top)
            QRCodeView(url: "encoreApp://\(self.userVM.sessionID)", size: 200).padding(10)
            saveQRCodeButton
            shareQRCodeButton
        }
        .background(Color.white)
        .cornerRadius(10)
        .frame(width: UIScreen.main.bounds.width * 0.8, height: UIScreen.main.bounds.height * 0.85)
        
        .sheet(isPresented: self.$showShareSheet) {
            ActivityViewController(activityItems: ["encoreApp://\(self.userVM.sessionID)"] as [Any], applicationActivities: nil)
        }
    }
    
    var saveQRCodeButton: some View {
        Button(action: {
            self.showShareSheet.toggle()
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
}

struct PopupQRCodeView_Previews: PreviewProvider {
    static var previews: some View {
        PopupQRCodeView(userVM: UserVM())
    }
}
