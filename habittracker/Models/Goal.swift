//
//  Goal.swift
//  habittracker
//
//  Created by Oleg Yakushin on 13/3/26.
//

import Foundation

struct Goal: Identifiable, Codable, Equatable {
    var id: UUID
    var name: String
    var disabledWeekdays: Set<Int>
    var startDate: Date

    init(id: UUID = UUID(), name: String, disabledWeekdays: Set<Int> = [], startDate: Date = Date()) {
        self.id = id
        self.name = name
        self.disabledWeekdays = disabledWeekdays
        self.startDate = startDate
    }

    func isActive(on date: Date, calendar: Calendar = .current) -> Bool {
        let day = calendar.startOfDay(for: date)
        let start = calendar.startOfDay(for: startDate)
        guard day >= start else { return false }

        let weekday = calendar.component(.weekday, from: date)
        return !disabledWeekdays.contains(weekday)
    }

    func startsAfter(_ date: Date, calendar: Calendar = .current) -> Bool {
        calendar.startOfDay(for: startDate) > calendar.startOfDay(for: date)
    }

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case disabledWeekdays
        case startDate
        case createdAt
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decodeIfPresent(UUID.self, forKey: .id) ?? UUID()
        name = try container.decode(String.self, forKey: .name)
        disabledWeekdays = try container.decodeIfPresent(Set<Int>.self, forKey: .disabledWeekdays) ?? []
        startDate =
            try container.decodeIfPresent(Date.self, forKey: .startDate)
            ?? container.decodeIfPresent(Date.self, forKey: .createdAt)
            ?? Date()
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(disabledWeekdays, forKey: .disabledWeekdays)
        try container.encode(startDate, forKey: .startDate)
    }
}
