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
    @Published private var playerState: SPTAppRemotePlayerState?
    private var subscribedToPlayerState: Bool = false
    private var subscribedToCapabilities: Bool = false
    private let playURI = "spotify:album:1htHMnxonxmyHdKE2uDFMR"
    private let trackIdentifier = "spotify:track:32ftxJzxMPgUFCM6Km9WTS"
    
    var appRemote: SPTAppRemote? {
        get {
            return (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.appRemote
        }
    }
    
    var defaultCallback: SPTAppRemoteCallback {
        get {
            return {[weak self] _, error in
                if let error = error {
                    //display error
                }
            }
        }
    }
    
    func playMusic() {
        if appRemote?.isConnected == false {
            if appRemote?.authorizeAndPlayURI(playURI) == false { //returns false when spotify not installed, if true, attempts to obtain access token and starts playback
                // The Spotify app is not installed, present the user with an App Store page
                showAppStoreInstall()
            }
        } else if playerState == nil || playerState!.isPaused {
            print("IAMHERE")
            startPlayback()
        } else {
            pausePlayback()
        }
    }
    
    func startPlayback() {
        appRemote?.playerAPI?.resume(defaultCallback)
    }
    
    func pausePlayback() {
        appRemote?.playerAPI?.pause(defaultCallback)
    }
    
    func enqueueTrack() {
        print("IAMHERE2")
        appRemote?.playerAPI?.enqueueTrackUri(trackIdentifier, callback: defaultCallback)
    }
    
    func skipNext() {
        appRemote?.playerAPI?.skip(toNext: defaultCallback)
    }
    /*
    
    private func subscribeToPlayerState() {
        guard (!subscribedToPlayerState) else { return }
        //appRemote?.playerAPI!.delegate = self
        appRemote?.playerAPI?.subscribe { (_, error) -> Void in
            guard error == nil else { return }
            self.subscribedToPlayerState = true
        }
    }
    
    private func getPlayerState() {
        appRemote?.playerAPI?.getPlayerState { (result, error) -> Void in
            guard error == nil else { return }

            let playerState = result as! SPTAppRemotePlayerState
        }
    }
    
}

// MARK: - SPTAppRemoteUserAPIDelegate
extension MusicController: SPTAppRemoteUserAPIDelegate {
    func userAPI(_ userAPI: SPTAppRemoteUserAPI, didReceive capabilities: SPTAppRemoteUserCapabilities) {
        updateViewWithCapabilities(capabilities)
    }*/
}

// MARK: SKStoreProductViewControllerDelegate
extension MusicController {
    private func showAppStoreInstall() {
        
    }
}

// MARK: - SPTAppRemotePlayerStateDelegate
extension MusicController: SPTAppRemotePlayerStateDelegate {
       func playerStateDidChange(_ playerState: SPTAppRemotePlayerState) {
           self.playerState = playerState
       }
}

