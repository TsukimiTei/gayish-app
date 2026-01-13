//
//  AnalyzingView.swift
//  Gayish
//
//  Created on 2026-01-13.
//

import SwiftUI

/// 分析中视图
struct AnalyzingView: View {
    @State private var progress: CGFloat = 0.0
    @State private var dotCount = 0
    
    var body: some View {
        VStack(spacing: 40) {
            // 彩虹小精灵动画
            ZStack {
                ForEach(0..<3, id: \.self) { index in
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: rainbowColors(for: index),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 60, height: 60)
                        .offset(x: circleOffset(for: index))
                        .opacity(0.8)
                }
            }
            .frame(height: 60)
            
            VStack(spacing: 16) {
                Text("正在检测 Gay 能量波动\(dots)")
                    .font(.title2)
                    .foregroundColor(.white)
                    .fontWeight(.medium)
                
                // 进度条
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.white.opacity(0.2))
                        .frame(height: 8)
                    
                    RoundedRectangle(cornerRadius: 10)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color(hex: "FF6B9D"),
                                    Color(hex: "C06BFF"),
                                    Color(hex: "6B9DFF")
                                ],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: 250 * progress, height: 8)
                }
                .frame(width: 250)
            }
        }
        .onAppear {
            // 进度条动画
            withAnimation(.easeInOut(duration: 2.0)) {
                progress = 1.0
            }
            
            // 文字动画
            Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { _ in
                dotCount = (dotCount + 1) % 4
            }
        }
    }
    
    private var dots: String {
        String(repeating: ".", count: dotCount)
    }
    
    private func rainbowColors(for index: Int) -> [Color] {
        let colorSets: [[Color]] = [
            [Color(hex: "FF6B9D"), Color(hex: "FF8E9D")],
            [Color(hex: "C06BFF"), Color(hex: "D08BFF")],
            [Color(hex: "6B9DFF"), Color(hex: "8BBDFF")]
        ]
        return colorSets[index % colorSets.count]
    }
    
    private func circleOffset(for index: Int) -> CGFloat {
        let spacing: CGFloat = 80
        return CGFloat(index - 1) * spacing
    }
}

#Preview {
    AnalyzingView()
        .background(
            LinearGradient(
                colors: [Color(hex: "667EEA"), Color(hex: "764BA2")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
}
