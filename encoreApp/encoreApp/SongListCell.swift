//
//  SongListCell.swift
//  encoreApp
//
//  Created by Nikolai Madlener on 26.05.20.
//  Copyright © 2020 NikolaiEtienne. All rights reserved.
//

import SwiftUI

struct SongListCell: View {
    
    @ObservedObject var song: Song
    @EnvironmentObject private var model: Model
    var rank: Int

    var body: some View {
        HStack {
            rankView
            albumView
            songView
            Spacer()
            voteView
        }
    }
    
    private var rankView: some View {
        Text("\(rank)")
            .font(.system(size: 25, weight: .bold))
            .padding(.horizontal, 10)
    }
    
    private var albumView: some View {
        song.album_image
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 70, height: 70)
    }
    
    private var songView: some View {
        VStack(alignment: .leading) {
            Text(self.song.name).bold()
            Text(self.song.artists[0])
        }
    }
    
    private var voteView: some View {
        ZStack {
            Text("\(self.song.upvoters.count - self.song.downvoters.count)")
                .font(.system(size: 20, weight: .regular))
            VStack {
                upvoteButton
                downvoteButton
            }
        }.padding(.horizontal, 10)
    }
    
    private var upvoteButton: some View {
        Button(action: {
            self.song.upvoters.append("Myself")
        }) {
            Image(systemName: "chevron.up")
                .font(.system(size: 25, weight: .regular))
                .padding(.bottom, 10)
        }
    }
    
    private var downvoteButton: some View {
        Button(action: {
            self.song.downvoters.append("Myself")
        }) {
            Image(systemName: "chevron.down")
                .font(.system(size: 25, weight: .regular))
                .padding(.top, 10)
        }
    }
}

struct SongListCell_Previews: PreviewProvider {
    static var previews: some View {
        SongListCell(song: Mockmodel.getSongs()[0], rank: 2)
    }
}
