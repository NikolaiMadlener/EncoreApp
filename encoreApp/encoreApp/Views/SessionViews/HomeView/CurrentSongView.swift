//
//  CurrentSongView.swift
//  encoreApp
//
//  Created by Etienne Köhler on 30.06.20.
//  Copyright © 2020 NikolaiEtienne. All rights reserved.
//

import SwiftUI

struct CurrentSongView: View {
    @ObservedObject var playerStateVM: PlayerStateVM
    var albumWidth: CGFloat
    
    init(playerStateVM: PlayerStateVM) {
        self.playerStateVM = playerStateVM
        self.albumWidth = playerStateVM.albumCover.size.width
    }
    
    var body: some View {
        VStack {
            Image(uiImage: self.playerStateVM.albumCover)
                .resizable()
                .frame(width: 180, height: 180)
                .cornerRadius(10)
                .shadow(radius: 10)
            Text("\(self.playerStateVM.song.name)")
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(Color.white)
                .multilineTextAlignment(.center)
                .lineLimit(1)
             
            Text("\(self.playerStateVM.song.artists[0])")
                .font(.system(size: 18, weight: .regular))
                .foregroundColor(Color("fontLightGray"))
            
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
