//
//  CurrentSongCompactView.swift
//  encoreApp
//
//  Created by Etienne Köhler on 08.07.20.
//  Copyright © 2020 NikolaiEtienne. All rights reserved.
//

import SwiftUI

struct CurrentSongCompactView: View {
    @Environment(\.colorScheme) var colorScheme
    @ObservedObject var playerStateVM: PlayerStateVM
    
    var body: some View {
        ZStack() {
            VStack(spacing: 0) {
                Rectangle()
                    .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height * 0.13)
                    .foregroundColor(Color.clear)
                    .background(self.colorScheme == .dark ? Color(.black) : Color(.white))
                ZStack(alignment: .leading) {
                    ProgressBarView(playerStateVM: playerStateVM, isWide: true)
                }
            }
            HStack() {
                Image(uiImage: self.playerStateVM.albumCover)
                    .resizable()
                    .frame(width: 50, height: 50)
                VStack(alignment: .leading) {
                    Text("\(self.playerStateVM.song.name)")
                        .font(.system(size: 16, weight: .bold))
                    Text("\(self.playerStateVM.song.artists[0])")
                        .font(.system(size: 14, weight: .semibold))
                }
                Spacer()
            }.padding(.horizontal)
                .padding(.top, 20)
        }.edgesIgnoringSafeArea(.top)
    }
}

struct CurrentSongCompactView_Previews: PreviewProvider {
    static var previews: some View {
        CurrentSongCompactView(playerStateVM: PlayerStateVM(userVM: UserVM()))
    }
}
