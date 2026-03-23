//
//  ContentView.swift
//  habittracker
//
//  Created by Oleg Yakushin on 13/3/26.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var store: HabitStore
    @AppStorage("has_seen_onboarding") private var hasSeenOnboarding = false

    var body: some View {
        Group {
            if hasSeenOnboarding {
                RootTabView(store: store)
            } else {
                OnboardingView {
                    hasSeenOnboarding = true
                }
            }
        }
        .tint(Theme.accent)
    }
}

#Preview {
    ContentView()
        .environmentObject(HabitStore.preview)
}

private struct RootTabView: View {
    let store: HabitStore
    @State private var selectedTab: RootTab = .progress

    var body: some View {
        TabView(selection: $selectedTab) {
            tabNavigationView {
                ProgressView(store: store)
            }
            .tabItem {
                Label("Progress", systemImage: "square.stack.3d.up")
            }
            .tag(RootTab.progress)

            tabNavigationView {
                CalendarView(store: store)
            }
            .tabItem {
                Label("Calendar", systemImage: "calendar")
            }
            .tag(RootTab.calendar)

            tabNavigationView {
                GoalsEditView(store: store)
            }
            .tabItem {
                Label("Goals", systemImage: "checklist")
            }
            .tag(RootTab.goals)

            tabNavigationView {
                ProfileView(store: store)
            }
            .tabItem {
                Label("Profile", systemImage: "person.crop.circle")
            }
            .tag(RootTab.profile)

            tabNavigationView {
                SettingsView(store: store)
            }
            .tabItem {
                Label("Settings", systemImage: "gearshape")
            }
            .tag(RootTab.settings)
        }
    }

    private func tabNavigationView<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        NavigationView {
            content()
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

private enum RootTab {
    case progress
    case calendar
    case goals
    case profile
    case settings
}
