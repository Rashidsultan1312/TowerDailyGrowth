//
//  OnboardingView.swift
//  habittracker
//
//  Created by Oleg Yakushin on 13/3/26.
//

import SwiftUI

struct OnboardingView: View {
    let onFinish: () -> Void

    @State private var currentPage = 0
    @State private var isRequestingNotifications = false

    private let pages: [OnboardingPage] = [
        OnboardingPage(
            symbolName: "target",
            title: "Track Daily Discipline",
            message: "This app helps you check in on your goals each day and build consistency over time."
        ),
        OnboardingPage(
            symbolName: "building.2",
            title: "Grow Your Tower",
            message: "The Progress screen turns completed days into blocks so your routine becomes visible."
        ),
        OnboardingPage(
            symbolName: "calendar",
            title: "Review Each Day",
            message: "Use the Calendar to mark days as completed, partial, or failed. Daily check-ins keep the system honest."
        ),
        OnboardingPage(
            symbolName: "bell",
            title: "Keep the Ritual",
            message: "Optional evening reminders help you close the day and keep your streak moving."
        )
    ]

    var body: some View {
        ZStack {
            FantasyBackgroundView()

            VStack(spacing: 18) {
                TabView(selection: $currentPage) {
                    ForEach(Array(pages.enumerated()), id: \.offset) { index, page in
                        pageCard(page)
                            .tag(index)
                    }
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
                .indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .interactive))

                actionButton
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 24)
        }
    }

    private func pageCard(_ page: OnboardingPage) -> some View {
        FantasyCardView {
            VStack(alignment: .leading, spacing: 18) {
                Spacer(minLength: 0)

                Image(systemName: page.symbolName)
                    .font(.system(size: 42, weight: .medium))
                    .foregroundColor(Theme.accent)

                VStack(alignment: .leading, spacing: 10) {
                    Text(page.title)
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)

                    Text(page.message)
                        .font(.body)
                        .foregroundColor(.white.opacity(0.72))
                }

                Spacer(minLength: 0)
            }
            .frame(maxWidth: .infinity, minHeight: 360, alignment: .leading)
        }
    }

    private var actionButton: some View {
        Button(action: advance) {
            Text(currentPage == pages.count - 1 ? "Allow Notifications & Start" : "Next")
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(Theme.card)
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(Theme.cardBorder, lineWidth: 0.8)
                )
        }
        .disabled(isRequestingNotifications)
    }

    private func advance() {
        if currentPage == pages.count - 1 {
            requestNotificationsAndFinish()
        } else {
            withAnimation(.easeInOut(duration: 0.25)) {
                currentPage += 1
            }
        }
    }

    private func requestNotificationsAndFinish() {
        guard !isRequestingNotifications else { return }
        isRequestingNotifications = true

        NotificationManager.shared.authorizationStatus { status in
            switch status {
            case .authorized, .provisional, .ephemeral:
                UserDefaults.standard.set(true, forKey: NotificationManager.notificationsEnabledKey)
                NotificationManager.shared.scheduleEveningReminders()
                completeOnboarding()
            case .notDetermined:
                NotificationManager.shared.requestAuthorization { granted in
                    UserDefaults.standard.set(granted, forKey: NotificationManager.notificationsEnabledKey)
                    if granted {
                        NotificationManager.shared.scheduleEveningReminders()
                    }
                    completeOnboarding()
                }
            case .denied:
                UserDefaults.standard.set(false, forKey: NotificationManager.notificationsEnabledKey)
                completeOnboarding()
            @unknown default:
                UserDefaults.standard.set(false, forKey: NotificationManager.notificationsEnabledKey)
                completeOnboarding()
            }
        }
    }

    private func completeOnboarding() {
        isRequestingNotifications = false
        onFinish()
    }
}

private struct OnboardingPage {
    let symbolName: String
    let title: String
    let message: String
}

#Preview {
    OnboardingView(onFinish: {})
}
