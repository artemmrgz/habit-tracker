//
//  StorageManager.swift
//  HabitTracker
//
//  Created by Artem Marhaza on 25/05/2023.
//

import Foundation

protocol StorageManageable {
    func dropTokens()
    func saveTimeDelta(_ delta: Double)
    func getTimeDelta() -> Double?
    func saveToken(_ token: TokenInfo, isRefresh: Bool)
    func getToken(isRefresh: Bool) -> TokenInfo?
}

class UserDefaultsManager: StorageManageable {

    static let shared = UserDefaultsManager()
    private let defaults = UserDefaults.standard

    private static let accessTokenKey = "accessToken"
    private static let accessTokenExpireKey = "accessTokenExpire"
    private static let refreshTokenKey = "refreshToken"
    private static let refreshTokenExpireKey = "refreshTokenExpire"
    private static let timeDeltaKey = "timeDelta"

    func saveToken(_ token: TokenInfo, isRefresh: Bool) {
        if isRefresh {
            defaults.set(token.token, forKey: UserDefaultsManager.refreshTokenKey)
            defaults.set(token.expiresAt, forKey: UserDefaultsManager.refreshTokenExpireKey)
        } else {
            defaults.set(token.token, forKey: UserDefaultsManager.accessTokenKey)
            defaults.set(token.expiresAt, forKey: UserDefaultsManager.accessTokenExpireKey)
        }
    }

    func getToken(isRefresh: Bool) -> TokenInfo? {
        let token: String?
        let expiresAt: Double?

        if isRefresh {
            token = defaults.object(forKey: UserDefaultsManager.refreshTokenKey) as? String
            expiresAt = defaults.object(forKey: UserDefaultsManager.refreshTokenExpireKey) as? Double
        } else {
            token = defaults.object(forKey: UserDefaultsManager.accessTokenKey) as? String
            expiresAt = defaults.object(forKey: UserDefaultsManager.accessTokenExpireKey) as? Double
        }

        if let token, let expiresAt {
            return TokenInfo(token: token, expiresAt: expiresAt)
        }
        return nil
    }

    func saveTimeDelta(_ delta: Double) {
        defaults.set(delta, forKey: UserDefaultsManager.timeDeltaKey)
    }

    func getTimeDelta() -> Double? {
        return defaults.object(forKey: UserDefaultsManager.timeDeltaKey) as? Double
    }

    func dropTokens() {
        defaults.removeObject(forKey: UserDefaultsManager.accessTokenKey)
        defaults.removeObject(forKey: UserDefaultsManager.accessTokenExpireKey)
        defaults.removeObject(forKey: UserDefaultsManager.refreshTokenKey)
        defaults.removeObject(forKey: UserDefaultsManager.refreshTokenExpireKey)
    }
}
