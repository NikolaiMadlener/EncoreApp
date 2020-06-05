//
//  Blur.swift
//  encoreApp
//
//  Created by Nikolai Madlener on 03.06.20.
//  Copyright © 2020 NikolaiEtienne. All rights reserved.
//

import SwiftUI

struct Blur: UIViewRepresentable {
    @Environment(\.colorScheme) var colorScheme
    
    var style: UIBlurEffect.Style

    init(colorScheme: ColorScheme) {
        self.style = (colorScheme == .dark ? .systemThinMaterialDark : .systemThinMaterialLight)
    }
    
    func makeUIView(context: Context) -> UIVisualEffectView {
        return UIVisualEffectView(effect: UIBlurEffect(style: style))
    }
    func updateUIView(_ uiView: UIVisualEffectView, context: Context) {
        uiView.effect = UIBlurEffect(style: style)
    }
}
