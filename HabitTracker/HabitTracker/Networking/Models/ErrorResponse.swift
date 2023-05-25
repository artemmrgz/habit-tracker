//
//  ErrorResponse.swift
//  HabitTracker
//
//  Created by Artem Marhaza on 25/05/2023.
//

import Foundation

struct ErrorResponse: Codable {
    let code: Int
    let message: String

    func isAuth() -> Bool {
        return Errors.isAuthError(err: message)
    }
}
