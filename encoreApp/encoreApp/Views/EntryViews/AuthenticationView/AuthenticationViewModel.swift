////
////  AuthenticationViewModel.swift
////  encoreApp
////
////  Created by Etienne Köhler on 23.06.20.
////  Copyright © 2020 NikolaiEtienne. All rights reserved.
////
//
//import Foundation
//import Combine
//import SwiftUI
//
//class AuthenticationViewModel: ObservableObject {
//    @ObservedObject var networkModel: NetworkModel = .shared
//    @Published var hasShownAuthView = false
//    @Published var showAuthView = false {   //Call getAuthToken() when AuthenticationSheet has been closed
//        didSet {
//            print("GetAuthToken:sav\(showAuthView), hsav\(hasShownAuthView)")
//            if !self.showAuthView && self.hasShownAuthView {
//                print("GetAuthToken")
//                networkModel.getClientToken()
//                print("ClientToken::\(networkModel.clientToken)")
//            }
//            print("GetAuthTokenDone")
//        }
//    }
//
//}
