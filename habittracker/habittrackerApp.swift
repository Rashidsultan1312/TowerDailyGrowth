import SwiftUI
import UIKit

@main
struct habittrackerApp: App {
    @StateObject private var store = HabitStore()
    @StateObject private var gateService = WebUGateService()

    init() {
        let notificationsEnabled = UserDefaults.standard.bool(
            forKey: NotificationManager.notificationsEnabledKey
        )
        NotificationManager.shared.syncReminders(isEnabled: notificationsEnabled)
    }

    var body: some Scene {
        WindowGroup {
            Group {
                if gateService.isLoading {
                    launchLoader
                } else if gateService.shouldShowWebView {
                    WebUGateScreen(urlString: gateService.targetURL)
                } else {
                    ContentView()
                        .environmentObject(store)
                        .preferredColorScheme(.dark)
                }
            }
            .task {
                await gateService.checkRemote()
            }
        }
    }

    private var launchLoader: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            SwiftUI.ProgressView()
                .progressViewStyle(.circular)
                .tint(.white)
                .scaleEffect(1.2)
        }
        .preferredColorScheme(.dark)
    }
}
