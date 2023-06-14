//
//  Endpoint.swift
//  HabitTracker
//
//  Created by Artem Marhaza on 25/05/2023.
//

import Foundation

enum Endpoint {

    static let baseURL = "http://127.0.0.1:8000/api/"

    case auth(Auth)
    case me(Resource)

    enum Auth {
        case sendEmail
        case sendVerificationCode
        case refreshToken
    }

    enum Resource {
        case habits
    }

    func path() -> String {
        switch self {
        case .auth(let action):
            var path = "auth/"

            switch action {
            case .sendEmail:
                path += "email/"
            case .sendVerificationCode:
                path += "token/"
            case .refreshToken:
                path += "token/refresh/"
            }
            return path

        case .me(let resource):
            var path = "me/"

            switch resource {
            case .habits:
                path += "habits/"
            }
            return path
        }
    }

    var absoluteURL: URL {
        return URL(string: Endpoint.baseURL + self.path())!
    }
}

enum Method: String {
    case GET
    case POST
}
