//
//  ProgressView.swift
//  habittracker
//
//  Created by Oleg Yakushin on 13/3/26.
//

import SwiftUI

struct ProgressView: View {
    @StateObject private var viewModel: ProgressViewModel
    private let store: HabitStore

    init(store: HabitStore) {
        self.store = store
        _viewModel = StateObject(wrappedValue: ProgressViewModel(store: store))
    }

    var body: some View {
        ZStack {
            FantasyBackgroundView()

            VStack(spacing: 16) {
                header
                towerCard
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
                Text("Progress")
                    .font(.title)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                Text("A simple view of your consistency")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.7))
            }

            Spacer()

           
        }
        .padding(.top, 10)
    }

    private var towerCard: some View {
        FantasyCardView {
            VStack(alignment: .leading, spacing: 16) {
                VStack(alignment: .leading, spacing: 6) {
                    Text(viewModel.title)
                        .font(.headline)
                        .foregroundColor(.white)

                    Text(viewModel.subtitle)
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.68))
                }

                VStack(alignment: .leading, spacing: 4) {
                    if let milestoneMessage = viewModel.milestoneMessage {
                        Text(milestoneMessage)
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(Theme.accent)
                            .transition(.move(edge: .top).combined(with: .opacity))
                    }

                    Text(viewModel.streakLabel)
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.72))
                }
                .animation(.easeInOut(duration: 0.25), value: viewModel.milestoneMessage)
                .animation(.easeInOut(duration: 0.25), value: viewModel.currentStreak)

                TowerView(blocks: viewModel.blocks)
                    .frame(height: 420)

                if store.goals.isEmpty {
                    Text("Add goals in the Goals tab to begin building the tower.")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.6))
                }
            }
        }
    }

    private func headerIcon(systemName: String) -> some View {
        Image(systemName: systemName)
            .foregroundColor(.white)
            .padding(10)
            .background(Theme.card)
            .clipShape(Circle())
            .overlay(Circle().stroke(Theme.cardBorder, lineWidth: 0.8))
    }
}

#Preview {
    NavigationView {
        ProgressView(store: HabitStore.preview)
    }
}
