//
//  SongListCellModifier.swift
//  encoreApp
//
//  Created by Etienne Köhler on 20.12.20.
//  Copyright © 2020 NikolaiEtienne. All rights reserved.
//

import SwiftUI

struct SongListCellModifier: ViewModifier {
    
    func body(content: Content) -> some View {
        content
            .padding(.vertical, 10)
            .frame(minWidth: 0, maxWidth: .infinity)
            .background(Color("mediumdarkgray"))
            .foregroundColor(Color.white)
            .cornerRadius(15)
            .padding(.horizontal, 8)
            .padding(.vertical, 5)
    }
}
