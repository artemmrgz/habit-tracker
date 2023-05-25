//
//  TokenManager.swift
//  HabitTracker
//
//  Created by Artem Marhaza on 25/05/2023.
//

import Foundation

class TokenManager {
    
    let storageManager: StorageManageable!
    
    var accessToken: TokenInfo!
    var refreshToken: TokenInfo!

    let accessTokenLifeSeconds = 5 * 60
    
    init(storageManager: StorageManageable = UserDefaultsManager()) {
        self.storageManager = storageManager
        
        getTokens()
    }
    
    func updateTokens(_ tokens: TokensInfo) {
        storageManager.saveAuthTokens(tokens: tokens)
        
        getTokens()
    }
    
    func getTokens() {
        accessToken = storageManager.getAccessToken()
        refreshToken = storageManager.getRefreshToken()
    }
}
