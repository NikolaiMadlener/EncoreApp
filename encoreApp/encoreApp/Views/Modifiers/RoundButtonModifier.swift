//
//  RoundedButton.swift
//  encoreApp
//
//  Created by Etienne Köhler on 23.06.20.
//  Copyright © 2020 NikolaiEtienne. All rights reserved.
//

import SwiftUI

struct RoundButtonModifier: ViewModifier {
    var isDisabled: Bool
    var backgroundColor: Color
    var foregroundColor: Color
    func body(content: Content) -> some View {
        content
            .font(.headline)
            .padding(15)
            .frame(minWidth: 0, maxWidth: .infinity)
            .background(isDisabled ? Color("buttonDisabledGray") : backgroundColor)
            .foregroundColor(isDisabled ? Color("lightgray") : foregroundColor)
            .cornerRadius(25)
            .padding(.horizontal, 25)
    }
}
