//
//  LabeledDivider.swift
//  encoreApp
//
//  Created by Etienne Köhler on 18.07.20.
//  Copyright © 2020 NikolaiEtienne. All rights reserved.
//

import SwiftUI

struct LabeledDivider: View {
    let label: String
    let horizontalPadding: CGFloat
    let color: Color
    
    init(label: String, horizontalPadding: CGFloat = 0, color: Color = .gray) {
        self.label = label
        self.horizontalPadding = horizontalPadding
        self.color = color
    }
    
    var body: some View {
        HStack {
            line
            Text(label).foregroundColor(color)
            line
        }.padding(.horizontal, 25)
    }
    
    var line: some View {
        VStack { Divider().background(color) }
    }
}

struct LabeledDivider_Previews: PreviewProvider {
    static var previews: some View {
        LabeledDivider(label: "OR")
    }
}
