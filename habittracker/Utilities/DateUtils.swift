//
//  DateUtils.swift
//  habittracker
//
//  Created by Oleg Yakushin on 13/3/26.
//

import Foundation

struct DateUtils {
    static func dateKey(for date: Date, calendar: Calendar = .current) -> String {
        let components = calendar.dateComponents([.year, .month, .day], from: date)
        let year = components.year ?? 0
        let month = components.month ?? 0
        let day = components.day ?? 0
        return String(format: "%04d-%02d-%02d", year, month, day)
    }

    static func date(fromKey key: String, calendar: Calendar = .current) -> Date? {
        let parts = key.split(separator: "-").compactMap { Int($0) }
        guard parts.count == 3 else { return nil }

        var components = DateComponents()
        components.year = parts[0]
        components.month = parts[1]
        components.day = parts[2]
        return calendar.date(from: components)
    }

    static func startOfMonth(for date: Date, calendar: Calendar = .current) -> Date {
        let components = calendar.dateComponents([.year, .month], from: date)
        return calendar.date(from: components) ?? date
    }

    static func monthTitle(for date: Date, calendar: Calendar = .current) -> String {
        let formatter = DateFormatter()
        formatter.calendar = calendar
        formatter.locale = Locale.current
        formatter.dateFormat = "LLLL yyyy"
        return formatter.string(from: date)
    }

    static func mediumDateString(for date: Date, calendar: Calendar = .current) -> String {
        let formatter = DateFormatter()
        formatter.calendar = calendar
        formatter.locale = Locale.current
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }

    static func monthDays(for date: Date, calendar: Calendar = .current) -> [Date] {
        let start = startOfMonth(for: date, calendar: calendar)
        guard let range = calendar.range(of: .day, in: .month, for: start) else {
            return []
        }
        return range.compactMap { day in
            calendar.date(byAdding: .day, value: day - 1, to: start)
        }
    }

    static func monthGrid(for date: Date, calendar: Calendar = .current) -> [Date?] {
        let days = monthDays(for: date, calendar: calendar)
        guard let first = days.first else { return [] }
        let weekday = calendar.component(.weekday, from: first)
        let firstWeekday = calendar.firstWeekday
        let leadingSpaces = (weekday - firstWeekday + 7) % 7
        return Array(repeating: nil, count: leadingSpaces) + days.map { Optional($0) }
    }

    static func weekdaySymbols(calendar: Calendar = .current) -> [String] {
        let symbols = calendar.shortStandaloneWeekdaySymbols
        let order = weekdayOrder(calendar: calendar)
        return order.map { symbols[$0 - 1] }
    }

    static func weekdayOrder(calendar: Calendar = .current) -> [Int] {
        let first = calendar.firstWeekday
        return (0..<7).map { offset in
            ((first - 1 + offset) % 7) + 1
        }
    }

    static func weekdaySymbol(for weekday: Int, calendar: Calendar = .current) -> String {
        let symbols = calendar.shortStandaloneWeekdaySymbols
        let index = max(0, min(weekday - 1, symbols.count - 1))
        return symbols[index]
    }

    static func addingMonths(_ value: Int, to date: Date, calendar: Calendar = .current) -> Date {
        calendar.date(byAdding: .month, value: value, to: date) ?? date
    }

    static func days(from startDate: Date, through endDate: Date, calendar: Calendar = .current) -> [Date] {
        let start = calendar.startOfDay(for: startDate)
        let end = calendar.startOfDay(for: endDate)
        guard start <= end else { return [] }

        var dates: [Date] = []
        var current = start

        while current <= end {
            dates.append(current)
            guard let next = calendar.date(byAdding: .day, value: 1, to: current) else {
                break
            }
            current = next
        }

        return dates
    }

    static func isPastDay(_ date: Date, comparedTo referenceDate: Date = Date(), calendar: Calendar = .current) -> Bool {
        let day = calendar.startOfDay(for: date)
        let referenceDay = calendar.startOfDay(for: referenceDate)
        return day < referenceDay
    }
}
