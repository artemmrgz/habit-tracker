//
//  ErrorAlert.swift
//  HabitTracker
//
//  Created by Artem Marhaza on 01/06/2023.
//

import UIKit

struct ErrorAlert {
    private static let alert: UIAlertController = {
        let alert = UIAlertController(title: "", message: "", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel))
        return alert
    }()
    
    static func buildForError(message: String) -> UIAlertController {
        alert.title = "An error has occured"
        alert.message = message
        return alert
    }
    
    static func build(title: String, message: String) -> UIAlertController {
        alert.title = title
        alert.message = message
        return alert
    }
    
    static func networkError() -> UIAlertController {
        return buildForError(message: "Please check your internet connection and try again")
    }
}
