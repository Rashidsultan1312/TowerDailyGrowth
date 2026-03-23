//
//  Color+Blend.swift
//  habittracker
//
//  Created by Oleg Yakushin on 13/3/26.
//

import SwiftUI
import UIKit

extension Color {
    static func blend(from: UIColor, to: UIColor, fraction: Double) -> Color {
        let clamped = max(0, min(1, fraction))
        var r1: CGFloat = 0
        var g1: CGFloat = 0
        var b1: CGFloat = 0
        var a1: CGFloat = 0
        var r2: CGFloat = 0
        var g2: CGFloat = 0
        var b2: CGFloat = 0
        var a2: CGFloat = 0

        from.getRed(&r1, green: &g1, blue: &b1, alpha: &a1)
        to.getRed(&r2, green: &g2, blue: &b2, alpha: &a2)

        let r = r1 + (r2 - r1) * CGFloat(clamped)
        let g = g1 + (g2 - g1) * CGFloat(clamped)
        let b = b1 + (b2 - b1) * CGFloat(clamped)
        let a = a1 + (a2 - a1) * CGFloat(clamped)

        return Color(red: Double(r), green: Double(g), blue: Double(b), opacity: Double(a))
    }
}
