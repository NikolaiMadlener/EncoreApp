//
//  SuggestSongCell.swift
//  encoreApp
//
//  Created by Etienne Köhler on 26.06.20.
//  Copyright © 2020 NikolaiEtienne. All rights reserved.
//

import SwiftUI
import URLImage

struct SuggestSongCell: View {
    var song: SpotifySearchPayload.Tracks.Item
    @State var currentImage: Image = Image("albumPlaceholder")
    
    var body: some View {
        HStack {
            albumView
            songView
        }
    }
    
    private var albumView: some View {
        URLImage(URL(string: song.album.images[1].url)!, placeholder: { _ in
                // Replace placeholder image with text
                self.currentImage.opacity(0.0)
        }, content: {
               $0.image
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 55, height: 55)
                .cornerRadius(5)
            }).frame(width: 55, height: 55)
    }
    
    private var songView: some View {
        VStack(alignment: .leading) {
            Text(self.song.name).bold()
            Text(self.song.artists[0].name)
        }
    }
}


struct SuggestSongCell_Previews: PreviewProvider {
    static var song = Mockmodel.getSongPayload()
    static var previews: some View {
        SuggestSongCell(song: song)
    }
}
