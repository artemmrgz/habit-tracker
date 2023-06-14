//
//  HabitsViewModel.swift
//  HabitTracker
//
//  Created by Artem Marhaza on 14/06/2023.
//

import UIKit

enum Status: String {
    case ACTIVE
    case ARCHIVED
    case COMPLETED
}

class HabitsViewModel {
    let networkService = NetworkService.shared()

    var activeHabits = [Habit]()
    var completedHabits = [Habit]()
    var failedHabits = [Habit]()

    var error: ObservableObject<UIAlertController?> = ObservableObject(nil)

    func getHabits(forDate date: Date, completion: @escaping () -> Void) {
        let group = DispatchGroup()
        getActiveHabits(forDate: date, group: group)
        getCompletedHabits(forDate: date, group: group)

        group.notify(queue: .main) {
            completion()
        }
    }

    func getActiveHabits(forDate date: Date, group: DispatchGroup) {
        group.enter()
        networkService.getHabits(forDate: date, status: .ACTIVE) { [weak self] result in
            var errorAlert: UIAlertController?

            switch result {
            case .success(let habits):
                self?.activeHabits = habits.data
            case .authError(let error):
                errorAlert = ErrorAlert.buildForError(message: error.message)
            case .networkError(_):
                errorAlert = ErrorAlert.networkError()
            case .serverError(let error):
                errorAlert = ErrorAlert.buildForError(message: error.message)
            case .encodingError:
                errorAlert = ErrorAlert.encodingError()
            }
            if errorAlert != nil, self?.error.value == nil {
                self?.error.value = errorAlert
            }
            group.leave()
        }
    }

    func getCompletedHabits(forDate date: Date, group: DispatchGroup) {
        group.enter()
        networkService.getHabits(forDate: date, status: .COMPLETED) { [weak self] result in
            var errorAlert: UIAlertController?

            switch result {
            case .success(let habits):
                self?.completedHabits = habits.data
            case .authError(let error):
                errorAlert = ErrorAlert.buildForError(message: error.message)
            case .networkError(_):
                errorAlert = ErrorAlert.networkError()
            case .serverError(let error):
                errorAlert = ErrorAlert.buildForError(message: error.message)
            case .encodingError:
                errorAlert = ErrorAlert.encodingError()
            }
            if errorAlert != nil, self?.error.value == nil {
                self?.error.value = errorAlert
            }
            group.leave()
        }
    }

}
