//
//  AsyncImage.swift
//  encoreApp
//
//  Created by Nikolai Madlener on 20.06.20.
//  Copyright © 2020 NikolaiEtienne. All rights reserved.
//

import Foundation
import SwiftUI

struct AsyncImage: View {
    @ObservedObject private var loader: ImageLoader
    private let placeholder: Image
    
    init(url: URL, placeholder: Image) {
        loader = ImageLoader(url: url)
        self.placeholder = placeholder
    }

    var body: some View {
        if let image = loader.image {
           
            Image(uiImage: image)
//                .onAppear {}
//                .onDisappear {}
        }

            return placeholder
                .onAppear {
                    self.loader.load()
                }
                .onDisappear {
                    self.loader.cancel()
                }
        
    }
    
//    private var image: some View {
//        Group {
//            if loader.image != nil {
//                Image(uiImage: loader.image!)
//                    .resizable()
//            } else {
//                placeholder
//                    .resizable()
//            }
//        }
//    }
}
