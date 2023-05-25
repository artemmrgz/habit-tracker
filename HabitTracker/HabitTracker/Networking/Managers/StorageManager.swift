//
//  StorageManager.swift
//  HabitTracker
//
//  Created by Artem Marhaza on 25/05/2023.
//

import Foundation

protocol StorageManageable {
    func saveAuthTokens(tokens: TokensInfo)
    func getAccessToken() -> TokenInfo
    func getRefreshToken() -> TokenInfo
    func dropTokens()
}


class UserDefaultsManager: StorageManageable {
    
    static let shared = UserDefaultsManager()
    private let defaults = UserDefaults.standard
    
    private static let accessTokenKey = "accessToken"
    private static let accessTokenExpireKey = "accessTokenExpire"
    private static let refreshTokenKey = "refreshToken"
    private static let refreshTokenExpireKey = "refreshTokenExpire"
    
    
    func saveAuthTokens(tokens: TokensInfo) {
        defaults.set(tokens.accessToken, forKey: UserDefaultsManager.accessTokenKey)
        defaults.set(tokens.accessTokenExpire, forKey: UserDefaultsManager.accessTokenExpireKey)
        defaults.set(tokens.refreshToken, forKey: UserDefaultsManager.refreshTokenKey)
        defaults.set(tokens.accessToken, forKey: UserDefaultsManager.refreshTokenExpireKey)
    }
    
    func getAccessToken() -> TokenInfo {
        let accessToken = defaults.string(forKey: UserDefaultsManager.accessTokenKey) ?? ""
        let expiresAt = defaults.integer(forKey: UserDefaultsManager.accessTokenExpireKey)
        
        return TokenInfo(token: accessToken, expiresAt: expiresAt)
    }
    
    func getRefreshToken() -> TokenInfo {
        let accessToken = defaults.string(forKey: UserDefaultsManager.refreshTokenKey) ?? ""
        let expiresAt = defaults.integer(forKey: UserDefaultsManager.refreshTokenExpireKey)
        
        return TokenInfo(token: accessToken, expiresAt: expiresAt)
    }
    
    func dropTokens() {
        defaults.removeObject(forKey: UserDefaultsManager.accessTokenKey)
        defaults.removeObject(forKey: UserDefaultsManager.accessTokenExpireKey)
        defaults.removeObject(forKey: UserDefaultsManager.refreshTokenKey)
        defaults.removeObject(forKey: UserDefaultsManager.refreshTokenExpireKey)
    }
}
