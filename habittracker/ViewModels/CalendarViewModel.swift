//
//  CalendarViewModel.swift
//  habittracker
//
//  Created by Oleg Yakushin on 13/3/26.
//

import Foundation
import Combine

final class CalendarViewModel: ObservableObject {
    @Published var currentMonth: Date

    private let store: HabitStore
    private var cancellables: Set<AnyCancellable> = []

    init(store: HabitStore) {
        self.store = store
        self.currentMonth = DateUtils.startOfMonth(for: Date())

        store.objectWillChange
            .sink { [weak self] _ in
                self?.objectWillChange.send()
            }
            .store(in: &cancellables)
    }

    var monthTitle: String {
        DateUtils.monthTitle(for: currentMonth)
    }

    var monthGrid: [Date?] {
        DateUtils.monthGrid(for: currentMonth)
    }

    var weekdaySymbols: [String] {
        DateUtils.weekdaySymbols()
    }

    func goToPreviousMonth() {
        currentMonth = DateUtils.addingMonths(-1, to: currentMonth)
    }

    func goToNextMonth() {
        currentMonth = DateUtils.addingMonths(1, to: currentMonth)
    }

    func completion(for date: Date) -> DayCompletion {
        store.completion(for: date)
    }
}
