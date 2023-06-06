//
//  ObtainTokensBodies.swift
//  HabitTracker
//
//  Created by Artem Marhaza on 26/05/2023.
//

import Foundation

struct EmailBody: Codable {
    let email: String
}

struct VerificationCodeBody: Codable {
    let email: String
    let code: String
}

struct SuccessResponse: Codable {
}
