//
//  GoalRowView.swift
//  habittracker
//
//  Created by Oleg Yakushin on 13/3/26.
//

import SwiftUI

struct GoalRowView: View {
    let goal: Goal
    let state: GoalState
    let isActive: Bool
    let inactiveLabel: String?
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                Circle()
                    .fill(stateColor)
                    .frame(width: 12, height: 12)

                VStack(alignment: .leading, spacing: 4) {
                    Text(goal.name)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)

                    Text(stateLabel)
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                }

                Spacer()

                Image(systemName: "arrow.2.circlepath")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.5))
            }
            .padding(12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(Color.black.opacity(0.25))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(Color.white.opacity(0.08), lineWidth: 0.8)
            )
        }
        .buttonStyle(.plain)
        .disabled(!isActive)
        .opacity(isActive ? 1 : 0.5)
    }

    private var stateColor: Color {
        guard isActive else { return Color.white.opacity(0.3) }
        switch state {
        case .neutral:
            return Color.white.opacity(0.3)
        case .completed:
            return Color.green.opacity(0.8)
        case .notCompleted:
            return Color.red.opacity(0.8)
        }
    }

    private var stateLabel: String {
        guard isActive else { return inactiveLabel ?? "Inactive today" }
        switch state {
        case .neutral:
            return "Neutral"
        case .completed:
            return "Completed"
        case .notCompleted:
            return "Not completed"
        }
    }
}

#Preview {
    GoalRowView(
        goal: Goal(name: "Potion Brewing"),
        state: .completed,
        isActive: true,
        inactiveLabel: nil,
        onTap: {}
    )
    .padding()
    .background(Theme.backgroundTop)
}
