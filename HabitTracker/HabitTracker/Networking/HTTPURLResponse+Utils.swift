//
//  HTTPURLResponse+Utils.swift
//  HabitTracker
//
//  Created by Artem Marhaza on 25/05/2023.
//

import Foundation

extension HTTPURLResponse {
    func isSuccessful() -> Bool {
        print(statusCode)
        return statusCode >= 200 && statusCode <= 299
    }
}
