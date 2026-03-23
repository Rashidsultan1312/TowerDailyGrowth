//
//  GoalsEditView.swift
//  habittracker
//
//  Created by Oleg Yakushin on 13/3/26.
//

import SwiftUI

struct GoalsEditView: View {
    @StateObject private var viewModel: GoalsViewModel
    @State private var isPresentingNew = false
    @State private var editingGoal: Goal?

    init(store: HabitStore) {
        _viewModel = StateObject(wrappedValue: GoalsViewModel(store: store))
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
                    header

                    VStack(spacing: 12) {
                        if viewModel.goals.isEmpty {
                            FantasyCardView {
                                VStack(alignment: .leading, spacing: 6) {
                                    Text("No goals yet")
                                        .font(.headline)
                                        .foregroundColor(.white)
                                    Text("Add your first goal to start tracking.")
                                        .font(.subheadline)
                                        .foregroundColor(.white.opacity(0.7))
                                }
                            }
                        } else {
                            ForEach(viewModel.goals) { goal in
                                FantasyCardView {
                                    VStack(alignment: .leading, spacing: 10) {
                                        HStack {
                                            Text(goal.name)
                                                .font(.headline)
                                                .foregroundColor(.white)

                                            Spacer()

                                            Button("Edit") {
                                                editingGoal = goal
                                            }
                                            .font(.caption)
                                            .foregroundColor(.white.opacity(0.8))
                                        }

                                        Text(weekdaySummary(for: goal))
                                            .font(.caption)
                                            .foregroundColor(.white.opacity(0.6))

                                        Text(startDateSummary(for: goal))
                                            .font(.caption)
                                            .foregroundColor(.white.opacity(0.6))

                                        Button(role: .destructive) {
                                            viewModel.deleteGoal(goal)
                                        } label: {
                                            Text("Delete")
                                                .font(.caption)
                                        }
                                    }
                                }
                            }
                        }
                    }

                    Button(action: { isPresentingNew = true }) {
                        HStack {
                            Image(systemName: "plus")
                            Text("Add Goal")
                        }
                        .font(.subheadline)
                       
                        .foregroundColor(.white)
                        .padding(.horizontal, 18)
                        .padding(.vertical, 10)
                        .background(Color.white.opacity(0.1))
                        .clipShape(Capsule())
                    }

                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
            }
        }
        .navigationTitle("Goals")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $isPresentingNew) {
            GoalEditorView(
                goal: Goal(name: ""),
                isNew: true,
                onSave: { goal in
                    viewModel.addGoal(
                        name: goal.name,
                        disabledWeekdays: goal.disabledWeekdays,
                        startDate: goal.startDate
                    )
                }
            )
        }
        .sheet(item: $editingGoal) { goal in
            GoalEditorView(
                goal: goal,
                isNew: false,
                onSave: { updated in
                    viewModel.updateGoal(updated)
                }
            )
        }
    }

    private var header: some View {
        FantasyCardView {
            VStack(alignment: .leading, spacing: 8) {
                Text("Goals Library")
                    .font(.headline)
                    .foregroundColor(.white)
                Text("Edit names, start dates, and disable specific weekdays.")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.7))
            }
        }
    }

    private func startDateSummary(for goal: Goal) -> String {
        "Counts from \(DateUtils.mediumDateString(for: goal.startDate))"
    }

    private func weekdaySummary(for goal: Goal) -> String {
        if goal.disabledWeekdays.isEmpty {
            return "Active every day"
        }
        let order = DateUtils.weekdayOrder()
        let sorted = order.filter { goal.disabledWeekdays.contains($0) }
        let names = sorted.map { DateUtils.weekdaySymbol(for: $0) }
        return "Disabled: \(names.joined(separator: ", "))"
    }
}

private struct GoalEditorView: View {
    @Environment(\.dismiss) private var dismiss

    let goal: Goal
    let isNew: Bool
    let onSave: (Goal) -> Void

    @State private var name: String
    @State private var disabledWeekdays: Set<Int>
    @State private var startDate: Date

    init(goal: Goal, isNew: Bool, onSave: @escaping (Goal) -> Void) {
        self.goal = goal
        self.isNew = isNew
        self.onSave = onSave
        _name = State(initialValue: goal.name)
        _disabledWeekdays = State(initialValue: goal.disabledWeekdays)
        _startDate = State(initialValue: goal.startDate)
    }

    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient(
                    colors: [Theme.backgroundTop, Theme.backgroundBottom],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()

                VStack(spacing: 16) {
                    FantasyCardView {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Goal Name")
                                .font(.headline)
                                .foregroundColor(.white)

                            TextField("Enter goal name", text: $name)
                                .textInputAutocapitalization(.words)
                                .padding(10)
                                .background(Color.white.opacity(0.08))
                                .cornerRadius(10)
                                .foregroundColor(.white)

                            Divider()
                                .overlay(Color.white.opacity(0.08))

                            DatePicker("Count From", selection: $startDate, displayedComponents: .date)
                                .foregroundColor(.white.opacity(0.85))
                                .tint(Theme.accent)
                        }
                    }

                    FantasyCardView {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Disable Weekdays")
                                .font(.headline)
                                .foregroundColor(.white)

                            WeekdayPicker(disabledWeekdays: $disabledWeekdays)
                        }
                    }

                    Spacer()
                }
                .padding(16)
            }
            .navigationTitle(isNew ? "New Goal" : "Edit Goal")
            
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        var updated = goal
                        updated.name = name.trimmingCharacters(in: .whitespacesAndNewlines)
                        updated.disabledWeekdays = disabledWeekdays
                        updated.startDate = startDate
                        onSave(updated)
                        dismiss()
                    }
                    .disabled(name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }
}

private struct WeekdayPicker: View {
    @Binding var disabledWeekdays: Set<Int>

    private let order = DateUtils.weekdayOrder()

    var body: some View {
        VStack(spacing: 8) {
            ForEach(order, id: \.self) { weekday in
                let isDisabled = disabledWeekdays.contains(weekday)

                Button(action: {
                    if isDisabled {
                        disabledWeekdays.remove(weekday)
                    } else {
                        disabledWeekdays.insert(weekday)
                    }
                }) {
                    HStack {
                        Text(DateUtils.weekdaySymbol(for: weekday))
                            .font(.subheadline)
                            .foregroundColor(.white)

                        Spacer()

                        Image(systemName: isDisabled ? "slash.circle.fill" : "checkmark.circle")
                            .foregroundColor(isDisabled ? .red.opacity(0.8) : .green.opacity(0.8))
                    }
                    .padding(10)
                    .background(Color.white.opacity(0.05))
                    .cornerRadius(10)
                }
            }
        }
    }
}

#Preview {
    NavigationView {
        GoalsEditView(store: HabitStore.preview)
    }
}
