//
//  AddSongsBarView.swift
//  encoreApp
//
//  Created by Etienne Köhler on 30.06.20.
//  Copyright © 2020 NikolaiEtienne. All rights reserved.
//

import SwiftUI

struct AddSongsBarView: View {
    @Environment(\.colorScheme) var colorScheme
    @StateObject var viewModel: ViewModel
    
    @ViewBuilder
    var body: some View {
       if self.viewModel.isUserAdmin {
           HStack {
                playPauseButton.frame(width: 50)
                Spacer().frame(width: 30)
                addButton
                Spacer().frame(width: 30)
                skipButton.frame(width: 50)
            }.padding(10)
            .frame(width: 280)
            .background(self.colorScheme == .dark ? Color("darkgray") : Color(.white))
            .cornerRadius(25)
            .shadow(radius: 10)
        } else {
            addButton
        }
    }
    
    var addButton: some View {
        Button(action: { self.viewModel.showAddSongSheet.wrappedValue = true }) {
            ZStack {
                Circle().frame(width: 55, height: 55).foregroundColor(Color.white)
                Image(systemName: "plus.circle.fill")
                    .font(.system(size: 60, weight: .light))
                    .foregroundColor(Color("purpleblue"))
            }
        }.sheet(isPresented: self.viewModel.showAddSongSheet) {
            SuggestSongView(viewModel: .init())
        }
    }
    
    var playPauseButton: some View {
        Button(action: {
            viewModel.playPause()
        }) {
            ZStack {
                Image(systemName: self.viewModel.isPlaying ? "pause" : "play.fill")
                    .font(.system(size: 30, weight: .semibold))
                    .foregroundColor(self.colorScheme == .dark ? Color.white : Color.black)
            }
        }
    }
    
    var skipButton: some View {
        Button(action: { self.viewModel.skipNext() }) {
            Image(systemName: "forward.end")
                .font(.system(size: 30, weight: .semibold))
                .foregroundColor(self.colorScheme == .dark ? Color.white : Color.black)
        }
    }
    
    
}

struct AddSongsBarView_Previews: PreviewProvider {
    @State static var isPlay = false
    @State static var showAddSongSheet = false
    
    static var previews: some View {
        AddSongsBarView(viewModel: .init(showAddSongSheet: $showAddSongSheet))
    }
}
