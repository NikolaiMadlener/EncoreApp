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
    @Environment(\.colorScheme) var colorScheme
    var color: Color?
    
    func body(content: Content) -> some View {
        content
            .background(color ?? (self.colorScheme == .dark ? Color(uiColor: UIColor.systemGray5) : Color.white))
            .cornerRadius(20)
            .padding(.vertical)
            .padding(.horizontal, 20)
            //.shadow(radius: 7)
            .edgesIgnoringSafeArea([.bottom])
    }
}
