//
//  HomeView.swift
//  encoreApp
//
//  Created by Nikolai Madlener on 26.05.20.
//  Copyright © 2020 NikolaiEtienne. All rights reserved.
//

import SwiftUI

struct HomeView: View {
    
    @ObservedObject var model: Model = .shared
    
    var body: some View {
        ScrollView {
            ForEach(model.queue, id: \.self) { song in
                VStack {
                    SongListCell(song: song, rank: (self.model.queue.firstIndex(of: song) ?? -1) + 1)
                    Divider()
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
