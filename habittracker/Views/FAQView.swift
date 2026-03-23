//
//  FAQView.swift
//  habittracker
//
//  Created by OpenAI Codex on 21/3/26.
//

import SwiftUI

struct FAQView: View {
    private let items: [FAQItem] = [
        FAQItem(
            question: "What is this app for?",
            answer: "This app helps you track daily goals and build consistency through simple check-ins."
        ),
        FAQItem(
            question: "How does the tower work?",
            answer: "Your tower grows when you complete days successfully and reflects your streak visually."
        ),
        FAQItem(
            question: "Why do some days turn red automatically?",
            answer: "If a day ends and no goals were marked, it is treated as a failed day."
        ),
        FAQItem(
            question: "Can I change my goals later?",
            answer: "Yes, goals can be added, edited, and removed in the Goals section."
        )
    ]

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
                            ForEach(Array(items.enumerated()), id: \.offset) { index, item in
                                DisclosureGroup {
                                    Text(item.answer)
                                        .font(.subheadline)
                                        .foregroundColor(.white.opacity(0.72))
                                        .padding(.top, 6)
                                } label: {
                                    Text(item.question)
                                        .font(.headline)
                                        .foregroundColor(.white)
                                }

                                if index < items.count - 1 {
                                    Divider()
                                        .overlay(Color.white.opacity(0.08))
                                }
                            }
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
            }
        }
        .navigationTitle("FAQ")
        .navigationBarTitleDisplayMode(.inline)
    }
}

private struct FAQItem {
    let question: String
    let answer: String
}

#Preview {
    NavigationView {
        FAQView()
    }
}
