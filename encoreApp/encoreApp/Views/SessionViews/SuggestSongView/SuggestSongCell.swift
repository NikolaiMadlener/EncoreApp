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
    @ObservedObject var searchResultListVM: SearchResultListVM
    @ObservedObject var songListVM: SongListVM
    @ObservedObject var playerStateVM: PlayerStateVM
    @State var currentImage: Image = Image("albumPlaceholder")
    @State var addingInProcess = false
    var song: SpotifySearchPayload.Tracks.Item
    
    var body: some View {
        HStack {
            albumView
            songView
            Spacer()
            addButton
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
            Text(self.song.name)
                .font(.system(size: 18, weight: .bold))
            Text(self.song.artists[0].name)
                .font(.system(size: 16, weight: .regular))
        }
    }
    
    private var addButton: some View {
        Button(action: {
            self.searchResultListVM.suggestSong(songID: self.song.id)
            self.addingInProcess = true
        }) {
            if songListVM.songs.map({ $0.id }).contains(song.id) || playerStateVM.song.id == song.id {
                Image(systemName: "checkmark.square")
                    .font(.system(size: 35, weight: .light))
                    .foregroundColor(Color("purpleblue"))
            } else if self.addingInProcess {
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
    static var searchResultListVM = SearchResultListVM(userVM: UserVM())
    static var song = Mockmodel.getSongPayload()
    static var previews: some View {
        SuggestSongCell(searchResultListVM: searchResultListVM, songListVM: SongListVM(userVM: UserVM()), playerStateVM: PlayerStateVM(userVM: UserVM()), song: song)
    }
}
