//
//  HomeView.swift
//  encoreApp
//
//  Created by Nikolai Madlener on 26.05.20.
//  Copyright © 2020 NikolaiEtienne. All rights reserved.
//

import SwiftUI

struct HomeView: View {
    var songsList: [Song] = Mockmodel.getSongs()
    var body: some View {
        ScrollView {
            VStack {
                ForEach(songsList, id: \.self) { song in
                    SongListCell(song: song)
                }
            }
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
