//
//  GoalsViewModel.swift
//  habittracker
//
//  Created by Oleg Yakushin on 13/3/26.
//

import Foundation
import Combine

final class GoalsViewModel: ObservableObject {
    private let store: HabitStore
    private var cancellables: Set<AnyCancellable> = []

    init(store: HabitStore) {
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

    func addGoal(name: String, disabledWeekdays: Set<Int>, startDate: Date) {
        store.addGoal(name: name, disabledWeekdays: disabledWeekdays, startDate: startDate)
    }

    func updateGoal(_ goal: Goal) {
        store.updateGoal(goal)
    }

    func deleteGoal(_ goal: Goal) {
        store.deleteGoal(id: goal.id)
    }
}
