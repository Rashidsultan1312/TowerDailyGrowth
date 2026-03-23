//
//  DayRecord.swift
//  habittracker
//
//  Created by Oleg Yakushin on 13/3/26.
//

import Foundation

enum GoalState: String, Codable {
    case neutral
    case completed
    case notCompleted

    mutating func advance() {
        // Three-step cycle: neutral -> completed -> not completed -> neutral.
        switch self {
        case .neutral:
            self = .completed
        case .completed:
            self = .notCompleted
        case .notCompleted:
            self = .neutral
        }
    }
}

enum DayStatus {
    case neutral
    case failed
    case partial
    case completed

    var towerDelta: Double {
        switch self {
        case .neutral:
            return 0
        case .failed:
            return -1
        case .partial:
            return 0.5
        case .completed:
            return 1
        }
    }
}

struct DayRecord: Identifiable, Codable, Equatable {
    var id: String
    var goalStates: [String: GoalState]

    init(id: String, goalStates: [String: GoalState] = [:]) {
        self.id = id
        self.goalStates = goalStates
    }

    func state(for goalID: UUID) -> GoalState {
        goalStates[goalID.uuidString] ?? .neutral
    }

    mutating func setState(_ state: GoalState, for goalID: UUID) {
        if state == .neutral {
            goalStates.removeValue(forKey: goalID.uuidString)
        } else {
            goalStates[goalID.uuidString] = state
        }
    }
}

struct DayCompletion {
    let percent: Double
    let completed: Int
    let total: Int
    let marked: Int

    var isNeutral: Bool {
        marked == 0
    }

    func status(for date: Date, calendar: Calendar = .current) -> DayStatus {
        guard total > 0 else {
            return .neutral
        }
        if marked == 0 {
            return DateUtils.isPastDay(date, calendar: calendar) ? .failed : .neutral
        }
        if completed == 0 {
            return .failed
        }
        if completed == total {
            return .completed
        }
        return .partial
    }
}
