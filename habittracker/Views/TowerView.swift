//
//  TowerView.swift
//  habittracker
//
//  Created by Oleg Yakushin on 13/3/26.
//

import SwiftUI

struct TowerView: View {
    let blocks: [TowerBlock]

    var body: some View {
        ZStack(alignment: .bottom) {
            base

            VStack(spacing: 8) {
                ForEach(blocks.reversed()) { block in
                    TowerBlockView(kind: block.kind)
                        .transition(
                            .asymmetric(
                                insertion: .scale(scale: 0.7, anchor: .bottom).combined(with: .opacity),
                                removal: .move(edge: .bottom).combined(with: .opacity)
                            )
                        )
                }
            }
            .padding(.bottom, 18)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
        .animation(.spring(response: 0.5, dampingFraction: 0.82), value: blocks)
    }

    private var base: some View {
        RoundedRectangle(cornerRadius: 14, style: .continuous)
            .fill(Theme.card.opacity(0.95))
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(Theme.cardBorder, lineWidth: 0.8)
            )
            .frame(width: 168, height: 18)
            .shadow(color: Color.black.opacity(0.25), radius: 10, x: 0, y: 6)
    }
}

private struct TowerBlockView: View {
    let kind: TowerBlock.Kind

    var body: some View {
        RoundedRectangle(cornerRadius: 12, style: .continuous)
            .fill(blockFill)
            .overlay(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .stroke(Color.white.opacity(0.08), lineWidth: 0.8)
            )
            .frame(width: 132, height: blockHeight)
            .shadow(color: Color.black.opacity(0.18), radius: 6, x: 0, y: 3)
    }

    private var blockHeight: CGFloat {
        kind == .full ? 32 : 18
    }

    private var blockFill: LinearGradient {
        let topColor = Theme.accent.opacity(kind == .full ? 0.95 : 0.72)
        return LinearGradient(
            colors: [topColor, Theme.card.opacity(0.92)],
            startPoint: .top,
            endPoint: .bottom
        )
    }
}

#Preview {
    TowerView(
        blocks: [
            TowerBlock(id: 0, kind: .full),
            TowerBlock(id: 1, kind: .full),
            TowerBlock(id: 2, kind: .half)
        ]
    )
    .padding()
    .frame(height: 320)
    .background(Theme.backgroundTop)
}
