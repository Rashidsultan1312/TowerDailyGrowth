//
//  HabitStore.swift
//  habittracker
//
//  Created by Oleg Yakushin on 13/3/26.
//

import Foundation
import Combine

struct UsageStats: Equatable {
    let totalTrackedDays: Int
    let completedDays: Int
    let partialDays: Int
    let failedDays: Int
    let currentStreak: Int
    let longestStreak: Int

    static let empty = UsageStats(
        totalTrackedDays: 0,
        completedDays: 0,
        partialDays: 0,
        failedDays: 0,
        currentStreak: 0,
        longestStreak: 0
    )
}

final class HabitStore: ObservableObject {
    @Published private(set) var goals: [Goal] = []
    @Published private(set) var records: [String: DayRecord] = [:]

    private let calendar: Calendar
    private let storeURL: URL

    init(preview: Bool = false, calendar: Calendar = .current) {
        self.calendar = calendar
        self.storeURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("habit_data.json")

        if preview {
            loadSampleData()
        } else {
            load()
        }
    }

    var sortedGoals: [Goal] {
        goals.sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
    }

    func addGoal(name: String, disabledWeekdays: Set<Int> = [], startDate: Date = Date()) {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        goals.append(
            Goal(
                name: trimmed,
                disabledWeekdays: disabledWeekdays,
                startDate: calendar.startOfDay(for: startDate)
            )
        )
        save()
    }

    func updateGoal(_ goal: Goal) {
        guard let index = goals.firstIndex(where: { $0.id == goal.id }) else { return }
        var updatedGoal = goal
        updatedGoal.startDate = calendar.startOfDay(for: goal.startDate)
        goals[index] = updatedGoal
        save()
    }

    func deleteGoal(id: UUID) {
        goals.removeAll { $0.id == id }
        for key in records.keys {
            guard var record = records[key] else { continue }
            record.goalStates.removeValue(forKey: id.uuidString)
            if record.goalStates.isEmpty {
                records.removeValue(forKey: key)
            } else {
                records[key] = record
            }
        }
        save()
    }

    func dayRecord(for date: Date) -> DayRecord {
        let key = DateUtils.dateKey(for: date, calendar: calendar)
        return records[key] ?? DayRecord(id: key)
    }

    func state(for goalID: UUID, on date: Date) -> GoalState {
        dayRecord(for: date).state(for: goalID)
    }

    func setState(_ state: GoalState, for goalID: UUID, on date: Date) {
        let key = DateUtils.dateKey(for: date, calendar: calendar)
        var record = records[key] ?? DayRecord(id: key)
        record.setState(state, for: goalID)
        if record.goalStates.isEmpty {
            records.removeValue(forKey: key)
        } else {
            records[key] = record
        }
        save()
    }

    func toggleState(for goalID: UUID, on date: Date) {
        let key = DateUtils.dateKey(for: date, calendar: calendar)
        var record = records[key] ?? DayRecord(id: key)
        var state = record.state(for: goalID)
        state.advance()
        record.setState(state, for: goalID)
        if record.goalStates.isEmpty {
            records.removeValue(forKey: key)
        } else {
            records[key] = record
        }
        save()
    }

    func completion(for date: Date) -> DayCompletion {
        let activeGoals = goals.filter { $0.isActive(on: date, calendar: calendar) }
        guard !activeGoals.isEmpty else {
            return DayCompletion(percent: 0, completed: 0, total: 0, marked: 0)
        }

        let record = dayRecord(for: date)
        var completed = 0
        var marked = 0

        for goal in activeGoals {
            let state = record.state(for: goal.id)
            if state != .neutral {
                marked += 1
            }
            if state == .completed {
                completed += 1
            }
        }

        let total = activeGoals.count
        // Percent is based on active goals for the weekday.
        let percent = total == 0 ? 0 : Double(completed) / Double(total)
        return DayCompletion(percent: percent, completed: completed, total: total, marked: marked)
    }

    func status(for date: Date) -> DayStatus {
        completion(for: date).status(for: date, calendar: calendar)
    }

    func trackingStartDate(relativeTo referenceDate: Date = Date()) -> Date? {
        let goalStart = goals.map(\.startDate).min()
        let recordStart = records.keys.compactMap { DateUtils.date(fromKey: $0, calendar: calendar) }.min()

        guard let startDate = [goalStart, recordStart].compactMap({ $0 }).min() else {
            return nil
        }

        return min(calendar.startOfDay(for: startDate), calendar.startOfDay(for: referenceDate))
    }

    func currentStreak(relativeTo referenceDate: Date = Date()) -> Int {
        let dates = trackingDates(relativeTo: referenceDate)
        var streak = 0

        for date in dates.reversed() {
            switch status(for: date) {
            case .completed, .partial:
                streak += 1
            case .failed:
                return streak
            case .neutral:
                continue
            }
        }

        return streak
    }

    func longestStreak(relativeTo referenceDate: Date = Date()) -> Int {
        let dates = trackingDates(relativeTo: referenceDate)
        var currentRun = 0
        var longestRun = 0

        for date in dates {
            switch status(for: date) {
            case .completed, .partial:
                currentRun += 1
                longestRun = max(longestRun, currentRun)
            case .failed:
                currentRun = 0
            case .neutral:
                continue
            }
        }

        return longestRun
    }

    func usageStats(relativeTo referenceDate: Date = Date()) -> UsageStats {
        let dates = trackingDates(relativeTo: referenceDate)
        guard !dates.isEmpty else { return .empty }

        var completedDays = 0
        var partialDays = 0
        var failedDays = 0

        for date in dates {
            switch status(for: date) {
            case .completed:
                completedDays += 1
            case .partial:
                partialDays += 1
            case .failed:
                failedDays += 1
            case .neutral:
                continue
            }
        }

        return UsageStats(
            totalTrackedDays: completedDays + partialDays + failedDays,
            completedDays: completedDays,
            partialDays: partialDays,
            failedDays: failedDays,
            currentStreak: currentStreak(relativeTo: referenceDate),
            longestStreak: longestStreak(relativeTo: referenceDate)
        )
    }

    private func trackingDates(relativeTo referenceDate: Date = Date()) -> [Date] {
        guard let startDate = trackingStartDate(relativeTo: referenceDate) else {
            return []
        }

        let endDate = calendar.startOfDay(for: referenceDate)
        return DateUtils.days(from: startDate, through: endDate, calendar: calendar)
    }

    private func load() {
        do {
            let data = try Data(contentsOf: storeURL)
            let decoder = JSONDecoder()
            let decoded = try decoder.decode(HabitData.self, from: data)
            goals = decoded.goals
            records = Dictionary(uniqueKeysWithValues: decoded.records.map { ($0.id, $0) })
        } catch {
            goals = []
            records = [:]
        }
    }

    private func save() {
        do {
            let encoder = JSONEncoder()
            encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
            let data = try encoder.encode(HabitData(goals: goals, records: Array(records.values)))
            try data.write(to: storeURL, options: [.atomic])
        } catch {
            // MVP: ignore persistence errors silently.
        }
    }

    private func loadSampleData() {
        let startDate = DateUtils.startOfMonth(for: Date(), calendar: calendar)
        let goal1 = Goal(name: "Sword Practice", startDate: startDate)
        let goal2 = Goal(name: "Read Ancient Scrolls", startDate: startDate)
        let goal3 = Goal(name: "Meditate", startDate: startDate)
        goals = [goal1, goal2, goal3]

        let today = Date()
        let days = DateUtils.monthDays(for: today, calendar: calendar)
        var records: [String: DayRecord] = [:]

        for day in days {
            let key = DateUtils.dateKey(for: day, calendar: calendar)
            var record = DayRecord(id: key)
            let dayNumber = calendar.component(.day, from: day)
            if dayNumber % 2 == 0 {
                record.setState(.completed, for: goal1.id)
            }
            if dayNumber % 3 == 0 {
                record.setState(.notCompleted, for: goal2.id)
            }
            if dayNumber % 4 == 0 {
                record.setState(.completed, for: goal3.id)
            }
            if !record.goalStates.isEmpty {
                records[key] = record
            }
        }

        self.records = records
    }

    static var preview: HabitStore {
        HabitStore(preview: true)
    }
}

private struct HabitData: Codable {
    var goals: [Goal]
    var records: [DayRecord]
}
