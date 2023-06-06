//
//  TokenManager.swift
//  HabitTracker
//
//  Created by Artem Marhaza on 25/05/2023.
//

import Foundation

protocol TokenManageable {
    func updateTokens(_ tokens: TokensInfo)
    func isValidToken(_ token: TokenInfo) -> Bool
    var accessToken: TokenInfo! { get }
    var refreshToken: TokenInfo! { get }
    var timeDelta: Double? { get }
}

class TokenManager: TokenManageable {

    private let storageManager: StorageManageable!

    private (set) var accessToken: TokenInfo!
    private (set) var refreshToken: TokenInfo!

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
        }
        getTimeDelta()
    }

    private func saveToken(_ token: String, isRefresh: Bool = false) {
        let token = parseToken(token)
        guard let token = token else { return }
        storageManager.saveToken(token, isRefresh: isRefresh)
    }

    private func saveTimeDelta(_ token: String, fromDate date: Date = Date()) {
        let payload = decode(jwtToken: token)
        guard let createdTimestamp = payload["iat"] as? Double else { return }
        let createAt = TimeInterval(createdTimestamp)

        let now = date.timeIntervalSince1970
        // ignore network delay (2 seconds)
        let delta = abs(now - createAt) > 2 ? now - createAt : 0

        storageManager.saveTimeDelta(delta)
    }

    private func getTimeDelta() {
        if let delta = storageManager.getTimeDelta() {
            timeDelta = delta
        }
    }

    private func getTokens() {
        let emptyToken = TokenInfo(token: "", expiresAt: 0.0)

        let access = storageManager.getToken(isRefresh: false)
        let refresh = storageManager.getToken(isRefresh: true)

        accessToken = access ?? emptyToken
        refreshToken = refresh ?? emptyToken
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

    func isValidToken(_ token: TokenInfo) -> Bool {
        guard let timeDelta = timeDelta else { return false }
        let now = Date().timeIntervalSinceReferenceDate

        return (token.expiresAt - now + timeDelta) > 0
    }
}

// MARK: Unit testing
extension TokenManager {
    func parseTokenForTesting(_ token: String) -> TokenInfo? {
        parseToken(token)
    }

    func saveTimeDeltaForTesting(_ token: String, fromDate date: Date) {
        saveTimeDelta(token, fromDate: date)
    }

    func saveTokenForTesting(_ token: String, isRefresh: Bool = false) {
        saveToken(token, isRefresh: isRefresh)
    }
}
