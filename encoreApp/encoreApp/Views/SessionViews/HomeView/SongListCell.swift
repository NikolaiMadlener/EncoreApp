//
//  SongListCell.swift
//  encoreApp
//
//  Created by Nikolai Madlener on 26.05.20.
//  Copyright © 2020 NikolaiEtienne. All rights reserved.
//

import SwiftUI
import URLImage

struct SongListCell: View {
    @StateObject var viewModel: ViewModel
    
    var body: some View {
        HStack {
            //rankView.frame(width: 55)
            albumView
            songView
            Spacer()
            voteView
        }.onAppear {
            if self.viewModel.song.upvoters.contains(self.viewModel.username) {
                self.viewModel.voteState = .UPVOTE
            } else if self.viewModel.song.downvoters.contains(self.viewModel.username) {
                self.viewModel.voteState = .DOWNVOTE
            } else {
                self.viewModel.voteState = .NEUTRAL
            }
        }
    }
    
    private var rankView: some View {
        Text("\(viewModel.rank)")
            .font(.system(size: 25, weight: .bold))
            .padding(.horizontal, 10)
    }
    
    private var albumView: some View {
        URLImage(URL(string: self.viewModel.song.cover_url)!, placeholder: { _ in
            self.viewModel.currentImage.opacity(0.0)
        }, content: {
               $0.image
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 55, height: 55)
                .cornerRadius(5)
            }).frame(width: 55, height: 55)
            .padding(.horizontal, 10)
    }
    
    private var songView: some View {
        VStack(alignment: .leading) {
            Text(self.viewModel.song.name)
                .font(.system(size: 18, weight: .semibold))
            Text(self.viewModel.song.artists[0])
                .font(.system(size: 16, weight: .regular))
        }
    }
    
    private var voteView: some View {
        HStack {
            Text("\(self.viewModel.song.upvoters.count - self.viewModel.song.downvoters.count)")
                .font(.system(size: 23, weight: .semibold))
                .padding(.leading, 10)
                .padding(.trailing, 5)
            VStack(spacing: 0) {
                upvoteButton
                downvoteButton
            }.padding(.trailing, 10)
        }
    }
    
    private var upvoteButton: some View {
        Button(action: {
            switch self.viewModel.voteState {
            case .NEUTRAL:
                self.viewModel.upvote()
                self.viewModel.voteState = VoteState.UPVOTE
            case .UPVOTE: break
            case .DOWNVOTE:
                self.viewModel.upvote()
            }
        }) {
            Image(systemName: viewModel.voteState == VoteState.UPVOTE ? "triangle.fill" : "triangle")
                .font(.system(size: 22, weight: .regular))
                .foregroundColor(viewModel.voteState == VoteState.UPVOTE ? viewModel.voteState.color : Color.gray)
                .padding(.bottom, 3)
        }
    }
    
    private var downvoteButton: some View {
        Button(action: {
            switch self.viewModel.voteState {
            case .NEUTRAL:
                self.viewModel.downvote()
                self.viewModel.voteState = VoteState.DOWNVOTE
            case .UPVOTE:
                self.viewModel.downvote()
            case .DOWNVOTE: break
            }
        }) {
            Image(systemName: viewModel.voteState == VoteState.DOWNVOTE ? "triangle.fill" : "triangle")
                .font(.system(size: 23, weight: .regular))
                .foregroundColor(viewModel.voteState == VoteState.DOWNVOTE ? viewModel.voteState.color : Color.gray)
                .rotationEffect(.degrees(-180))
                .padding(.top, 3)
        }
    }
}

struct SongListCell_Previews: PreviewProvider {
    static var previews: some View {
        SongListCell(viewModel: .init(song: Mockmodel.getSongs()[0], rank: 2))
    }
}

