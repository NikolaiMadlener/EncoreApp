//
//  ScannerView.swift
//  encoreApp
//
//  Created by Etienne Köhler on 22.12.20.
//  Copyright © 2020 NikolaiEtienne. All rights reserved.
//

import SwiftUI

struct ScannerView: View {
    @ObservedObject var viewModel: ScannerViewModel
    
    var body: some View {
        ZStack {
            QrCodeScannerView()
            .found(r: self.viewModel.onFoundQrCode)
            .torchLight(isOn: self.viewModel.torchIsOn)
            .interval(delay: self.viewModel.scanInterval)
            
            VStack {
                Text("Scan the session's QR code to join")
                    .padding(10)
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(Color("purpleblue"))
                    .background(Color.white)
                    .cornerRadius(10)
                    .padding(.top, 40)
                
                Spacer()
                Button(action: { self.viewModel.showScannerSheet = false }) {
                    ZStack {
                        Circle().frame(width: 59, height: 59).foregroundColor(Color("purpleblue")).cornerRadius(20)
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 60, weight: .regular))
                            .foregroundColor(Color.white)
                    }
                }.padding(.bottom, 20)
                
            }.padding()
        }.edgesIgnoringSafeArea(.all)
    }
}
