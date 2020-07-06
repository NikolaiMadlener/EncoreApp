//
//  ProgressBarView.swift
//  encoreApp
//
//  Created by Etienne Köhler on 01.07.20.
//  Copyright © 2020 NikolaiEtienne. All rights reserved.
//

import SwiftUI

struct ProgressBarView: View {
    @Environment(\.colorScheme) var colorScheme
    @ObservedObject var playerStateVM: PlayerStateVM
    var updateFrequency_ms: CGFloat = 50
    @State var songTimestamp_ms: CGFloat = 0
    let timer2 = Timer.publish(every: 0.05, on: .main, in: .common).autoconnect()
    
    var body: some View {
        ZStack(alignment: .leading) {
            Rectangle()
                .foregroundColor(self.colorScheme == .dark ? Color("darkgray") : Color.gray)
                .frame(width: UIScreen.main.bounds.width * 0.8, height: 4.0)
                .cornerRadius(5)
            Rectangle()
                .foregroundColor(Color("purpleblue"))
                .frame(width: UIScreen.main.bounds.width * 0.8 * (songTimestamp_ms / CGFloat(playerStateVM.song.duration_ms)), height: 4.0)
                .animation(.easeOut(duration: 0.6))
                .cornerRadius(5)
                .onReceive(timer2) { _ in
                    if self.playerStateVM.song.name != "" {
                        self.songTimestamp_ms += 50
                        print("UPDATEPB:\(self.songTimestamp_ms), From:\(self.playerStateVM.song.duration_ms)")
                        print("Length:\(UIScreen.main.bounds.width * 0.73 * CGFloat((self.songTimestamp_ms / CGFloat(self.playerStateVM.song.duration_ms))))")
                    }
                }
        }
        .onAppear(perform: {
            print("VALUE:\(self.playerStateVM.song.duration_ms), Name: \(self.playerStateVM.song.name )")
            self.songTimestamp_ms = 0
        })
    }
    
    func updateProgress(frequency_ms: CGFloat) {
        songTimestamp_ms += frequency_ms
        print("Durationms:\(self.playerStateVM.song.duration_ms), Name: \(self.playerStateVM.song.name )")
    }
}

struct ProgressBarView_Previews: PreviewProvider {
    static var duration_ms: Int = 50000
    static var previews: some View {
        ProgressBarView(playerStateVM: PlayerStateVM(userVM: UserVM()))
    }
}
