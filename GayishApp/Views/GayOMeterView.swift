//
//  GayOMeterView.swift
//  Gayish
//
//  Created on 2026-01-13.
//

import SwiftUI

/// Gay-O-Meter 仪表盘视图
struct GayOMeterView: View {
    @ObservedObject var viewModel: AnalysisViewModel
    @State private var showScrollHint = false
    
    var body: some View {
        ZStack {
            // 根据分数动态改变背景
            if let result = viewModel.analysisResult {
                Color.gradientForScore(result.totalScore)
                    .ignoresSafeArea()
                    .transition(.opacity)
            }
            
            VStack(spacing: 0) {
                Spacer()
                
                // 仪表盘组件
                MeterGaugeView(
                    currentScore: viewModel.currentPointerScore,
                    finalScore: viewModel.analysisResult?.totalScore ?? 0,
                    levelTitle: viewModel.analysisResult?.levelTitle ?? "",
                    isAnimating: viewModel.isPointerAnimating
                )
                
                Spacer()
                
                // 向下滑动提示（动画完成后显示）
                if !viewModel.isPointerAnimating {
                    VStack(spacing: 12) {
                        Text("向下滑动查看详情")
                            .font(.headline)
                            .foregroundColor(.white.opacity(0.9))
                        
                        Image(systemName: "chevron.down")
                            .font(.title2)
                            .foregroundColor(.white)
                            .offset(y: showScrollHint ? 10 : 0)
                    }
                    .padding(.bottom, 40)
                    .transition(.opacity)
                    .onAppear {
                        withAnimation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true)) {
                            showScrollHint = true
                        }
                    }
                }
            }
        }
    }
}

/// 仪表盘刻度组件
struct MeterGaugeView: View {
    let currentScore: Double
    let finalScore: Int
    let levelTitle: String
    let isAnimating: Bool
    
    var body: some View {
        VStack(spacing: 30) {
            // 标题
            Text("🌈 GAY-O-METER 🌈")
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundColor(.white)
            
            // 半圆形仪表盘
            ZStack {
                // 背景弧线
                GaugeArcView()
                
                // 刻度数字
                GaugeNumbersView()
                
                // 指针
                PointerView(score: currentScore, isAnimating: isAnimating)
            }
            .frame(width: 300, height: 180)
            
            // 分数显示
            HStack(alignment: .lastTextBaseline, spacing: 4) {
                Text(String(format: "%.0f", currentScore))
                    .font(.system(size: 72, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .contentTransition(.numericText())
                
                Text("/ 10")
                    .font(.system(size: 32, weight: .medium))
                    .foregroundColor(.white.opacity(0.8))
            }
            
            // 等级标签
            if !isAnimating && !levelTitle.isEmpty {
                Text("✨ \(levelTitle) ✨")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(
                        Capsule()
                            .fill(Color.white.opacity(0.2))
                            .overlay(
                                Capsule()
                                    .stroke(Color.white, lineWidth: 2)
                            )
                    )
                    .transition(.scale.combined(with: .opacity))
                    .shadow(color: .white.opacity(0.3), radius: 10, x: 0, y: 5)
            }
        }
    }
}

/// 仪表盘弧线背景
struct GaugeArcView: View {
    var body: some View {
        ZStack {
            // 外圈装饰
            Circle()
                .trim(from: 0, to: 0.5)
                .stroke(
                    Color.white.opacity(0.1),
                    style: StrokeStyle(lineWidth: 30, lineCap: .round)
                )
                .frame(width: 260, height: 260)
                .rotationEffect(.degrees(180))
            
            // 主刻度弧线
            Circle()
                .trim(from: 0, to: 0.5)
                .stroke(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0.6),
                            Color.white.opacity(0.3)
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    ),
                    style: StrokeStyle(lineWidth: 8, lineCap: .round)
                )
                .frame(width: 240, height: 240)
                .rotationEffect(.degrees(180))
            
            // 刻度线
            ForEach(0..<11, id: \.self) { index in
                Rectangle()
                    .fill(Color.white.opacity(0.5))
                    .frame(width: 2, height: index % 5 == 0 ? 20 : 12)
                    .offset(y: -120)
                    .rotationEffect(.degrees(Double(index) * 18))
            }
        }
    }
}

/// 刻度数字
struct GaugeNumbersView: View {
    var body: some View {
        ZStack {
            ForEach([0, 2, 4, 6, 8, 10], id: \.self) { number in
                Text("\(number)")
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundColor(.white)
                    .offset(y: -135)
                    .rotationEffect(.degrees(Double(number) * 18))
                    .rotationEffect(.degrees(-Double(number) * 18)) // 保持数字水平
            }
        }
    }
}

/// 指针组件
struct PointerView: View {
    let score: Double
    let isAnimating: Bool
    
    var body: some View {
        ZStack(alignment: .bottom) {
            // 指针本体
            RoundedRectangle(cornerRadius: 3)
                .fill(
                    LinearGradient(
                        colors: [Color.white, Color.white.opacity(0.8)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(width: 6, height: 100)
                .shadow(color: .white.opacity(0.5), radius: 10, x: 0, y: 0)
                .offset(y: -50)
            
            // 中心圆
            Circle()
                .fill(Color.white)
                .frame(width: 20, height: 20)
                .shadow(color: .white.opacity(0.8), radius: 8, x: 0, y: 0)
                .overlay(
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color(hex: "FF6B9D"),
                                    Color(hex: "C06BFF")
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 12, height: 12)
                )
        }
        .rotationEffect(.degrees(scoreToAngle(score)))
    }
    
    /// 将分数转换为角度 (0分=-90度, 10分=90度)
    private func scoreToAngle(_ score: Double) -> Double {
        let clampedScore = min(max(score, 0), 10)
        return -90 + (clampedScore * 18)
    }
}

#Preview {
    GayOMeterView(viewModel: {
        let vm = AnalysisViewModel()
        vm.currentPointerScore = 7.5
        vm.analysisResult = ChatAnalysisResult(
            totalScore: 9,
            levelTitle: "Drama Queen",
            breakdown: [],
            summary: ""
        )
        return vm
    }())
}
