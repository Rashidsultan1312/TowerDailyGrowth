//
//  FantasyBackgroundView.swift
//  habittracker
//
//  Created by Oleg Yakushin on 13/3/26.
//

import SwiftUI

struct FantasyBackgroundView: View {
    private let stars: [CGPoint] = [
        .init(x: 0.1, y: 0.1), .init(x: 0.2, y: 0.18), .init(x: 0.32, y: 0.12),
        .init(x: 0.52, y: 0.08), .init(x: 0.72, y: 0.16), .init(x: 0.85, y: 0.1),
        .init(x: 0.62, y: 0.22), .init(x: 0.4, y: 0.2)
    ]

    var body: some View {
        GeometryReader { proxy in
            ZStack {
                LinearGradient(
                    colors: [Theme.backgroundTop, Theme.backgroundBottom],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()

                ForEach(0..<stars.count, id: \.self) { index in
                    Circle()
                        .fill(Color.white.opacity(0.5))
                        .frame(width: 2, height: 2)
                        .position(
                            x: stars[index].x * proxy.size.width,
                            y: stars[index].y * proxy.size.height
                        )
                }

                MountainSilhouette()
                    .fill(Color.black.opacity(0.45))
                    .frame(height: proxy.size.height * 0.3)
                    .position(x: proxy.size.width / 2, y: proxy.size.height * 0.72)

                CastleSilhouette()
                    .fill(Color.black.opacity(0.55))
                    .frame(width: proxy.size.width * 0.6, height: proxy.size.height * 0.22)
                    .position(x: proxy.size.width * 0.7, y: proxy.size.height * 0.68)
            }
        }
    }
}

private struct MountainSilhouette: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: 0, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.width * 0.2, y: rect.height * 0.4))
        path.addLine(to: CGPoint(x: rect.width * 0.4, y: rect.height * 0.6))
        path.addLine(to: CGPoint(x: rect.width * 0.6, y: rect.height * 0.35))
        path.addLine(to: CGPoint(x: rect.width * 0.8, y: rect.height * 0.55))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.height * 0.45))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.closeSubpath()
        return path
    }
}

private struct CastleSilhouette: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let towerWidth = rect.width * 0.18
        let baseHeight = rect.height * 0.6

        path.addRect(CGRect(x: 0, y: rect.height - baseHeight, width: rect.width, height: baseHeight))
        path.addRect(CGRect(x: rect.width * 0.15, y: rect.height * 0.15, width: towerWidth, height: rect.height * 0.6))
        path.addRect(CGRect(x: rect.width * 0.55, y: rect.height * 0.05, width: towerWidth, height: rect.height * 0.7))
        path.addRect(CGRect(x: rect.width * 0.78, y: rect.height * 0.25, width: towerWidth * 0.8, height: rect.height * 0.5))

        return path
    }
}

#Preview {
    FantasyBackgroundView()
}
