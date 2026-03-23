//
//  DayViewModel.swift
//  habittracker
//
//  Created by Oleg Yakushin on 13/3/26.
//

import Foundation
import Combine

final class DayViewModel: ObservableObject {
    @Published var date: Date

    private let store: HabitStore
    private var cancellables: Set<AnyCancellable> = []

    init(date: Date, store: HabitStore) {
        self.date = date
        self.store = store

        store.objectWillChange
            .sink { [weak self] _ in
                self?.objectWillChange.send()
            }
            .store(in: &cancellables)
    }

    var goals: [Goal] {
        store.sortedGoals
    }

    func completion() -> DayCompletion {
        store.completion(for: date)
    }

    func isGoalActive(_ goal: Goal) -> Bool {
        goal.isActive(on: date)
    }

    func inactiveLabel(for goal: Goal) -> String {
        if goal.startsAfter(date) {
            return "Starts on \(DateUtils.mediumDateString(for: goal.startDate))"
        }
        return "Disabled today"
    }

    func state(for goal: Goal) -> GoalState {
        store.state(for: goal.id, on: date)
    }

    func toggle(goal: Goal) {
        guard isGoalActive(goal) else { return }
        store.toggleState(for: goal.id, on: date)
    }
}
