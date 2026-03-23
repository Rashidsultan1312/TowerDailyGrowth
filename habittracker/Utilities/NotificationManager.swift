//
//  NotificationManager.swift
//  habittracker
//
//  Created by Oleg Yakushin on 13/3/26.
//

import Foundation
import UserNotifications

final class NotificationManager {
    static let shared = NotificationManager()
    static let notificationsEnabledKey = "notifications_enabled"

    private let center = UNUserNotificationCenter.current()
    private let reminderIdentifiersPrefix = "habit_reminder_"
    private let scheduleWindow = 30

    private let reminderHour = 20
    private let reminderMinute = 0

    let reminderTexts = [
        "How did your day go? Don't forget to mark your goals.",
        "Your day is almost over - update your progress.",
        "A small check-in today keeps your streak alive.",
        "Don't leave today empty - mark your goals.",
        "Your tower grows one day at a time.",
        "Take a moment to record today's progress.",
        "A quick update now keeps your routine clear.",
        "Check in before the day ends.",
        "Your daily ritual is waiting for one last tap.",
        "Mark today so tomorrow starts clean."
    ]

    func requestAuthorization(completion: @escaping (Bool) -> Void) {
        center.requestAuthorization(options: [.alert, .badge, .sound]) { granted, _ in
            DispatchQueue.main.async {
                completion(granted)
            }
        }
    }

    func authorizationStatus(completion: @escaping (UNAuthorizationStatus) -> Void) {
        center.getNotificationSettings { settings in
            DispatchQueue.main.async {
                completion(settings.authorizationStatus)
            }
        }
    }

    func syncReminders(isEnabled: Bool) {
        authorizationStatus { [weak self] status in
            guard let self else { return }
            let isAuthorized = status == .authorized || status == .provisional || status == .ephemeral

            if isEnabled && isAuthorized {
                self.scheduleEveningReminders()
            } else {
                self.removeAllReminders()
            }
        }
    }

    func scheduleEveningReminders(daysAhead: Int? = nil) {
        // A rolling schedule keeps the reminder daily while still allowing random copy.
        removeAllReminders()

        let daysAhead = daysAhead ?? scheduleWindow

        let calendar = Calendar.current
        let now = Date()

        for offset in 0..<daysAhead {
            guard let date = calendar.date(byAdding: .day, value: offset, to: now) else { continue }
            var components = calendar.dateComponents([.year, .month, .day], from: date)
            components.hour = reminderHour
            components.minute = reminderMinute

            let content = UNMutableNotificationContent()
            content.title = "Evening Check-in"
            content.body = reminderTexts.randomElement() ?? "Time to mark your habits."
            content.sound = .default

            let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
            let request = UNNotificationRequest(
                identifier: "\(reminderIdentifiersPrefix)\(offset)",
                content: content,
                trigger: trigger
            )

            center.add(request)
        }
    }

    func removeAllReminders() {
        let identifiers = (0..<scheduleWindow).map { "\(reminderIdentifiersPrefix)\($0)" }
        center.removePendingNotificationRequests(withIdentifiers: identifiers)
    }
}
