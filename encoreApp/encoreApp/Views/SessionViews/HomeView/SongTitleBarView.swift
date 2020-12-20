//
//  SongTitleBarView.swift
//  encoreApp
//
//  Created by Nikolai Madlener on 07.07.20.
//  Copyright © 2020 NikolaiEtienne. All rights reserved.
//

import SwiftUI

struct SongTitleBarView: View {
    @ObservedObject var playerStateVM: PlayerStateVM
    
    var body: some View {
        ZStack {
            Rectangle()
                .frame(height: 50)
                .cornerRadius(10)
                .foregroundColor(Color("mediumdarkgray"))
                .shadow(radius: 10)
            VStack {
                HStack {
                    Image(uiImage: self.playerStateVM.albumCover)
                        .resizable()
                        .frame(width: 35, height: 35)
                        .cornerRadius(5)
                    VStack(alignment: .leading) {
                        Text("\(self.playerStateVM.song.name)")
                            .font(.system(size: 15, weight: .bold))
                            .frame(maxWidth: 250, maxHeight: 15, alignment: .leading)
                            .foregroundColor(Color.white)
                        Text("\(self.playerStateVM.song.artists[0])")
                            .font(.system(size: 10, weight: .semibold))
                            .frame(maxWidth: 200, maxHeight: 15, alignment: .leading)
                            .foregroundColor(Color("fontLightGray"))
                    }
                    Spacer()
                }
            }.padding(.horizontal, 10)
        }.padding(.top, 3)
        .padding(.horizontal, 5)
    }
}

struct SongTitleBarView_Previews: PreviewProvider {
    @ObservedObject static var playerStateVM = PlayerStateVM(userVM: UserVM())
    static var previews: some View {
        self.playerStateVM.song.name = "abc"
        self.playerStateVM.song.artists = ["defdefdefdefdefdefdefdefdefdefdefdefdef"]
        return
            SongTitleBarView(playerStateVM: playerStateVM).previewLayout(.sizeThatFits)
    }
}
