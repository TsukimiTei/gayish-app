//
//  AnalysisViewModel.swift
//  Gayish
//
//  Created on 2026-01-13.
//

import SwiftUI
import Combine

@MainActor
class AnalysisViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var currentState: AnalysisState = .idle
    @Published var selectedImage: UIImage?
    @Published var analysisResult: ChatAnalysisResult?
    @Published var currentPointerScore: Double = 0.0
    @Published var isPointerAnimating: Bool = false
    
    // MARK: - Services
    private let imagePickerService = ImagePickerService()
    private let aiService = AIAnalysisService()
    let soundService = SoundEffectService() // 改为public以便视图访问
    let achievementService = AchievementService() // 成就服务
    
    // MARK: - Methods
    
    /// 选择图片
    func selectImage(_ image: UIImage) {
        selectedImage = image
        startAnalysis()
    }
    
    /// 开始分析流程
    func startAnalysis() {
        Task {
            print("🚀 [AnalysisViewModel] 开始分析流程")
            print("📸 [AnalysisViewModel] 图片大小: \(selectedImage?.size ?? .zero)")
            
            // 1. 上传状态
            currentState = .uploading
            print("📤 [AnalysisViewModel] 状态: 上传中")
            try? await Task.sleep(nanoseconds: 1_000_000_000) // 1秒
            
            // 2. 分析状态
            currentState = .analyzing
            print("🤖 [AnalysisViewModel] 状态: 分析中")
            soundService.playAnalyzingSound()
            
            // 调用AI分析
            do {
                print("🌐 [AnalysisViewModel] 调用 AI 服务...")
                let result = try await aiService.analyzeImage(selectedImage!)
                print("✅ [AnalysisViewModel] AI 分析成功！分数: \(result.totalScore)")
                
                analysisResult = result
                
                // 记录测试结果到成就系统
                achievementService.recordTestResult(score: result.totalScore)
                print("🏆 [AnalysisViewModel] 成就记录成功")
                
                // 3. 揭晓分数（仪表盘动画）
                currentState = .revealingScore
                print("🎯 [AnalysisViewModel] 状态: 揭晓分数")
                await startPointerAnimation(targetScore: result.totalScore)
                
                // 4. 显示故事模式
                try? await Task.sleep(nanoseconds: 1_000_000_000) // 停留1秒
                currentState = .showingStory
                print("📖 [AnalysisViewModel] 状态: 故事模式")
                
            } catch {
                print("❌ [AnalysisViewModel] 分析失败:")
                print("   错误类型: \(type(of: error))")
                print("   错误详情: \(error)")
                print("   错误描述: \(error.localizedDescription)")
                
                // 显示错误界面而不是直接返回
                let errorMessage = getErrorMessage(from: error)
                currentState = .error(errorMessage)
                print("⚠️ [AnalysisViewModel] 状态: 错误 - \(errorMessage)")
            }
        }
    }
    
    /// 从错误中提取友好的错误消息
    private func getErrorMessage(from error: Error) -> String {
        let nsError = error as NSError
        
        // API 错误
        if nsError.domain == "APIError" {
            if nsError.code == 401 {
                return "API密钥无效，请检查配置"
            } else if nsError.code == 429 {
                return "请求过于频繁，请稍后再试"
            } else {
                return "API调用失败：\(nsError.localizedDescription)"
            }
        }
        
        // 网络错误
        if nsError.domain == NSURLErrorDomain {
            return "网络连接失败，请检查网络"
        }
        
        // 解析错误
        if nsError.domain == "ParseError" {
            return "AI返回结果解析失败，请重试"
        }
        
        // 图片错误
        if nsError.domain == "ImageError" {
            return "图片处理失败，请选择其他图片"
        }
        
        // 默认错误
        return "分析失败：\(error.localizedDescription)"
    }
    
    /// 指针动画
    func startPointerAnimation(targetScore: Int) async {
        isPointerAnimating = true
        soundService.playPointerSwingSound()
        
        // 悬疑摆动动画序列
        let swingSequence: [(score: Double, duration: Double)] = [
            (10.0, 0.5),
            (2.0, 0.5),
            (8.0, 0.5),
            (5.0, 0.5),
            (Double(targetScore) + 1.0, 0.5),
            (Double(targetScore) - 0.5, 0.3),
            (Double(targetScore), 0.5)
        ]
        
        for (score, duration) in swingSequence {
            withAnimation(.easeInOut(duration: duration)) {
                currentPointerScore = score
            }
            try? await Task.sleep(nanoseconds: UInt64(duration * 1_000_000_000))
        }
        
        // 最终定格
        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
            currentPointerScore = Double(targetScore)
        }
        
        soundService.playRevealSound()
        soundService.triggerHaptic()
        
        try? await Task.sleep(nanoseconds: 500_000_000) // 0.5秒
        isPointerAnimating = false
    }
    
    /// 重置到空闲状态
    func resetToIdle() {
        currentState = .idle
        selectedImage = nil
        analysisResult = nil
        currentPointerScore = 0.0
        isPointerAnimating = false
    }
    
    /// 再测一次
    func testAgain() {
        resetToIdle()
    }
}
