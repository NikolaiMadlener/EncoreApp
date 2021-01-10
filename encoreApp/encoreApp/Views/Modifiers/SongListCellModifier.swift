//
//  SongListCellModifier.swift
//  encoreApp
//
//  Created by Etienne Köhler on 20.12.20.
//  Copyright © 2020 NikolaiEtienne. All rights reserved.
//

import SwiftUI

struct SongListCellModifier: ViewModifier {
    @Binding var voteState: VoteState
    
    func body(content: Content) -> some View {
        content
            .padding(.vertical, 10)
            .frame(minWidth: 0, maxWidth: .infinity)
            .background(Color("mediumdarkgray"))
            .cornerRadius(15)
            .foregroundColor(voteState.color)
//            .overlay(
//                RoundedRectangle(cornerRadius: 15)
//                    .stroke(voteState.color, lineWidth: 3)
//            )
            .padding(.horizontal, 8)
            .padding(.vertical, 5)
    }
}
