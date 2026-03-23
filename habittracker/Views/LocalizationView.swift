//
//  LocalizationView.swift
//  habittracker
//
//  Created by OpenAI Codex on 21/3/26.
//

import SwiftUI

struct LocalizationView: View {
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
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Localization")
                                .font(.headline)
                                .foregroundColor(.white)

                            Text("English is currently the only available language.")
                                .font(.subheadline)
                                .foregroundColor(.white.opacity(0.7))
                        }
                    }

                    FantasyCardView {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("English")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                Text("Current language")
                                    .font(.caption)
                                    .foregroundColor(.white.opacity(0.6))
                            }

                            Spacer()

                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(Theme.accent)
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
            }
        }
        .navigationTitle("Localization")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationView {
        LocalizationView()
    }
}
