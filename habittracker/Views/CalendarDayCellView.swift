//
//  CalendarDayCellView.swift
//  habittracker
//
//  Created by Oleg Yakushin on 13/3/26.
//

import SwiftUI

struct CalendarDayCellView: View {
    let date: Date
    let completion: DayCompletion
    let isToday: Bool

    var body: some View {
        let dayNumber = Calendar.current.component(.day, from: date)
        let fillColor = dayColor

        VStack(spacing: 6) {
            Text("\(dayNumber)")
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(.white)

            if completion.marked > 0 {
                Text("\(completion.completed)/\(completion.total)")
                    .font(.caption2)
                    .foregroundColor(.white.opacity(0.7))
            }
        }
        .frame(maxWidth: .infinity, minHeight: 60)
        .padding(.vertical, 6)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(fillColor)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(isToday ? Color.white.opacity(0.7) : Theme.cardBorder, lineWidth: isToday ? 1.2 : 0.6)
        )
        .shadow(color: Color.black.opacity(0.2), radius: 4, x: 0, y: 2)
    }

    private var dayColor: Color {
        let status = completion.status(for: date)

        if status == .neutral || completion.total == 0 {
            return Theme.neutral
        }

        // Interpolate from red to green based on completion percentage.
        let start = UIColor(red: 0.74, green: 0.22, blue: 0.22, alpha: 1)
        let end = UIColor(red: 0.22, green: 0.7, blue: 0.45, alpha: 1)
        return Color.blend(from: start, to: end, fraction: completion.percent)
    }
}

#Preview {
    CalendarDayCellView(
        date: Date(),
        completion: DayCompletion(percent: 0.5, completed: 2, total: 4, marked: 3),
        isToday: true
    )
    .padding()
    .background(Theme.backgroundTop)
}
