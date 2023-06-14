//
//  URL+Utils.swift
//  HabitTracker
//
//  Created by Artem Marhaza on 12/06/2023.
//

import Foundation

extension URL {
    mutating func appendQueryItem(name: String, value: String) {
        guard var urlComponents = URLComponents(string: absoluteString) else { return }

        var queryItems = urlComponents.queryItems ?? []

        let queryItem = URLQueryItem(name: name, value: value)
        queryItems.append(queryItem)
        urlComponents.queryItems = queryItems

        self = urlComponents.url!
    }
}
