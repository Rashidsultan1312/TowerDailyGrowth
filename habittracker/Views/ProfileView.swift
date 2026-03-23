//
//  ProfileView.swift
//  habittracker
//
//  Created by OpenAI Codex on 21/3/26.
//

import SwiftUI

struct ProfileView: View {
    @StateObject private var viewModel: ProfileViewModel
    @State private var isPresentingImagePicker = false

    init(store: HabitStore) {
        _viewModel = StateObject(wrappedValue: ProfileViewModel(store: store))
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
                    avatarCard
                    statsCard
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
            }
        }
        .navigationTitle("Profile")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $isPresentingImagePicker) {
            ImagePickerView { image in
                guard let image else { return }
                viewModel.saveAvatar(image)
            }
        }
    }

    private var avatarCard: some View {
        FantasyCardView {
            VStack(spacing: 16) {
                avatarView

                VStack(spacing: 10) {
                    Button("Choose Avatar") {
                        isPresentingImagePicker = true
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(Color.white.opacity(0.08))
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))

                    if viewModel.avatarImage != nil {
                        Button("Remove Avatar", role: .destructive) {
                            viewModel.removeAvatar()
                        }
                        .font(.caption)
                    }
                }
            }
        }
    }

    private var avatarView: some View {
        Group {
            if let avatarImage = viewModel.avatarImage {
                Image(uiImage: avatarImage)
                    .resizable()
                    .scaledToFill()
            } else {
                Image(systemName: "person.crop.circle.fill")
                    .resizable()
                    .scaledToFit()
                    .padding(22)
                    .foregroundColor(.white.opacity(0.82))
            }
        }
        .frame(width: 112, height: 112)
        .background(Color.white.opacity(0.08))
        .clipShape(Circle())
        .overlay(
            Circle()
                .stroke(Theme.cardBorder, lineWidth: 1)
        )
    }

    private var statsCard: some View {
        let stats = viewModel.stats

        return FantasyCardView {
            VStack(alignment: .leading, spacing: 14) {
                Text("Usage")
                    .font(.headline)
                    .foregroundColor(.white)

                statRow(title: "Total tracked days", value: "\(stats.totalTrackedDays)")
                statRow(title: "Completed days", value: "\(stats.completedDays)")
                statRow(title: "Partially completed days", value: "\(stats.partialDays)")
                statRow(title: "Failed days", value: "\(stats.failedDays)")
                statRow(title: "Current streak", value: "\(stats.currentStreak)")
                statRow(title: "Longest streak", value: "\(stats.longestStreak)")
            }
        }
    }

    private func statRow(title: String, value: String) -> some View {
        HStack {
            Text(title)
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.72))

            Spacer()

            Text(value)
                .font(.headline)
                .foregroundColor(.white)
        }
    }
}

#Preview {
    NavigationView {
        ProfileView(store: HabitStore.preview)
    }
}
