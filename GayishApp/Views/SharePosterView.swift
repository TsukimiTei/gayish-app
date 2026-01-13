//
//  SharePosterView.swift
//  Gayish
//
//  Created on 2026-01-13.
//

import SwiftUI

/// 分享海报视图
struct SharePosterView: View {
    let result: ChatAnalysisResult
    @Environment(\.dismiss) private var dismiss
    @State private var posterImage: UIImage?
    @State private var showShareSheet = false
    
    var body: some View {
        NavigationView {
            ZStack {
                // 背景
                Color.gradientForScore(result.totalScore)
                    .ignoresSafeArea()
                
                VStack(spacing: 30) {
                    // 海报预览
                    PosterContentView(result: result)
                        .frame(width: 350, height: 600)
                        .background(Color.white)
                        .cornerRadius(20)
                        .shadow(color: .black.opacity(0.3), radius: 20, x: 0, y: 10)
                    
                    // 分享按钮
                    Button(action: {
                        generateAndShare()
                    }) {
                        HStack(spacing: 12) {
                            Image(systemName: "square.and.arrow.up")
                                .font(.title3)
                            
                            Text("保存并分享")
                                .font(.headline)
                        }
                        .frame(width: 200, height: 50)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.white)
                        )
                        .foregroundColor(Color(hex: "764BA2"))
                        .shadow(color: .white.opacity(0.3), radius: 10, x: 0, y: 5)
                    }
                }
            }
            .navigationTitle("分享海报")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("关闭") {
                        dismiss()
                    }
                    .foregroundColor(.white)
                }
            }
            .sheet(isPresented: $showShareSheet) {
                if let image = posterImage {
                    ActivityViewController(activityItems: [image])
                }
            }
        }
    }
    
    /// 生成并分享海报
    private func generateAndShare() {
        let posterView = PosterContentView(result: result)
            .frame(width: Constants.UI.posterWidth, height: Constants.UI.posterHeight)
        
        let renderer = ImageRenderer(content: posterView)
        renderer.scale = Constants.UI.posterScale
        
        if let image = renderer.uiImage {
            posterImage = image
            showShareSheet = true
        }
    }
}

/// 海报内容视图
struct PosterContentView: View {
    let result: ChatAnalysisResult
    
    var body: some View {
        ZStack {
            // 背景渐变
            Color.gradientForScore(result.totalScore)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // 顶部装饰
                HStack {
                    Spacer()
                    rainbowDots
                    Spacer()
                }
                .padding(.top, 40)
                
                // 标题
                Text("🌈 GAY-O-METER 🌈")
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .padding(.top, 20)
                
                Spacer()
                
                // 证书主体
                VStack(spacing: 24) {
                    // 分数
                    VStack(spacing: 8) {
                        HStack(alignment: .lastTextBaseline, spacing: 6) {
                            Text("\(result.totalScore)")
                                .font(.system(size: 100, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                            
                            Text("/ 10")
                                .font(.system(size: 40, weight: .medium))
                                .foregroundColor(.white.opacity(0.8))
                        }
                        
                        Text("Gay 指数")
                            .font(.title3)
                            .foregroundColor(.white.opacity(0.9))
                    }
                    
                    // 等级认证
                    VStack(spacing: 12) {
                        Text("【 \(result.levelTitle) 】")
                            .font(.system(size: 32, weight: .bold))
                            .foregroundColor(.white)
                        
                        Text("等级认证")
                            .font(.title2)
                            .foregroundColor(.white.opacity(0.9))
                    }
                    .padding(.vertical, 20)
                    
                    // 星级
                    HStack(spacing: 8) {
                        ForEach(0..<min(result.totalScore, 10), id: \.self) { _ in
                            Image(systemName: "star.fill")
                                .foregroundColor(Color(hex: "FFD700"))
                                .font(.title3)
                        }
                    }
                    
                    // 最Gay瞬间
                    if let highlight = result.breakdown.first(where: { $0.isHighlight }) {
                        VStack(spacing: 12) {
                        Text("⭐ 最Gay瞬间")
                            .font(.headline)
                            .foregroundColor(Color(hex: "FFD700"))
                        
                        Text("\"\(highlight.quote)\"")
                            .font(.body)
                            .foregroundColor(.white)
                            .italic()
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 30)
                        }
                        .padding(.vertical, 20)
                    }
                }
                
                Spacer()
                
                // 底部信息
                VStack(spacing: 16) {
                    Divider()
                        .background(Color.white.opacity(0.3))
                        .padding(.horizontal, 40)
                    
                    HStack(spacing: 20) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("签发日期")
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.7))
                            
                            Text(currentDate)
                                .font(.footnote)
                                .foregroundColor(.white)
                        }
                        
                        Spacer()
                        
                        VStack(alignment: .trailing, spacing: 4) {
                            Text("编号")
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.7))
                            
                            Text("#\(randomCertNumber)")
                                .font(.footnote)
                                .foregroundColor(.white)
                        }
                    }
                    .padding(.horizontal, 40)
                    
                    // App名称
                    Text("Gayish")
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundColor(.white.opacity(0.8))
                        .padding(.bottom, 30)
                }
            }
        }
    }
    
    /// 彩虹点装饰
    private var rainbowDots: some View {
        HStack(spacing: 12) {
            ForEach([Color(hex: "FF6B9D"), Color(hex: "C06BFF"), Color(hex: "6B9DFF")], id: \.self) { color in
                Circle()
                    .fill(color)
                    .frame(width: 12, height: 12)
            }
        }
    }
    
    /// 当前日期字符串
    private var currentDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy.MM.dd"
        return formatter.string(from: Date())
    }
    
    /// 随机证书编号
    private var randomCertNumber: String {
        String(format: "%06d", Int.random(in: 100000...999999))
    }
}

/// UIKit分享控制器
struct ActivityViewController: UIViewControllerRepresentable {
    let activityItems: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(
            activityItems: activityItems,
            applicationActivities: nil
        )
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

#Preview {
    SharePosterView(result: ChatAnalysisResult(
        totalScore: 9,
        levelTitle: "Drama Queen",
        breakdown: [
            ScoreBreakdown(
                level: 3,
                title: "灵魂得分",
                score: 3,
                quote: "帮我把茶包拿出来丢掉",
                analysis: "这是小公主式的行为艺术",
                isHighlight: true
            )
        ],
        summary: "那个扔茶包的要求实在是太传神了。"
    ))
}
