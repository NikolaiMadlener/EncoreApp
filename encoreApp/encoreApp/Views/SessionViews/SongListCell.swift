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
    @ObservedObject var userVM: UserVM
    @State var voteState: VoteState = VoteState.NEUTRAL
    @State var currentImage: Image = Image("albumPlaceholder")
    var song: Song
    var rank: Int
    
    var body: some View {
        HStack {
            rankView.frame(width: 50)
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
        URLImage(URL(string: self.song.cover_url)!, placeholder: { _ in
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
        }.padding(.horizontal)
    }
    
    private var upvoteButton: some View {
        Button(action: {
            switch self.voteState {
            case .NEUTRAL:
                self.upvote()
                //self.model.upvote(song: self.song, username: "Myself")
                self.voteState = VoteState.UPVOTE
            case .UPVOTE: break
            case .DOWNVOTE:
                self.upvote()
                //self.model.upvote(song: self.song, username: "Myself")
                self.voteState = VoteState.NEUTRAL
            }
        }) {
            Image(systemName: "chevron.up")
                .font(.system(size: 30, weight: .semibold))
                .foregroundColor(voteState != VoteState.DOWNVOTE ? voteState.color : Color.gray)
                .padding(.bottom, 5)
        }
    }
    
    private var downvoteButton: some View {
        Button(action: {
            switch self.voteState {
            case .NEUTRAL:
                self.downvote()
                //self.model.downvote(song: self.song, username: "Myself")
                self.voteState = VoteState.DOWNVOTE
            case .UPVOTE:
                self.downvote()
                //self.model.downvote(song: self.song, username: "Myself")
                self.voteState = VoteState.NEUTRAL
            case .DOWNVOTE: break
            }
        }) {
            Image(systemName: "chevron.down")
                .font(.system(size: 30, weight: .semibold))
                .foregroundColor(voteState != VoteState.UPVOTE ? voteState.color : Color.gray)
                .padding(.top, 5)
        }
    }
    
    func upvote() {
        guard let url = URL(string: "https://api.encore-fm.com/users/"+"\(userVM.username)"+"/vote/"+"\(self.song.id)"+"/up") else {
            print("Invalid URL")
            return
            
        }
        var request = URLRequest(url: url)
        
        request.httpMethod = "POST"
        request.addValue(userVM.secret, forHTTPHeaderField: "Authorization")
        request.addValue(userVM.sessionID, forHTTPHeaderField: "Session")
        
        // HTTP Request Parameters which will be sent in HTTP Request Body
        //let postString = "userId=300&title=My urgent task&completed=false";
        // Set HTTP Request Body
        //request.httpBody = postString.data(using: String.Encoding.utf8);
        // Perform HTTP Request
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            
            // Check for Error
            if let error = error {
                print("Error took place \(error)")
                return
            }
            
            
            // Convert HTTP Response Data to a String
            if let data = data, let dataString = String(data: data, encoding: .utf8) {
                print("Response data string:\n \(dataString)")
                
                do {
                    let decodedData = try JSONDecoder().decode([Song].self, from: data)
                    DispatchQueue.main.async {

                    }
                } catch {
                    print("Error")
                    //self.showSessionExpiredAlert = true
                    //self.currentlyInSession = false
                }
            }
        }
        task.resume()
    }
    
    func downvote() {
        guard let url = URL(string: "https://api.encore-fm.com/users/"+"\(userVM.username)"+"/vote/"+"\(self.song.id)"+"/down") else {
            print("Invalid URL")
            return
        }
        var request = URLRequest(url: url)
        
        request.httpMethod = "POST"
        request.addValue(userVM.secret, forHTTPHeaderField: "Authorization")
        request.addValue(userVM.sessionID, forHTTPHeaderField: "Session")
        
        // HTTP Request Parameters which will be sent in HTTP Request Body
        //let postString = "userId=300&title=My urgent task&completed=false";
        // Set HTTP Request Body
        //request.httpBody = postString.data(using: String.Encoding.utf8);
        // Perform HTTP Request
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            
            // Check for Error
            if let error = error {
                print("Error took place \(error)")
                return
            }
            
            
            // Convert HTTP Response Data to a String
            if let data = data, let dataString = String(data: data, encoding: .utf8) {
                print("Response data string:\n \(dataString)")
                
                do {
                    let decodedData = try JSONDecoder().decode([[Song]].self, from: data)
                    DispatchQueue.main.async {

                    }
                } catch {
                    print("Error")
                    //self.showSessionExpiredAlert = true
                    //self.currentlyInSession = false
                }
            }
        }
        task.resume()
        
    }
}

struct SongListCell_Previews: PreviewProvider {
    static var previews: some View {
        SongListCell(userVM: UserVM(), song: Mockmodel.getSongs()[0], rank: 2)
    }
}

