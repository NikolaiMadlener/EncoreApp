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
    @StateObject var viewModel: ViewModel
    
    var body: some View {
        HStack {
            albumView
            songView
            Spacer()
            addButton
        }
    }
    
    private var albumView: some View {
        URLImage(URL(string: self.viewModel.song.album.images[1].url)!, placeholder: { _ in
            // Replace placeholder image with text
            self.viewModel.currentImage.opacity(0.0)
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
            Text(self.viewModel.song.name)
                .font(.system(size: 18, weight: .semibold))
            Text(self.viewModel.song.artists[0].name)
                .font(.system(size: 16, weight: .regular))
        }
    }
    
    private var addButton: some View {
        Button(action: {
            self.viewModel.suggestSong(songID: self.viewModel.song.id)
            self.viewModel.addingInProcess = true
        }) {
            if self.viewModel.songs.map({ $0.id }).contains(self.viewModel.song.id) || viewModel.currentSong.id == viewModel.song.id {
                Image(systemName: "checkmark.square")
                    .font(.system(size: 35, weight: .light))
                    .foregroundColor(Color("purpleblue"))
            } else if self.viewModel.addingInProcess {
                ZStack {
                    Image(systemName: "square")
                        .font(.system(size: 35, weight: .light))
                        .foregroundColor(Color("purpleblue"))
                    Image(systemName: "ellipsis")
                        .font(.system(size: 20, weight: .light))
                        .foregroundColor(Color("purpleblue"))
                }
            }
            else {
                Image(systemName: "plus.square.fill")
                    .font(.system(size: 35, weight: .light))
                    .foregroundColor(Color("purpleblue"))
            }
        }
    }
}


struct SuggestSongCell_Previews: PreviewProvider {
    static var song = Mockmodel.getSongPayload()
    @State static var songs = [song]
    static var previews: some View {
        SuggestSongCell(viewModel: .init(song: song))
    }
}
