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
            //.frame(width: UIScreen.main.bounds.width * 0.9)
            .background(Color("purpleblue").opacity(1))
            .cornerRadius(20)
            .padding(.vertical)
            .padding(.horizontal, 20)
            .edgesIgnoringSafeArea([.bottom])
    }
}
