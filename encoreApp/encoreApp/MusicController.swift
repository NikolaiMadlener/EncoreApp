//
//  MusicContoller.swift
//  encoreApp
//
//  Created by Etienne Köhler on 09.06.20.
//  Copyright © 2020 NikolaiEtienne. All rights reserved.
//

import Foundation
import SwiftUI
import UIKit

class MusicController: NSObject, ObservableObject {
    //
    //    let remoteCommandCenter = MPRemoteCommandCenter.shared()
    
    static let shared = MusicController()

    private var currentPodcastSpeed: SPTAppRemotePodcastPlaybackSpeed?
    var playerStateLocal: SPTAppRemotePlayerState?
    var normalizedPlaybackPosition: CGFloat? = CGFloat()
    var currentAlbumImage: UIImage = UIImage(imageLiteralResourceName: "album6")
    var trackName: String?
    var artistName: String?
    var playbackPosition: Int = 0
    var test = 1
    private var subscribedToPlayerState: Bool = false
    private var subscribedToCapabilities: Bool = false
    var playURI = ""
    private let trackIdentifier = "spotify:track:32ftxJzxMPgUFCM6Km9WTS"
    var timer = Timer() //for fetching playerState every second
    var userVM: UserVM?
    @Published var isPaused = true
    @Published var buttonReady = true
    @Published var showNetworkAlert = false
    
    @Published var showAppStoreOverlay = false
    @Published var showNoSpotifyAppAlert = false
    
    //    func calculatePlayBarPosition() {
    //        var numerator = CGFloat(self.playbackPosition ?? 1)
    //        var denominator = CGFloat(Int(self.playerState?.track.duration ?? 1))
    //        self.normalizedPlaybackPosition = numerator / denominator
    //        print(self.normalizedPlaybackPosition)
    //    }
    
    func updateViewWithPlayerState(_ playerState: SPTAppRemotePlayerState) {
        
        print("updateViewWithPlayerState()")
        //print("UPDATE:\(playerState)")
        //self.playerState = playerState
        //        fetchAlbumArtForTrack(playerState.track) { (image) -> Void in
        //            self.currentAlbumImage = image
        //        }
        
        //        trackName = playerState.track.name
        //        artistName = playerState.track.artist.name
        //        playbackPosition = playerState.playbackPosition
        //calculatePlayBarPosition()
        
        if self.isPaused != playerState.isPaused {
            self.isPaused = playerState.isPaused
            //self.playbackPosition = playerState.playbackPosition
            playerState.isPaused ? self.playerPause() : self.playerPlay()
        }
    }
    
    var appRemote: SPTAppRemote? {
        get {
            return (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.appRemote
        }
    }
    
    var defaultCallback: SPTAppRemoteCallback {
        get {
            return { [weak self] _, error in
                if let error = error {
                    //display error
                }
                self?.getPlayerState()
            }
        }
    }
    
    private func getPlayerState() {
        print("getPlayerState()")
        appRemote?.playerAPI?.getPlayerState { (result, error) -> Void in
            guard error == nil else { return }
            let playerState = result as! SPTAppRemotePlayerState
            self.updateViewWithPlayerState(playerState)
        }
    }
    
    func doConnect() {
        print("doConnect()")
        if appRemote?.isConnected == false {
            if appRemote?.authorizeAndPlayURI(self.playURI) == false { //returns false when spotify not installed, if true, attempts to obtain access token and starts playback
                // The Spotify app is not installed, present the user with an App Store page
                print("showAppStoreInstall")
                showAppStoreInstall()
            }
            self.pausePlayback()
        }
    }
    
    func startPlayback() {
        print("startPlayback()")
        if appRemote?.isConnected == false {
            if appRemote?.authorizeAndPlayURI(self.playURI) == false { //returns false when spotify not installed, if true, attempts to obtain access token and starts playback
                // The Spotify app is not installed, present the user with an App Store page
                showAppStoreInstall()
            }
        } else {
            buttonReady = false
            playerPlay()
        }
    }
    
    func pausePlayback() {
        print("pausePlayback()")
        if appRemote?.isConnected == false {
            if appRemote?.authorizeAndPlayURI(self.playURI) == false { //returns false when spotify not installed, if true, attempts to obtain access token and starts playback
                // The Spotify app is not installed, present the user with an App Store page
                showAppStoreInstall()
            }
        } else {
            buttonReady = false
            playerPause()
        }
    }
    
    // NOT NEEDED
    func enqueueTrack() {
        print("enqueueTrack()")
        //        appRemote?.playerAPI?.enqueueTrackUri(trackIdentifier, callback: defaultCallback)
    }
    
    // NOT NEEDED
    func skipNext() {
        print("enqueue()")
        //appRemote?.playerAPI?.skip(toNext: defaultCallback)
    }
    
    // NOT NEEDED
    func fetchAlbumArtForTrack(_ track: SPTAppRemoteTrack, callback: @escaping (UIImage) -> Void ) {
        print("fetchAlbumArtForTrack()")
        appRemote?.imageAPI?.fetchImage(forItem: track, with:CGSize(width: 1000, height: 1000), callback: { (image, error) -> Void in
            guard error == nil else { return }
            
            let image = image as! UIImage
            callback(image)
        })
    }
    
    private func subscribeToPlayerState() {
        print("subscribeToPlayerState()")
        DispatchQueue.main.async {
            guard (!self.subscribedToPlayerState) else { return }
            self.appRemote?.playerAPI!.delegate = self
            self.appRemote?.playerAPI?.subscribe { (_, error) -> Void in
            guard error == nil else { return }
            self.subscribedToPlayerState = true
        }
            print("SUBSCRIBE: \(self.subscribedToPlayerState)")
        }
    }
    
    // MARK: - AppRemote
    
    // NOT NEEDED
    func appRemoteConnecting() {
        
    }
    
    func appRemoteConnected() {
        print("appRemoteConnected()")
        subscribeToPlayerState()
    }
    
    func appRemoteDisconnect() {
//        print("appRemoteDisconnect()")
//        guard (self.subscribedToPlayerState) else { return }
//        self.appRemote?.playerAPI!.delegate = nil
//        self.appRemote?.playerAPI?.unsubscribe { (_, error) -> Void in
//            guard error == nil else { return }
//            self.subscribedToPlayerState = false
//        }
        self.subscribedToPlayerState = false
        self.subscribedToCapabilities = false
    }
    
    func getAccessToken() -> String {
        print("getAccessToken()")
        return appRemote?.connectionParameters.accessToken ?? "No Acces Token"
    }
    
    func playerPlay() {
        
        print("playerPlay() - BACKEND")
        print("userName: \(self.userVM?.username ?? "")")
        guard let url = URL(string: "https://api.encore-fm.com/users/"+"\(self.userVM?.username ?? "")"+"/player/play") else {
            print("Invalid URL")
            return
            
        }
        var request = URLRequest(url: url)
        
        request.httpMethod = "POST"
        request.addValue(self.userVM?.secret ?? "", forHTTPHeaderField: "Authorization")
        request.addValue(self.userVM?.sessionID ?? "", forHTTPHeaderField: "Session")
        
        // HTTP Request Parameters which will be sent in HTTP Request Body
        //let postString = "userId=300&title=My urgent task&completed=false";
        // Set HTTP Request Body
        //request.httpBody = postString.data(using: String.Encoding.utf8);
        // Perform HTTP Request
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            
            DispatchQueue.main.async {
                self.buttonReady = true
            }
            
            // Check for Error
            if let error = error {
                print("Error took place \(error)")
                DispatchQueue.main.async {
//                    self.appRemote?.playerAPI?.resume(self.defaultCallback)
                    self.showNetworkAlert = true
                }
                return
            }
            
            
            // Convert HTTP Response Data to a String
            if let data = data, let dataString = String(data: data, encoding: .utf8) {
                //print("Response data string:\n \(dataString)")
                print("BACKEND player play")
            }
        }
        task.resume()
        
    }
    
    func playerPause() {
        
        print("playerPause() - BACKEND")
        guard let url = URL(string: "https://api.encore-fm.com/users/"+"\(self.userVM?.username ?? "")"+"/player/pause") else {
            print("Invalid URL")
            return
            
        }
        var request = URLRequest(url: url)
        
        request.httpMethod = "POST"
        request.addValue(self.userVM?.secret ?? "", forHTTPHeaderField: "Authorization")
        request.addValue(self.userVM?.sessionID ?? "", forHTTPHeaderField: "Session")
        
        
        
        // HTTP Request Parameters which will be sent in HTTP Request Body
        //let postString = "userId=300&title=My urgent task&completed=false";
        // Set HTTP Request Body
        //request.httpBody = postString.data(using: String.Encoding.utf8);
        // Perform HTTP Request
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            
            DispatchQueue.main.async {
                self.buttonReady = true
            }
            
            // Check for Error
            if let error = error {
                print("Error took place \(error)")
                DispatchQueue.main.async {
                    self.appRemote?.playerAPI?.pause(self.defaultCallback)
                    self.showNetworkAlert = true
                }
                return
            }
            
            
            // Convert HTTP Response Data to a String
            if let data = data, let dataString = String(data: data, encoding: .utf8) {
                //print("Response data string:\n \(dataString)")
                print("BACKEND player pause")
                DispatchQueue.main.async {
                    guard (self.subscribedToPlayerState) else { return }
                    self.appRemote?.playerAPI!.delegate = nil
                    self.appRemote?.playerAPI?.unsubscribe { (_, error) -> Void in
                        guard error == nil else { return }
                        self.subscribedToPlayerState = false
                        self.subscribeToPlayerState()
                    }
                   
                }
            }
        }
        task.resume()
    }
    
    func playerSkipNext() {
        guard let url = URL(string: "https://api.encore-fm.com/users/"+"\(self.userVM?.username ?? "")"+"/player/skip") else {
            print("Invalid URL")
            return
            
        }
        var request = URLRequest(url: url)
        
        request.httpMethod = "POST"
        request.addValue(self.userVM?.secret ?? "", forHTTPHeaderField: "Authorization")
        request.addValue(self.userVM?.sessionID ?? "", forHTTPHeaderField: "Session")
        
        // HTTP Request Parameters which will be sent in HTTP Request Body
        //let postString = "userId=300&title=My urgent task&completed=false";
        // Set HTTP Request Body
        //request.httpBody = postString.data(using: String.Encoding.utf8);
        // Perform HTTP Request
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            
            // Check for Error
            if let error = error {
                print("Error took place \(error)")
                DispatchQueue.main.async {
                    self.showNetworkAlert = true
                }
                return
            }
            
            
            // Convert HTTP Response Data to a String
            if let data = data, let dataString = String(data: data, encoding: .utf8) {
                print("Response data string:\n \(dataString)")
            }
        }
        task.resume()
    }
}

// MARK: SKStoreProductViewControllerDelegate
extension MusicController {
    private func showAppStoreInstall() {
        self.showAppStoreOverlay = true
        self.showNoSpotifyAppAlert = true
    }
}

// MARK: - SPTAppRemotePlayerStateDelegate
extension MusicController: SPTAppRemotePlayerStateDelegate {
    func playerStateDidChange(_ playerState: SPTAppRemotePlayerState) {
        print("playerStateDidChange()")
        print("DELEGATE:\(playerState)")
        updateViewWithPlayerState(playerState)
        
    }
}

 //for fetching playerState every second.
//extension MusicController {
//    func viewDidLoad() {               // Use for the app's interface
//        print("viewDidLoad()")
//    scheduledTimerWithTimeInterval()
//    }
//
//    func scheduledTimerWithTimeInterval(){
//        // Scheduling timer to Call the function "updateCounting" with the interval of 1 seconds
//        print("scheduledTimerWithTimeInterval()")
//        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.updatePlayerState), userInfo: nil, repeats: true)
//    }
////
//    @objc func updatePlayerState(){
//        print("updatePlayerState()")
//        getPlayerState()
//    }
//}


