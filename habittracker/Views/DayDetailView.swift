//
//  DayDetailView.swift
//  habittracker
//
//  Created by Oleg Yakushin on 13/3/26.
//

import SwiftUI

struct DayDetailView: View {
    @StateObject private var viewModel: DayViewModel

    init(date: Date, store: HabitStore) {
        _viewModel = StateObject(wrappedValue: DayViewModel(date: date, store: store))
    }

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Theme.backgroundTop, Theme.backgroundBottom],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 16) {
                    headerCard
                    goalsCard
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
            }
        }
        .navigationTitle(dateTitle)
        .navigationBarTitleDisplayMode(.inline)
    }

    private var headerCard: some View {
        let completion = viewModel.completion()
        let percent = completion.total == 0 ? 0 : Int((completion.percent * 100).rounded())

        return FantasyCardView {
            VStack(alignment: .leading, spacing: 8) {
                Text(dateTitle)
                    .font(.headline)
                    .foregroundColor(.white)

                Text("\(completion.completed) of \(completion.total) goals completed")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.7))

                Text("Tap a goal to cycle: Completed → Not completed → Neutral.")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.6))

                HStack(spacing: 10) {
                    SwiftUI.ProgressView(value: completion.percent)
                        .tint(Theme.accent)
                    Text("\(percent)%")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                }
            }
        }
    }

    private var goalsCard: some View {
        FantasyCardView {
            if viewModel.goals.isEmpty {
                VStack(alignment: .leading, spacing: 6) {
                    Text("No goals yet")
                        .font(.headline)
                        .foregroundColor(.white)
                    Text("Add a goal in the Goals tab to start tracking.")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.7))
                }
            } else {
                VStack(spacing: 12) {
                    ForEach(viewModel.goals) { goal in
                        GoalRowView(
                            goal: goal,
                            state: viewModel.state(for: goal),
                            isActive: viewModel.isGoalActive(goal),
                            inactiveLabel: viewModel.inactiveLabel(for: goal),
                            onTap: {
                                viewModel.toggle(goal: goal)
                            }
                        )
                    }
                }
            }
        }
    }

    private var dateTitle: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        return formatter.string(from: viewModel.date)
    }
}

#Preview {
    NavigationView {
        DayDetailView(date: Date(), store: HabitStore.preview)
    }
}
