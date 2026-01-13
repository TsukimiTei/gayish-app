//
//  ChatAnalysisResult.swift
//  Gayish
//
//  Created on 2026-01-13.
//

import Foundation

/// 聊天分析结果模型
struct ChatAnalysisResult: Codable {
    let totalScore: Int                  // 总分 1-10
    let levelTitle: String               // 等级标题，如 "Drama Queen"
    let breakdown: [ScoreBreakdown]      // 打分细节
    let summary: String                  // 总结评语
    
    /// 根据分数获取等级标题
    static func getLevelTitle(for score: Int) -> String {
        switch score {
        case 1...2:
            return "直男铁憨憨"
        case 3...4:
            return "普通朋友"
        case 5...6:
            return "Gay雷达有反应"
        case 7...8:
            return "姐妹预备役"
        case 9:
            return "Drama Queen"
        case 10:
            return "Gay Icon本人"
        default:
            return "未知级别"
        }
    }
}

/// 打分细节模型
struct ScoreBreakdown: Codable, Identifiable {
    let id = UUID()
    let level: Int                       // 层级 1, 2, 3...
    let title: String                    // 标题，如 "基础得分"
    let score: Int                       // 得分
    let quote: String                    // 引用的对话内容
    let analysis: String                 // 分析说明
    let isHighlight: Bool                // 是否是最Gay部分
    
    /// 获取层级emoji
    var levelEmoji: String {
        switch level {
        case 1:
            return "🎯"
        case 2:
            return "💅"
        case 3:
            return "👑"
        default:
            return "💬"
        }
    }
    
    /// 获取层级标题
    var levelTitle: String {
        switch level {
        case 1:
            return "基础得分"
        case 2:
            return "进阶得分"
        case 3:
            return "灵魂得分"
        default:
            return "附加分"
        }
    }
    
    private enum CodingKeys: String, CodingKey {
        case level, title, score, quote, analysis, isHighlight
    }
}

/// 分析状态枚举
enum AnalysisState {
    case idle              // 空闲，等待上传
    case uploading         // 正在上传
    case analyzing         // 正在分析
    case revealingScore    // 揭晓分数（仪表盘动画）
    case showingStory      // 展示故事模式
    case error(String)     // 错误状态（附带错误信息）
}
