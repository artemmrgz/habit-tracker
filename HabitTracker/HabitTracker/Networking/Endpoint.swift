//
//  Endpoint.swift
//  HabitTracker
//
//  Created by Artem Marhaza on 25/05/2023.
//

import Foundation

enum Endpoint {
    
    static let baseURL = "http://127.0.0.1:8080/"
    
    case auth(Auth)
    
    enum Auth {
        case sendEmail
        case sendVerificationCode
        case refreshToken
    }
    
    
    func path() -> String {
        switch self {
        case.auth(let auth):
            var path = "auth/"
            
            switch auth {
            case .sendEmail:
                path += "email/"
            case .sendVerificationCode:
                path += "token/"
            case .refreshToken:
                path += "token/refresh/"
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
