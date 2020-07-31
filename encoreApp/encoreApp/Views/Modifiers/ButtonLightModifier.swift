//
//  ButtonLightModifier.swift
//  encoreApp
//
//  Created by Etienne Köhler on 19.07.20.
//  Copyright © 2020 NikolaiEtienne. All rights reserved.
//

import SwiftUI

struct ButtonLightModifier: ViewModifier {
    var isDisabled: Bool
    var foregroundColor: Color
    func body(content: Content) -> some View {
        content
            .font(.headline)
            .padding(15)
            .frame(minWidth: 0, maxWidth: .infinity)
            .foregroundColor(isDisabled ? Color.gray : foregroundColor)
            .overlay(
                RoundedRectangle(cornerRadius: 15)
                    .stroke(isDisabled ? Color.gray : foregroundColor, lineWidth: 2)
            ).padding(.horizontal, 25)
    }
}
