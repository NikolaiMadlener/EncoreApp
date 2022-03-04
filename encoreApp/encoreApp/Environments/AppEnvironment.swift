//
//  AppEnvironment.swift
//  encoreApp
//
//  Created by Nikolai Madlener on 02.03.22.
//  Copyright © 2022 NikolaiEtienne. All rights reserved.
//

import Foundation


// MARK: - Injection
private struct LoginServiceKey: DependencyKey {
    static var currentValue: LoginService = LoginService()
}

private struct SessionServiceKey: DependencyKey {
    static var currentValue: SessionService = SessionService()
}

private struct SSEServiceKey: DependencyKey {
    static var currentValue: SSEService = SSEService()
}

private struct PlayerServiceKey: DependencyKey {
    static var currentValue: PlayerService = PlayerService()
}

private struct MusicControllerServiceKey: DependencyKey {
    static var currentValue: MusicControllerService = MusicControllerService()
}

private struct AppStateKey: DependencyKey {
    static var currentValue: Store<AppState> = Store<AppState>(AppState())
}

extension DependencyValues {
    // Services
    var loginService: LoginService {
        get { Self[LoginServiceKey.self] }
        set { Self[LoginServiceKey.self] = newValue }
    }
    var sessionService: SessionService {
        get { Self[SessionServiceKey.self] }
        set { Self[SessionServiceKey.self] = newValue }
    }
    var sseService: SSEService {
        get { Self[SSEServiceKey.self] }
        set { Self[SSEServiceKey.self] = newValue }
    }
    var playerService: PlayerService {
        get { Self[PlayerServiceKey.self] }
        set { Self[PlayerServiceKey.self] = newValue }
    }
    var musicControllerService: MusicControllerService {
        get { Self[MusicControllerServiceKey.self] }
        set { Self[MusicControllerServiceKey.self] = newValue }
    }
    
    // AppState
    var appState: Store<AppState> {
        get { Self[AppStateKey.self] }
        set { Self[AppStateKey.self] = newValue }
    }
}
