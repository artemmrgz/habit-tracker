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

    var timeDelta: Double?
    
    init(storageManager: StorageManageable = UserDefaultsManager()) {
        self.storageManager = storageManager
        
        getTokens()
        getTimeDelta()
    }
    
    func updateTokens(_ tokens: TokensInfo) {
        saveToken(tokens.access)
        saveToken(tokens.refresh, isRefresh: true)
        
        getTokens()
        
        if timeDelta == nil {
            saveTimeDelta(tokens.access)
            
            getTimeDelta()
        }
    }
    
    func saveToken(_ token: String, isRefresh: Bool = false) {
        let token = parseToken(token)
        guard let token = token else { return }
        storageManager.saveToken(token, isRefresh: isRefresh)
    }
    
    private func saveTimeDelta(_ token: String) {
        let payload = decode(jwtToken: token)
        guard let createdTimestamp = payload["iat"] as? Double else { return }
        let createAt = TimeInterval(createdTimestamp)
        
        let now = Date().timeIntervalSinceReferenceDate
        // ignore network delay (2 seconds)
        let delta = abs(now - createAt) > 2 ? now - createAt : 0
        print("delta", delta)
        
        storageManager.saveTimeDelta(delta)
    }
    
    private func getTimeDelta() {
        if let delta = storageManager.getTimeDelta() {
            timeDelta = delta
        }
    }
    
    func getTokens() {
        accessToken = storageManager.getToken(isRefresh: false)
        refreshToken = storageManager.getToken(isRefresh: true)
    }
    
    private func parseToken(_ token: String) -> TokenInfo? {
        let payload = decode(jwtToken: token)
        guard let expiresAt = payload["exp"] as? Double else { return nil }
        
        return TokenInfo(token: token, expiresAt: expiresAt)
    }
    
    private func decode(jwtToken jwt: String) -> [String: Any] {
      let segments = jwt.components(separatedBy: ".")
      return decodeJWTPart(segments[1]) ?? [:]
    }

    private func decodeJWTPart(_ value: String) -> [String: Any]? {
        let str = base64String(value)
        let data = Data(base64Encoded: str, options: .ignoreUnknownCharacters)
        guard let data = data,
              let json = try? JSONSerialization.jsonObject(with: data, options: []),
                let payload = json as? [String: Any] else {
          return nil
      }
      return payload
    }
    
    private func base64String(_ input: String) -> String {
        var base64 = input
            .replacingOccurrences(of: "-", with: "+")
            .replacingOccurrences(of: "_", with: "/")
        switch base64.count % 4 {
        case 2:
             base64 = base64.appending("==")
       
        case 3:
             base64 = base64.appending("=")
        default:
             break
        }
        return base64
     }
}
