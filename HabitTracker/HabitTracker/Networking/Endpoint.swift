//
//  Endpoint.swift
//  HabitTracker
//
//  Created by Artem Marhaza on 25/05/2023.
//

import Foundation

enum Endpoint {
    
    static let baseURL = "https://test/"
    
    case refreshToken
    
    func path() -> String {
        switch self {
        case .refreshToken:
            return "api/refresh/"
        }
    }
    
    var absoluteURL: URL {
        return URL(string: Endpoint.baseURL + self.path())!
    }
}
