//
//  ProgressViewModel.swift
//  habittracker
//
//  Created by Oleg Yakushin on 13/3/26.
//

import Foundation
import Combine

struct TowerBlock: Identifiable, Equatable {
    enum Kind: Equatable {
        case full
        case half
    }

    let id: Int
    let kind: Kind
}

final class ProgressViewModel: ObservableObject {
    @Published private(set) var blocks: [TowerBlock] = []
    @Published private(set) var currentStreak = 0

    private let store: HabitStore
    private var cancellables: Set<AnyCancellable> = []
    private let milestones: [(days: Int, message: String)] = [
        (30, "Unstoppable"),
        (15, "Impressive consistency"),
        (10, "Strong discipline"),
        (5, "Keep it up"),
        (3, "Nice start")
    ]

    init(store: HabitStore) {
        self.store = store

        store.objectWillChange
            .sink { [weak self] _ in
                DispatchQueue.main.async {
                    self?.rebuild()
                    self?.objectWillChange.send()
                }
            }
            .store(in: &cancellables)

        rebuild()
    }

    var title: String {
        if blocks.isEmpty {
            return "Start building your discipline tower"
        }
        return "Your discipline tower is growing"
    }

    var subtitle: String {
        if store.goals.isEmpty {
            return "Create goals in Goals, then mark days in Calendar."
        }
        return "Full days add one block. Partial days add half."
    }

    var streakLabel: String {
        let dayLabel = currentStreak == 1 ? "day" : "days"
        return "\(currentStreak) \(dayLabel) in a row"
    }

    var milestoneMessage: String? {
        milestones.first(where: { currentStreak >= $0.days })?.message
    }

    private func rebuild() {
        let today = Date()
        guard let startDate = store.trackingStartDate(relativeTo: today) else {
            blocks = []
            currentStreak = 0
            return
        }

        let dates = DateUtils.days(from: startDate, through: today)

        var height = 0.0
        for date in dates {
            let delta = store.status(for: date).towerDelta
            height = max(0, height + delta)
        }

        blocks = makeBlocks(height: height)
        currentStreak = store.currentStreak(relativeTo: today)
    }

    private func makeBlocks(height: Double) -> [TowerBlock] {
        let fullCount = Int(height.rounded(.down))
        let hasHalfBlock = height - Double(fullCount) >= 0.5

        var result = (0..<fullCount).map { TowerBlock(id: $0, kind: .full) }
        if hasHalfBlock {
            result.append(TowerBlock(id: result.count, kind: .half))
        }
        return result
    }
}
