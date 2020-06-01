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
    @State var presentMenuSheet = false
    @Binding var currentlyInSession: Bool
    @Binding var sessionID: String
    
    var topSpacer_height: CGFloat = 400
    @State var scroll_offset: CGFloat = 200
    @State var album_offset: CGFloat = 200
    
    var body: some View {
        ZStack {
            /*VStack {
                HStack {
                    Spacer()
                    Button(action: { self.presentMenuSheet = true }) {
                        Image(systemName: "ellipsis").font(Font.system(.title))
                    }.padding()
                        .sheet(isPresented: self.$presentMenuSheet) {
                            MenuView(currentlyInSession: self.$currentlyInSession, sessionID: self.$sessionID)
                    }
                }
                Spacer()
            }*/
            
            //Background Layer
            LinearGradient(gradient: Gradient(colors: [
                Color.blue,
                Color.white,
                Color.white
            ]), startPoint: .top, endPoint: .bottom).edgesIgnoringSafeArea(.all)
            
            //Album Cover Layer
            /*VStack {
                Spacer()
                    .frame(height: 50)
                Image("album1")
                    .resizable()
                    .frame(width: 200, height: 200)
                Text("Title")
                Text("Subtitle")
                Spacer()
                
            }*/
            
            //Song Queue Layer
            ScrollView {
                GeometryReader { geo -> AnyView? in
                    let thisOffset = geo.frame(in: .global).minY
                    if thisOffset > -250 {
                        self.scroll_offset = thisOffset
                    } else {
                        self.scroll_offset = -250
                    }

                    return nil
                }
                VStack {
                    //Spacer for Album Cover Layer
                    HStack {
                        Spacer()
                            .frame(height: topSpacer_height)
                    }
                    VStack {
                        ForEach(model.queue, id: \.self) { song in
                            VStack {
                                SongListCell(song: song, rank: (self.model.queue.firstIndex(of: song) ?? -1) + 1)
                                Divider()
                            }
                        }.animation(.easeInOut(duration: 0.30))
                    }.background(Color.white)
                }.background(Color.clear)//.padding(.top, 50)
            }
            
            //Song Title Layer
            VStack {
                Spacer()
                    .frame(height: scroll_offset + 50)
                
                HStack {
                    if (scroll_offset > -250) {
                        VStack {
                            Image("album1")
                                .resizable()
                                .frame(width: 200, height: 200)
                            Text("Title")
                                .font(.system(size: 25, weight: .bold))
                            Text("Subtitle")
                                .font(.system(size: 20, weight: .semibold))
                        }
                    } else {
                        VStack {
                            Spacer()
                                .frame(height: 200)
                            Text("Title")
                                .font(.system(size: 25, weight: .bold))
                            Text("Subtitle")
                                .font(.system(size: 20, weight: .semibold))
                            Spacer()
                        }
                    }
                }
                
                Spacer()
            }
            
            //Observer Layer
            VStack {
                Text("\(scroll_offset)")
                    .foregroundColor(Color.yellow)
                Spacer()
            }
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    @State static var currentlyInSession = true
    @State static var sessionID = ""
    
    static var previews: some View {
        HomeView(currentlyInSession: $currentlyInSession, sessionID: $sessionID)
    }
}
