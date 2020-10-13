//
//  BlueCardModifier.swift
//  encoreApp
//
//  Created by Etienne Köhler on 13.10.20.
//  Copyright © 2020 NikolaiEtienne. All rights reserved.
//

import Foundation
import SwiftUI

struct BlueCardModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .frame(width: UIScreen.main.bounds.width)
            .background(Color("purpleblue"))
            .cornerRadius(20, corners: [.topLeft, .topRight])
            .padding(.top)
            .edgesIgnoringSafeArea([.bottom])
    }
}
