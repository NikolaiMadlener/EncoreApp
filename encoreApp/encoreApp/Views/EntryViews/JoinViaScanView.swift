//
//  JoinViaScanView.swift
//  encoreApp
//
//  Created by Nikolai Madlener on 12.06.20.
//  Copyright © 2020 NikolaiEtienne. All rights reserved.
//

import SwiftUI

//struct JoinViaScanView: View {
//    @State private var showImagePicker: Bool = false
//    @State private var image: Image? = nil
//    
//    var body: some View {
//        VStack {
//            Text("Scan the Session's QR code to join.").padding()
//            //ImagePicker(isShown: $showImagePicker, image: $image)
//            CodeScannerView(
//                codeTypes: [.qr],
//                completion: { result in
//                    if case let .success(code) = result {
//                        self.scannedCode = code
//                        self.isPresentingScanner = false
//                    }
//                }
//            )
//        }
//    }
//}
//
//struct JoinViaScanView_Previews: PreviewProvider {
//    static var previews: some View {
//        JoinViaScanView()
//    }
//}
