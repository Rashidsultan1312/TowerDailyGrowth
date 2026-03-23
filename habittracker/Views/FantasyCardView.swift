//
//  FantasyCardView.swift
//  habittracker
//
//  Created by Oleg Yakushin on 13/3/26.
//

import SwiftUI

struct FantasyCardView<Content: View>: View {
    private let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        content
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(Theme.card)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(Theme.cardBorder, lineWidth: 0.8)
            )
    }
}

#Preview {
    FantasyCardView {
        VStack(alignment: .leading, spacing: 8) {
            Text("Card Title")
                .font(.headline)
                .foregroundColor(.white)
            Text("Dark fantasy card styling.")
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.7))
        }
    }
    .padding()
    .background(Theme.backgroundTop)
}
