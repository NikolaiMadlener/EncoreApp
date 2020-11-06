//
//  CurrentSongView.swift
//  encoreApp
//
//  Created by Etienne Köhler on 30.06.20.
//  Copyright © 2020 NikolaiEtienne. All rights reserved.
//

import SwiftUI

struct CurrentSongView: View {
    @Environment(\.colorScheme) var colorScheme
    @ObservedObject var playerStateVM: PlayerStateVM
    var albumWidth: CGFloat
//    var uiColorTopLeft: UIColor
//    var uiColorBottomRight: UIColor
//    var uiColorBottomLeft: UIColor
//    var uiColorTopRight: UIColor
    
    init(playerStateVM: PlayerStateVM) {
        self.playerStateVM = playerStateVM
        self.albumWidth = playerStateVM.albumCover.size.width
//        self.uiColorTopLeft = playerStateVM.albumCover.getPixelColor(pos: CGPoint(x: albumWidth * 0.2, y: albumWidth * 0.2))
//        self.uiColorBottomRight = playerStateVM.albumCover.getPixelColor(pos: CGPoint(x: albumWidth * 0.8, y: albumWidth * 0.8))
//        self.uiColorBottomLeft = playerStateVM.albumCover.getPixelColor(pos: CGPoint(x: albumWidth * 0.2,y: albumWidth * 0.8))
//        self.uiColorTopRight = playerStateVM.albumCover.getPixelColor(pos: CGPoint(x: albumWidth * 0.8, y: albumWidth * 0.2))
    }
    
    var body: some View {
        VStack {
            Image(uiImage: self.playerStateVM.albumCover)
                .resizable()
                .frame(width: 180, height: 180)
                .cornerRadius(10)
                .shadow(radius: 10)
//                .shadow(color: Color(uiColorTopLeft).opacity(0.1), radius: 8, x: -10, y: -10)
//                .shadow(color: Color(uiColorTopRight).opacity(0.1), radius: 8, x: 10, y: -10)
//                .shadow(color: Color(uiColorBottomLeft).opacity(0.1), radius: 8, x: -10, y: 10)
//                .shadow(color: Color(uiColorBottomRight).opacity(0.1), radius: 8, x: 10, y: 10)
//                .blendMode(.multiply)
            Text("\(self.playerStateVM.song.name)")
                .font(.system(size: 20, weight: .semibold))
                .multilineTextAlignment(.center)
                .lineLimit(1)
             
            Text("\(self.playerStateVM.song.artists[0])")
                .font(.system(size: 18, weight: .regular))
                .foregroundColor(self.colorScheme == .dark ? Color("fontLightGray") : Color.black)
            
            Text("suggested by \(self.playerStateVM.song.suggested_by)")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(Color("purpleblue"))
                .padding(.top, 1)
            
        }.frame(width: UIScreen.main.bounds.width * 0.8)
    }
}

struct CurrentSongView_Previews: PreviewProvider {
    static var previews: some View {
        CurrentSongView(playerStateVM: PlayerStateVM(userVM: UserVM()))
    }
}
