//
//  StoryModeView.swift
//  Gayish
//
//  Created on 2026-01-13.
//

import SwiftUI

/// 故事模式视图
struct StoryModeView: View {
    @ObservedObject var viewModel: AnalysisViewModel
    @State private var visibleCards: Set<Int> = []
    @State private var showActions = false
    
    var body: some View {
        ZStack {
            // 背景渐变
            if let result = viewModel.analysisResult {
                Color.gradientForScore(result.totalScore)
                    .ignoresSafeArea()
            }
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    // 顶部固定的分数显示
                    CompactScoreHeaderView(
                        score: viewModel.analysisResult?.totalScore ?? 0,
                        levelTitle: viewModel.analysisResult?.levelTitle ?? ""
                    )
                    .padding(.top, 60)
                    .padding(.bottom, 20)
                    
                    // 上传的截图展示
                    if let image = viewModel.selectedImage {
                        UploadedImageView(image: image)
                            .padding(.horizontal, 20)
                            .padding(.bottom, 30)
                    }
                    
                    // 故事卡片区域
                    if let result = viewModel.analysisResult {
                        VStack(spacing: 24) {
                            // 标题
                            Text("📖 分析报告")
                                .font(.system(size: 28, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                                .padding(.bottom, 10)
                            
                            // LV卡片
                            ForEach(Array(result.breakdown.enumerated()), id: \.element.id) { index, breakdown in
                                LevelCardView(
                                    breakdown: breakdown,
                                    index: index
                                )
                                .opacity(visibleCards.contains(index) ? 1 : 0)
                                .offset(y: visibleCards.contains(index) ? 0 : 50)
                            }
                            
                            // 总结卡片
                            SummaryCardView(summary: result.summary)
                                .opacity(visibleCards.contains(99) ? 1 : 0)
                                .offset(y: visibleCards.contains(99) ? 0 : 50)
                            
                            // 操作按钮
                            if showActions {
                                ActionButtonsView(viewModel: viewModel)
                                    .transition(.scale.combined(with: .opacity))
                                    .padding(.top, 20)
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 40)
                    }
                }
            }
        }
        .onAppear {
            startCardAnimation()
        }
    }
    
    /// 启动卡片逐个弹出动画
    private func startCardAnimation() {
        guard let result = viewModel.analysisResult else { return }
        
        // 逐个显示卡片
        for index in 0..<result.breakdown.count {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(index) * 0.5) {
                withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                    visibleCards.insert(index)
                }
                // 播放解锁音效
                viewModel.soundService.playUnlockSound()
                viewModel.soundService.triggerSelectionHaptic()
            }
        }
        
        // 显示总结
        let summaryDelay = Double(result.breakdown.count) * 0.5 + 0.3
        DispatchQueue.main.asyncAfter(deadline: .now() + summaryDelay) {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                visibleCards.insert(99)
            }
            viewModel.soundService.playUnlockSound()
        }
        
        // 显示操作按钮
        DispatchQueue.main.asyncAfter(deadline: .now() + summaryDelay + 0.5) {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                showActions = true
            }
        }
    }
}

/// 顶部紧凑分数显示
struct CompactScoreHeaderView: View {
    let score: Int
    let levelTitle: String
    
    var body: some View {
        HStack(spacing: 16) {
            // 分数
            HStack(alignment: .lastTextBaseline, spacing: 4) {
                Text("\(score)")
                    .font(.system(size: 48, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                
                Text("/ 10")
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(.white.opacity(0.8))
            }
            
            Divider()
                .frame(height: 40)
                .background(Color.white.opacity(0.5))
            
            // 等级
            Text(levelTitle)
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(.white)
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white.opacity(0.15))
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.white.opacity(0.3), lineWidth: 1)
                )
        )
        .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
    }
}

/// LV 卡片视图
struct LevelCardView: View {
    let breakdown: ScoreBreakdown
    let index: Int
    @State private var isExpanded = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // 卡片头部
            HStack {
                // LV标识
                HStack(spacing: 8) {
                    Text(breakdown.levelEmoji)
                        .font(.title)
                    
                    Text("LV.\(breakdown.level)")
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                }
                
                Spacer()
                
                // 得分
                Text("+\(breakdown.score)分")
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                    .foregroundColor(breakdown.isHighlight ? Color(hex: "FFD700") : .white)
            }
            
            // 标题
            HStack {
                Text(breakdown.levelTitle)
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                
                if breakdown.isHighlight {
                    Text("⭐ 最Gay部分")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(Color(hex: "FFD700"))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(
                            Capsule()
                                .fill(Color(hex: "FFD700").opacity(0.2))
                        )
                }
            }
            
            // 引用内容
            Text("\"\(breakdown.quote)\"")
                .font(.body)
                .foregroundColor(.white.opacity(0.95))
                .italic()
                .padding(.vertical, 12)
                .padding(.horizontal, 16)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.white.opacity(0.1))
                )
            
            // 分析说明
            Text(breakdown.analysis)
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.9))
                .lineSpacing(4)
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(
                    breakdown.isHighlight
                        ? LinearGradient(
                            colors: [
                                Color(hex: "FFD700").opacity(0.3),
                                Color(hex: "FFA500").opacity(0.2)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                        : LinearGradient(
                            colors: [
                                Color.white.opacity(0.2),
                                Color.white.opacity(0.1)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(
                            breakdown.isHighlight
                                ? Color(hex: "FFD700").opacity(0.5)
                                : Color.white.opacity(0.3),
                            lineWidth: breakdown.isHighlight ? 2 : 1
                        )
                )
        )
        .shadow(
            color: breakdown.isHighlight
                ? Color(hex: "FFD700").opacity(0.3)
                : Color.black.opacity(0.1),
            radius: breakdown.isHighlight ? 15 : 10,
            x: 0,
            y: 5
        )
    }
}

/// 总结卡片
struct SummaryCardView: View {
    let summary: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("🎭")
                    .font(.title)
                
                Text("最终评语")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
            }
            
            Text(summary)
                .font(.body)
                .foregroundColor(.white.opacity(0.95))
                .lineSpacing(6)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0.25),
                            Color.white.opacity(0.15)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.white.opacity(0.4), lineWidth: 1.5)
                )
        )
        .shadow(color: .black.opacity(0.15), radius: 15, x: 0, y: 8)
    }
}

/// 操作按钮组
struct ActionButtonsView: View {
    @ObservedObject var viewModel: AnalysisViewModel
    @State private var showShareSheet = false
    @State private var showAchievements = false
    
    var body: some View {
        VStack(spacing: 16) {
            // 生成分享海报
            Button(action: {
                showShareSheet = true
            }) {
                HStack(spacing: 12) {
                    Image(systemName: "square.and.arrow.up")
                        .font(.title3)
                    
                    Text("生成分享海报")
                        .font(.headline)
                }
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.white)
                )
                .foregroundColor(Color(hex: "764BA2"))
                .shadow(color: Color.white.opacity(0.3), radius: 10, x: 0, y: 5)
            }
            
            // 查看成就
            Button(action: {
                showAchievements = true
            }) {
                HStack(spacing: 12) {
                    Image(systemName: "trophy.fill")
                        .font(.title3)
                    
                    Text("成就中心")
                        .font(.headline)
                }
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.white.opacity(0.2))
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color.white, lineWidth: 2)
                        )
                )
                .foregroundColor(.white)
            }
            
            // 再测一次
            Button(action: {
                viewModel.testAgain()
            }) {
                HStack(spacing: 12) {
                    Image(systemName: "arrow.clockwise")
                        .font(.title3)
                    
                    Text("再测一次")
                        .font(.headline)
                }
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.white.opacity(0.2))
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color.white, lineWidth: 2)
                        )
                )
                .foregroundColor(.white)
            }
        }
        .sheet(isPresented: $showShareSheet) {
            SharePosterView(result: viewModel.analysisResult!)
        }
        .sheet(isPresented: $showAchievements) {
            AchievementView(achievementService: viewModel.achievementService)
        }
    }
}

/// 上传图片展示组件
struct UploadedImageView: View {
    let image: UIImage
    @State private var showFullscreen = false
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Text("📸 对话截图")
                    .font(.headline)
                    .foregroundColor(.white)
                
                Spacer()
                
                Button(action: {
                    showFullscreen = true
                }) {
                    HStack(spacing: 4) {
                        Image(systemName: "arrow.up.left.and.arrow.down.right")
                            .font(.caption)
                        Text("查看大图")
                            .font(.caption)
                    }
                    .foregroundColor(.white.opacity(0.8))
                }
            }
            
            Image(uiImage: image)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(maxHeight: 300)
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.white.opacity(0.3), lineWidth: 1)
                )
                .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 5)
                .onTapGesture {
                    showFullscreen = true
                }
        }
        .sheet(isPresented: $showFullscreen) {
            FullscreenImageView(image: image, isPresented: $showFullscreen)
        }
    }
}

/// 全屏图片查看
struct FullscreenImageView: View {
    let image: UIImage
    @Binding var isPresented: Bool
    @State private var scale: CGFloat = 1.0
    @State private var lastScale: CGFloat = 1.0
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack {
                HStack {
                    Spacer()
                    
                    Button(action: {
                        isPresented = false
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 30))
                            .foregroundColor(.white.opacity(0.8))
                            .padding()
                    }
                }
                
                Spacer()
                
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .scaleEffect(scale)
                    .gesture(
                        MagnificationGesture()
                            .onChanged { value in
                                scale = lastScale * value
                            }
                            .onEnded { _ in
                                lastScale = scale
                                // 限制缩放范围
                                if scale < 1.0 {
                                    withAnimation {
                                        scale = 1.0
                                        lastScale = 1.0
                                    }
                                } else if scale > 4.0 {
                                    withAnimation {
                                        scale = 4.0
                                        lastScale = 4.0
                                    }
                                }
                            }
                    )
                    .onTapGesture(count: 2) {
                        // 双击重置缩放
                        withAnimation {
                            scale = 1.0
                            lastScale = 1.0
                        }
                    }
                
                Spacer()
                
                Text("双击重置 · 捏合缩放")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.6))
                    .padding(.bottom, 40)
            }
        }
    }
}

#Preview {
    StoryModeView(viewModel: {
        let vm = AnalysisViewModel()
        vm.analysisResult = ChatAnalysisResult(
            totalScore: 9,
            levelTitle: "Drama Queen",
            breakdown: [
                ScoreBreakdown(level: 1, title: "基础得分", score: 3, quote: "不要番茄酱", analysis: "挑剔", isHighlight: false),
                ScoreBreakdown(level: 2, title: "进阶得分", score: 3, quote: "红茶+大薯条", analysis: "品味", isHighlight: false),
                ScoreBreakdown(level: 3, title: "灵魂得分", score: 3, quote: "帮我把茶包拿出来", analysis: "Drama Queen", isHighlight: true)
            ],
            summary: "那个扔茶包的要求实在是太传神了。"
        )
        return vm
    }())
}
