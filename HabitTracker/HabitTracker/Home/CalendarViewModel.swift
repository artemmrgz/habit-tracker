//
//  CalendarViewModel.swift
//  HabitTracker
//
//  Created by Artem Marhaza on 22/05/2023.
//

import UIKit

class CalendarViewModel {

    enum DayOfWeekFormat: String {
        case EEE
        case EEEE
    }

    enum DayOfMonthFormat: String {
        case d
        case dd
    }

    struct Day {
        var dayOfMonth: String
        var dayOfWeek: String
        var dayAsDate: Date
    }

    let dateToday = Date()
    var lastDayInSevenDays: Date!
    var sevenDays: [Day]!
    private var dayOfMonthFormat: DayOfMonthFormat
    private var dayOfWeekFormat: DayOfWeekFormat

    init(dayOfMonthFormat: DayOfMonthFormat = .dd, dayOfWeekFormat: DayOfWeekFormat = .EEE) {
        self.dayOfMonthFormat = dayOfMonthFormat
        self.dayOfWeekFormat = dayOfWeekFormat

        getSevenDays(endDate: dateToday)
    }

    private func getSevenDays(endDate: Date) {
        var days = [Day]()

        lastDayInSevenDays = endDate

        for index in -6...0 {
            days.append(getDate(index: index, currentDate: lastDayInSevenDays))
        }

        sevenDays = days
    }

    private func getDate(index: Int, currentDate: Date) -> Day {
        let dayOfMonth = DateFormatter()
        dayOfMonth.dateFormat = dayOfMonthFormat.rawValue

        let dayOfWeek = DateFormatter()
        dayOfWeek.locale = Locale(identifier: "en_US")
        dayOfWeek.dateFormat = dayOfWeekFormat.rawValue

        let date = Calendar.current.date(byAdding: .day, value: index, to: currentDate)!

        return Day(dayOfMonth: dayOfMonth.string(from: date),
                   dayOfWeek: dayOfWeek.string(from: date),
                   dayAsDate: date)
    }

    func getPreviousSevenDays() {
        let dateWeekAgo = Calendar.current.date(byAdding: .day, value: -7, to: lastDayInSevenDays)!

        getSevenDays(endDate: dateWeekAgo)
    }

    func getNextSevenDays() -> Bool {
        let dateNextWeek = Calendar.current.date(byAdding: .day, value: 7, to: lastDayInSevenDays)!

        let nextWeekAvailable = dateNextWeek <= dateToday

        if nextWeekAvailable {
            getSevenDays(endDate: dateNextWeek)
        }
        return nextWeekAvailable
    }
}
