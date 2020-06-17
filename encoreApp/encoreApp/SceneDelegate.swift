//
//  SceneDelegate.swift
//  encoreApp
//
//  Created by Nikolai Madlener on 26.05.20.
//  Copyright © 2020 NikolaiEtienne. All rights reserved.
//

import UIKit
import SwiftUI

class SceneDelegate: UIResponder, UIWindowSceneDelegate, SPTAppRemoteDelegate, SPTAppRemotePlayerStateDelegate {
    
    var window: UIWindow?
    //var model = Model()
    var accessToken = "accessToken"
    var musicController = MusicController()
    
    var playURI = ""
    
    let SpotifyClientID = "a8be659c46584d1c818dadd8023a4f36"
    let SpotifyRedirectURL = URL(string: "encoreapp://spotify/callback")!
    
    lazy var configuration = SPTConfiguration(
        clientID: SpotifyClientID,
        redirectURL: SpotifyRedirectURL
    )
    
    lazy var appRemote: SPTAppRemote = {
        let appRemote = SPTAppRemote(configuration: self.configuration, logLevel: .debug)
        appRemote.connectionParameters.accessToken = self.accessToken
        appRemote.delegate = self
        return appRemote
    }()
    
    // MARK: App IS NOT running and App is called from either Join Link or normally from App Icon
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        var joinedViaURL = false
        var sessionID = ""
        if let url = connectionOptions.urlContexts.first?.url {
            // Handle URL
            let urlString = url.absoluteString
            sessionID = url.absoluteString.substring(from: urlString.index(urlString.startIndex, offsetBy: 12))
            if sessionID != "" {
                joinedViaURL = true
            }
        }
        
        // Create the SwiftUI view that provides the window contents.
        let contentView = AppContentView(joinedViaURL: joinedViaURL, sessionID: sessionID)
        
        // Use a UIHostingController as window root view controller.
        if let windowScene = scene as? UIWindowScene {
            let window = UIWindow(windowScene: windowScene)
            window.rootViewController = UIHostingController(rootView: contentView)
            self.window = window
            window.makeKeyAndVisible()
            connect()
        }
    }
    
    // MARK: App IS running and App is called from Join Link
    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
         
        guard let url = URLContexts.first?.url else {
            return
        }
        
        let urlString = url.absoluteString
        let index = urlString.index(urlString.startIndex, offsetBy: 19)
        let urlSubstring = urlString[..<index] // encoreapp://spotify
        print(urlSubstring)
        
        if urlSubstring == "encoreapp://spotify" {
            let parameters = appRemote.authorizationParameters(from: url);
            
            if let access_token = parameters?[SPTAppRemoteAccessTokenKey] {
                appRemote.connectionParameters.accessToken = access_token
                self.accessToken = access_token
            } else if let error_description = parameters?[SPTAppRemoteErrorDescriptionKey] {
                // Show the error
            }
        } else {
            var sessionID = ""
            if let url = URLContexts.first?.url {
                // Handle URL
                let urlString = url.absoluteString
                sessionID = url.absoluteString.substring(from: urlString.index(urlString.startIndex, offsetBy: 12))
                print(sessionID)
            }
            
            let contentView = AppContentView(joinedViaURL: true, sessionID: sessionID)
            // Use a UIHostingController as window root view controller.
            if let windowScene = scene as? UIWindowScene {
                let window = UIWindow(windowScene: windowScene)
                window.rootViewController = UIHostingController(rootView: contentView)
                self.window = window
                window.makeKeyAndVisible()
            }
        }
    }
    
    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not neccessarily discarded (see `application:didDiscardSceneSessions` instead).
    }
    
    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }
    
    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }
    
    func connect() {
        //self.appRemote.authorizeAndPlayURI(self.playURI)
        
        musicController.appRemoteConnecting()
        self.appRemote.connect()
    }
    
    // MARK: AppRemoteDelegate
    
    func appRemoteDidEstablishConnection(_ appRemote: SPTAppRemote) {
        // Connection was successful, you can begin issuing commands
        self.appRemote.playerAPI?.delegate = self
        self.appRemote.playerAPI?.subscribe(toPlayerState: { (result, error) in
            if let error = error {
                debugPrint(error.localizedDescription)
            }
        })
        print("AppREMOTECOnnected")
        self.appRemote = appRemote
        musicController.appRemoteConnected()
    }
    
    func appRemote(_ appRemote: SPTAppRemote, didDisconnectWithError error: Error?) {
        print("disconnected")
    }
    
    func appRemote(_ appRemote: SPTAppRemote, didFailConnectionAttemptWithError error: Error?) {
        print("failed")
    }
    
    func playerStateDidChange(_ playerState: SPTAppRemotePlayerState) {
        debugPrint("Track name: %@", playerState.track.name)
    }
    
    func sceneDidBecomeActive(_ scene: UIScene) {
        if let _ = self.appRemote.connectionParameters.accessToken {
            self.appRemote.connect()
        }
    }
    
    func sceneWillResignActive(_ scene: UIScene) {
        if self.appRemote.isConnected {
            self.appRemote.disconnect()
        }
    }
    
    
    
}

