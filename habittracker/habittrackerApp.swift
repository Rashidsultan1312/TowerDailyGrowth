//
//  habittrackerApp.swift
//  habittracker
//
//  Created by Oleg Yakushin on 13/3/26.
//

import SwiftUI

@main
struct habittrackerApp: App {
    @StateObject private var store = HabitStore()

    init() {
        let notificationsEnabled = UserDefaults.standard.bool(forKey: NotificationManager.notificationsEnabledKey)
        NotificationManager.shared.syncReminders(isEnabled: notificationsEnabled)
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(store)
                .preferredColorScheme(.dark)
        }
    }
}
