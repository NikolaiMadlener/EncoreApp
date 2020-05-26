//
//  SwiftUIView.swift
//  encoreApp
//
//  Created by Nikolai Madlener on 26.05.20.
//  Copyright © 2020 NikolaiEtienne. All rights reserved.
//

import SwiftUI

struct SongCell: View {
    var song: Song
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(self.song.name).bold()
                Text(self.song.artists[0])
            }
            Spacer()
            Text("\(self.song.upvoters.count)")
        }.padding(10)
    }
}

struct SongCell_Previews: PreviewProvider {
    static var song = Song(id: "", name: "Alle meine Entchen", artists: ["Etienne"], duration_ms: 123, cover_url: "", album_name: "Kinderlieder", preview_url: "", suggested_by: "", score: 3, time_added: 1, upvoters: [], downvoters: [])
    static var previews: some View {
        SongCell(song: self.song)
    }
}
