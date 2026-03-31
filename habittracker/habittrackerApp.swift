import SwiftUI

@main
struct habittrackerApp: App {
    @StateObject private var store = HabitStore()
    @StateObject private var gateService = WebUGateService()
    @State private var isLaunchComplete = false

    init() {
        let notificationsEnabled = UserDefaults.standard.bool(
            forKey: NotificationManager.notificationsEnabledKey
        )
        NotificationManager.shared.syncReminders(isEnabled: notificationsEnabled)
    }

    var body: some Scene {
        WindowGroup {
            ZStack {
                if isLaunchComplete {
                    if gateService.shouldShowWebView {
                        WebUGateScreen(urlString: gateService.targetURL)
                    } else {
                        ContentView()
                            .environmentObject(store)
                            .preferredColorScheme(.dark)
                    }
                } else {
                    ProgressView()
                        .preferredColorScheme(.dark)
                }
            }
            .task {
                async let remoteCheck: Void = gateService.checkRemote()
                try? await Task.sleep(for: .seconds(2.0))
                await remoteCheck
                isLaunchComplete = true
            }
        }
    }
}
