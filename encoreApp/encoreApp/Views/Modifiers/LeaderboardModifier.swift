//
//  BlueCardModifier.swift
//  encoreApp
//
//  Created by Etienne Köhler on 13.10.20.
//  Copyright © 2020 NikolaiEtienne. All rights reserved.
//

import Foundation
import SwiftUI

struct LeaderboardModifier: ViewModifier {
    @Environment(\.colorScheme) var colorScheme
    
    func body(content: Content) -> some View {
        content
            .background(self.colorScheme == .dark ? Color("mediumdarkgray") : Color.white)
            .cornerRadius(20)
            .padding(.vertical)
            .padding(.horizontal, 20)
            .shadow(radius: 7)
    }
}
