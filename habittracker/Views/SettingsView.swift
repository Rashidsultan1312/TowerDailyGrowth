//
//  SettingsView.swift
//  habittracker
//
//  Created by Oleg Yakushin on 13/3/26.
//

import SwiftUI
import UIKit
import UserNotifications

struct SettingsView: View {
    @Environment(\.openURL) private var openURL

    @State private var notificationsEnabled: Bool = UserDefaults.standard.bool(forKey: NotificationManager.notificationsEnabledKey)
    @State private var authorizationStatus: UNAuthorizationStatus = .notDetermined
    @State private var showingPermissionNote = false

    init(store: HabitStore) {
        _ = store
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
                    FantasyCardView {
                        VStack(alignment: .leading, spacing: 12) {
                            settingsNavigationRow(
                                title: "Localization",
                                destination: LocalizationView()
                            )

                            Divider()
                                .overlay(Color.white.opacity(0.08))

                            settingsNavigationRow(
                                title: "FAQ",
                                destination: FAQView()
                            )
                        }
                    }

                    FantasyCardView {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Reminders")
                                .font(.headline)
                                .foregroundColor(.white)

                            Toggle("Evening check-in", isOn: $notificationsEnabled)
                                .toggleStyle(SwitchToggleStyle(tint: Theme.accent))
                                .foregroundColor(.white)

                            Text(notificationStatusText)
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.6))

                            if authorizationStatus == .notDetermined {
                                permissionButton(title: "Allow Notifications", action: requestNotificationPermission)
                            } else if authorizationStatus == .denied {
                                permissionButton(title: "Open System Settings", action: openSystemSettings)
                            }
                        }
                    }

                    FantasyCardView {
                        VStack(alignment: .leading, spacing: 12) {

                            LinkRow(title: "Privacy Policy", url: LegalLinks.privacyPolicy)
                            LinkRow(title: "Terms of Use", url: LegalLinks.termsOfUse)
                        }
                    }

              
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
            }
        }
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            refreshNotificationState()
            NotificationManager.shared.syncReminders(isEnabled: notificationsEnabled)
        }
        .onChange(of: notificationsEnabled) { value in
            handleNotificationToggle(value)
        }
        .alert("Notifications Disabled", isPresented: $showingPermissionNote) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("Enable notifications in Settings to receive reminders.")
        }
    }

    private var notificationStatusText: String {
        switch authorizationStatus {
        case .authorized, .provisional, .ephemeral:
            return "Daily reminders are ready for the evening."
        case .denied:
            return "Notifications are disabled for this app."
        case .notDetermined:
            return "Allow notifications to get a daily evening reminder."
        @unknown default:
            return "Notification status is unavailable."
        }
    }

    private func permissionButton(title: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(.white)
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(Color.white.opacity(0.08))
                .clipShape(Capsule())
        }
    }

    private func settingsNavigationRow<Destination: View>(title: String, destination: Destination) -> some View {
        NavigationLink(destination: destination) {
            HStack {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.white)

                Spacer()

                Image(systemName: "chevron.right")
                    .foregroundColor(.white.opacity(0.6))
            }
        }
    }

    private func refreshNotificationState() {
        NotificationManager.shared.authorizationStatus { status in
            authorizationStatus = status
            let isAuthorized = isAuthorized(status)
            if !isAuthorized && notificationsEnabled {
                notificationsEnabled = false
                UserDefaults.standard.set(false, forKey: NotificationManager.notificationsEnabledKey)
            }
        }
    }

    private func handleNotificationToggle(_ isEnabled: Bool) {
        if isEnabled {
            switch authorizationStatus {
            case .authorized, .provisional, .ephemeral:
                UserDefaults.standard.set(true, forKey: NotificationManager.notificationsEnabledKey)
                NotificationManager.shared.scheduleEveningReminders()
            case .notDetermined:
                requestNotificationPermission()
            case .denied:
                notificationsEnabled = false
                UserDefaults.standard.set(false, forKey: NotificationManager.notificationsEnabledKey)
                showingPermissionNote = true
            @unknown default:
                notificationsEnabled = false
            }
        } else {
            UserDefaults.standard.set(false, forKey: NotificationManager.notificationsEnabledKey)
            NotificationManager.shared.removeAllReminders()
        }
    }

    private func requestNotificationPermission() {
        NotificationManager.shared.requestAuthorization { granted in
            refreshNotificationState()
            if granted {
                notificationsEnabled = true
                UserDefaults.standard.set(true, forKey: NotificationManager.notificationsEnabledKey)
                NotificationManager.shared.scheduleEveningReminders()
            } else {
                notificationsEnabled = false
                UserDefaults.standard.set(false, forKey: NotificationManager.notificationsEnabledKey)
                showingPermissionNote = true
            }
        }
    }

    private func openSystemSettings() {
        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
        openURL(url)
    }

    private func isAuthorized(_ status: UNAuthorizationStatus) -> Bool {
        status == .authorized || status == .provisional || status == .ephemeral
    }
}

#Preview {
    NavigationView {
        SettingsView(store: HabitStore.preview)
    }
}

private struct LinkRow: View {
    let title: String
    let url: URL

    var body: some View {
        Link(destination: url) {
            HStack {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.white)
                Spacer()
                Image(systemName: "arrow.up.right.square")
                    .foregroundColor(.white.opacity(0.6))
            }
        }
    }
}

private enum LegalLinks {
    static let privacyPolicy = URL(string: "https://sites.google.com/view/towerdailygrowthprivatpolicy/main")!
    static let termsOfUse = URL(string: "https://sites.google.com/view/towerdailygrowthterm/main?read_current=1")!
}
