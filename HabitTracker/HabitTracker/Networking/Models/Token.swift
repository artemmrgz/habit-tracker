//
//  Token.swift
//  HabitTracker
//
//  Created by Artem Marhaza on 25/05/2023.
//

import Foundation

// TODO: choose tokens model
struct TokensInfo2: Codable {
    let accessToken: String
    let accessTokenExpire: Int
    let refreshToken: String
    let refreshTokenExpire: Int
}

struct TokensInfo: Codable {
    let access: String
    let refresh: String
}

struct TokenInfo {
    let token: String
    let expiresAt: Int
}
