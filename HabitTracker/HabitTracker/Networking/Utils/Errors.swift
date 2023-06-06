//
//  Errors.swift
//  HabitTracker
//
//  Created by Artem Marhaza on 25/05/2023.
//

import Foundation

struct Errors {
    
    static let errorConvertingToHttpResponse = "Error coverting response to HTTP response"
    static let errorNilBody = "Error nil body"
    static let errorParsingErrorResponse = "Error parsing error response"
    static let errorParsingResponse = "Error parsing response"
    
    
    static func isAuthError(_ error: String) -> Bool {
        //TODO: implement this checking
        return true
    }
}
