//
//  VoteState.swift
//  encoreApp
//
//  Created by Etienne Köhler on 29.05.20.
//  Copyright © 2020 NikolaiEtienne. All rights reserved.
//

import Foundation
import SwiftUI

public enum VoteState: Int32 {
    
    case NEUTRAL, UPVOTE, DOWNVOTE
    
    var number: Int32 {
        switch self {
        case .NEUTRAL:
            return 0
        case .UPVOTE:
            return 1
        case .DOWNVOTE:
            return 2
        }
    }
    
    var color: Color {
        switch self {
        case .NEUTRAL:
            return Color.gray
        case .UPVOTE:
            return Color.green
        case .DOWNVOTE:
            return Color.red
        }
    }
}
