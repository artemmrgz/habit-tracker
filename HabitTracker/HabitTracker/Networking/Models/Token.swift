//
//  Token.swift
//  HabitTracker
//
//  Created by Artem Marhaza on 25/05/2023.
//

import Foundation

struct TokensInfo: Codable {
    let access: String
    let refresh: String
}

struct TokenInfo {
    let token: String
    let expiresAt: Double
}
