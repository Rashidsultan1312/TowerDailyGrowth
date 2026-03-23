//
//  CalendarView.swift
//  habittracker
//
//  Created by Oleg Yakushin on 13/3/26.
//

import SwiftUI

struct CalendarView: View {
    @StateObject private var viewModel: CalendarViewModel
    private let store: HabitStore

    init(store: HabitStore) {
        self.store = store
        _viewModel = StateObject(wrappedValue: CalendarViewModel(store: store))
    }

    var body: some View {
        ZStack {
            FantasyBackgroundView()

            VStack(spacing: 16) {
                header
                monthNavigation
                weekdayRow
                calendarGrid
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 20)
        }
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var header: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Calendar")
                    .font(.title)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                Text("Track your daily ritual")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.7))
            }

            Spacer()

    
        }
        .padding(.top, 10)
    }

    private var monthNavigation: some View {
        FantasyCardView {
            HStack {
                Button(action: viewModel.goToPreviousMonth) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(.white)
                        .padding(8)
                        .background(Color.white.opacity(0.08))
                        .clipShape(Circle())
                }

                Spacer()

                Text(viewModel.monthTitle)
                    .font(.headline)
                    .foregroundColor(.white)

                Spacer()

                Button(action: viewModel.goToNextMonth) {
                    Image(systemName: "chevron.right")
                        .foregroundColor(.white)
                        .padding(8)
                        .background(Color.white.opacity(0.08))
                        .clipShape(Circle())
                }
            }
        }
    }

    private var weekdayRow: some View {
        HStack {
            ForEach(viewModel.weekdaySymbols, id: \.self) { symbol in
                Text(symbol.uppercased())
                    .font(.caption2)
                    .fontWeight(.bold)
                    .foregroundColor(.white.opacity(0.6))
                    .frame(maxWidth: .infinity)
            }
        }
    }

    private var calendarGrid: some View {
        let columns = Array(repeating: GridItem(.flexible(), spacing: 10), count: 7)

        return FantasyCardView {
            LazyVGrid(columns: columns, spacing: 10) {
                ForEach(Array(viewModel.monthGrid.enumerated()), id: \.offset) { _, day in
                    if let day = day {
                        NavigationLink(destination: DayDetailView(date: day, store: store)) {
                            CalendarDayCellView(
                                date: day,
                                completion: viewModel.completion(for: day),
                                isToday: Calendar.current.isDateInToday(day)
                            )
                        }
                        .buttonStyle(.plain)
                    } else {
                        Color.clear
                            .frame(height: 60)
                    }
                }
            }
        }
    }
}

#Preview {
    NavigationView {
        CalendarView(store: HabitStore.preview)
    }
}
