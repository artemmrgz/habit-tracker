//
//  ObservableObject.swift
//  HabitTracker
//
//  Created by Artem Marhaza on 30/05/2023.
//

import Foundation

final class ObservableObject<T> {

    var value: T {
        didSet {
            listener?(value)
        }
    }

    var listener: ((T) -> Void)?

    init(_ value: T) {
        self.value = value
    }

    func bind(_ listener: @escaping (T) -> Void) {
        listener(value)
        self.listener = listener
    }
}
