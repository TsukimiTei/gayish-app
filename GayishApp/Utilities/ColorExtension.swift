//
//  ColorExtension.swift
//  Gayish
//
//  Created on 2026-01-13.
//

import SwiftUI

extension Color {
    /// 从十六进制字符串初始化颜色
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
    
    // MARK: - 预定义配色方案
    
    /// 低分区配色 (1-3分)
    static let lowScoreColor = Color(hex: "4A90E2")
    
    /// 中分区配色 (4-6分)
    static let midScoreColor = Color(hex: "9B59B6")
    
    /// 高分区配色 (7-10分)
    static let highScoreStart = Color(hex: "E91E63")
    static let highScoreEnd = Color(hex: "9C27B0")
    
    /// 根据分数获取渐变色
    static func gradientForScore(_ score: Int) -> LinearGradient {
        switch score {
        case 1...3:
            return LinearGradient(
                colors: [lowScoreColor, lowScoreColor.opacity(0.7)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case 4...6:
            return LinearGradient(
                colors: [midScoreColor, midScoreColor.opacity(0.8)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case 7...10:
            return LinearGradient(
                colors: [highScoreStart, highScoreEnd],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        default:
            return LinearGradient(
                colors: [Color.gray, Color.gray],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }
}
