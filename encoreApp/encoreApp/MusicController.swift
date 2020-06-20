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
    
    static let shared = MusicController()
    
    private var currentPodcastSpeed: SPTAppRemotePodcastPlaybackSpeed?
    @Published var playerState: SPTAppRemotePlayerState?
    @Published var normalizedPlaybackPosition: CGFloat? = CGFloat()
    var currentAlbumImage: UIImage = UIImage(imageLiteralResourceName: "album6")
    var trackName: String?
    var artistName: String?
    var playbackPosition: Int?
    var test = 1
    private var subscribedToPlayerState: Bool = false
    private var subscribedToCapabilities: Bool = false
    var playURI = ""
    private let trackIdentifier = "spotify:track:32ftxJzxMPgUFCM6Km9WTS"
    var timer = Timer() //for fetching playerState every second
    
    func calculatePlayBarPosition() {
        var numerator = CGFloat(self.playbackPosition ?? 1)
        var denominator = CGFloat(Int(self.playerState?.track.duration ?? 1))
        self.normalizedPlaybackPosition = numerator / denominator
        print(self.normalizedPlaybackPosition)
    }
    
    func updateViewWithPlayerState(_ playerState: SPTAppRemotePlayerState) {
        print("UPDATE:\(playerState)")
        self.playerState = playerState
        fetchAlbumArtForTrack(playerState.track) { (image) -> Void in
            self.currentAlbumImage = image
        }
        trackName = playerState.track.name
        artistName = playerState.track.artist.name
        playbackPosition = playerState.playbackPosition
        calculatePlayBarPosition()
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
        appRemote?.playerAPI?.getPlayerState { (result, error) -> Void in
            guard error == nil else { return }
            
            let playerState = result as! SPTAppRemotePlayerState
            self.updateViewWithPlayerState(playerState)
        }
        
        print("GETSTATE:\(playerState)")
    }
    
    func playMusic() {
        if appRemote?.isConnected == false {
            if appRemote?.authorizeAndPlayURI(self.playURI) == false { //returns false when spotify not installed, if true, attempts to obtain access token and starts playback
                // The Spotify app is not installed, present the user with an App Store page
                showAppStoreInstall()
                self.getPlayerState()
                
            }
        } else if playerState == nil || playerState!.isPaused {
            startPlayback()
            print("PLAYERSTATE:\(playerState)")
        } else {
            pausePlayback()
        }
    }
    
    func startPlayback() {
        print("START")
        self.appRemote?.playerAPI?.resume(self.defaultCallback)
    }
    
    func pausePlayback() {
        print("PAUSE")
        self.appRemote?.playerAPI?.pause(self.defaultCallback)
    }
    
    func enqueueTrack() {
        appRemote?.playerAPI?.enqueueTrackUri(trackIdentifier, callback: defaultCallback)
    }
    
    func skipNext() {
        appRemote?.playerAPI?.skip(toNext: defaultCallback)
    }
    
    func fetchAlbumArtForTrack(_ track: SPTAppRemoteTrack, callback: @escaping (UIImage) -> Void ) {
        appRemote?.imageAPI?.fetchImage(forItem: track, with:CGSize(width: 1000, height: 1000), callback: { (image, error) -> Void in
            guard error == nil else { return }
            
            let image = image as! UIImage
            callback(image)
        })
    }
    
    private func subscribeToPlayerState() {
        guard (!subscribedToPlayerState) else { return }
        appRemote?.playerAPI!.delegate = self
        appRemote?.playerAPI?.subscribe { (_, error) -> Void in
            guard error == nil else { return }
            self.subscribedToPlayerState = true
        }
        print("SUBSCRIBE: \(subscribedToPlayerState)")
    }
    
    // MARK: - AppRemote
    func appRemoteConnecting() {
        
    }
    
    func appRemoteConnected() {
        subscribeToPlayerState()
        //subscribeToCapabilityChanges()
        getPlayerState()
        
        //enableInterface(true)
    }
    
    func appRemoteDisconnect() {
        
        self.subscribedToPlayerState = false
        self.subscribedToCapabilities = false
        //enableInterface(false)
    }
}

// MARK: SKStoreProductViewControllerDelegate
extension MusicController {
    private func showAppStoreInstall() {
        
    }
}

// MARK: - SPTAppRemotePlayerStateDelegate
extension MusicController: SPTAppRemotePlayerStateDelegate {
    func playerStateDidChange(_ playerState: SPTAppRemotePlayerState) {
        print("DELEGATE:\(playerState)")
        updateViewWithPlayerState(playerState)
    }
}

// for fetching playerState every second.
extension MusicController {
    func viewDidLoad() {               // Use for the app's interface
        scheduledTimerWithTimeInterval()
    }
    
    func scheduledTimerWithTimeInterval(){
        // Scheduling timer to Call the function "updateCounting" with the interval of 1 seconds
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.updatePlayerState), userInfo: nil, repeats: true)
    }
    
    @objc func updatePlayerState(){
        getPlayerState()
    }
}

