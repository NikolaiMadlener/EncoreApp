//
//  HomeView.swift
//  encoreApp
//
//  Created by Nikolai Madlener on 26.05.20.
//  Copyright © 2020 NikolaiEtienne. All rights reserved.
//

import SwiftUI

struct HomeView: View {
    
    //@EnvironmentObject private var model: Model
    private var queue: [Song] = Mockmodel.getSongs()
    
    var body: some View {
        ScrollView {
            VStack {
                ForEach(queue, id: \.self) { song in
                    SongListCell(song: song, rank: (self.queue.firstIndex(of: song) ?? -1) + 1)
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
