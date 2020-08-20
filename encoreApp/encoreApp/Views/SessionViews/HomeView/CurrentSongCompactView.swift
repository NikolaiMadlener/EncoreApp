//
//  CurrentSongCompactView.swift
//  encoreApp
//
//  Created by Etienne Köhler on 08.07.20.
//  Copyright © 2020 NikolaiEtienne. All rights reserved.
//

//Obsolete: We are using SongTitleBarView instead
import SwiftUI
import URLImage

struct CurrentSongCompactView: View {
    @Environment(\.colorScheme) var colorScheme
    @ObservedObject var playerStateVM: PlayerStateVM
    @State var currentImage: Image = Image("albumPlaceholder")
    
    var body: some View {
       Group {
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
                .foregroundColor(Color.white)
            }
        }
        
                    
    }
}

struct CurrentSongCompactView_Previews: PreviewProvider {
    static var previews: some View {
        CurrentSongCompactView(playerStateVM: PlayerStateVM(userVM: UserVM()))
    }
}
