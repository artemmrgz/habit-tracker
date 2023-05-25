//
//  Token.swift
//  HabitTracker
//
//  Created by Artem Marhaza on 25/05/2023.
//

import Foundation

struct TokensInfo: Codable {
    let accessToken: String
    let accessTokenExpire: Int
    let refreshToken: String
    let refreshTokenExpire: Int
}

struct TokenInfo {
    let token: String
    let expiresAt: Int
}
