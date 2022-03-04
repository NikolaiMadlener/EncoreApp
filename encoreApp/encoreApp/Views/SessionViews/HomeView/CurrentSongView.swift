//
//  CurrentSongView.swift
//  encoreApp
//
//  Created by Etienne Köhler on 30.06.20.
//  Copyright © 2020 NikolaiEtienne. All rights reserved.
//

import SwiftUI

struct CurrentSongView: View {
    @StateObject var viewModel: ViewModel
    
    var body: some View {
        VStack {
            Image(uiImage: self.viewModel.albumCover)
                .resizable()
                .frame(width: 180, height: 180)
                .cornerRadius(10)
                .shadow(radius: 10)
//                .shadow(color: Color(uiColorTopLeft).opacity(0.1), radius: 8, x: -10, y: -10)
//                .shadow(color: Color(uiColorTopRight).opacity(0.1), radius: 8, x: 10, y: -10)
//                .shadow(color: Color(uiColorBottomLeft).opacity(0.1), radius: 8, x: -10, y: 10)
//                .shadow(color: Color(uiColorBottomRight).opacity(0.1), radius: 8, x: 10, y: 10)
//                .blendMode(.multiply)
            Text("\(self.viewModel.song.name)")
                .font(.system(size: 20, weight: .semibold))
                .multilineTextAlignment(.center)
                .lineLimit(1)
             
            Text("\(self.viewModel.song.artists[0])")
                .font(.system(size: 18, weight: .regular))
            
            Text("suggested by \(self.viewModel.song.suggested_by)")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(Color("purpleblue"))
                .padding(.top, 1)
            
        }.frame(width: UIScreen.main.bounds.width * 0.8)
    }
}

struct CurrentSongView_Previews: PreviewProvider {
    static var previews: some View {
        CurrentSongView(viewModel: .init())
    }
}
