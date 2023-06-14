//
//  Habit.swift
//  HabitTracker
//
//  Created by Artem Marhaza on 06/06/2023.
//

import Foundation

struct Habit: Codable {
    let name: String
    let measurementType: String
    let completionData: CompletionData
    let frequency: String

    enum CodingKeys: String, CodingKey {
        case name
        case frequency
        case measurementType = "measurement_type"
        case completionData = "completion_data"
    }

    struct CompletionData: Codable {
        let target: Int
        let current: Int
    }
}

struct Habits: Codable {
    let data: [Habit]
}
