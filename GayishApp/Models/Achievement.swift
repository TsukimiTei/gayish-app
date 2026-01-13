//
//  Achievement.swift
//  Gayish
//
//  Created on 2026-01-13.
//

import Foundation

/// 成就模型
struct Achievement: Identifiable, Codable {
    let id: String
    let title: String
    let description: String
    let emoji: String
    let requiredScore: Int?      // 需要达到的分数（nil表示其他条件）
    let requiredCount: Int?      // 需要测试的次数
    var isUnlocked: Bool = false
    var unlockedDate: Date?
    
    /// 预定义成就列表
    static let allAchievements: [Achievement] = [
        Achievement(
            id: "first_test",
            title: "初次体验",
            description: "完成第一次测试",
            emoji: "🎯",
            requiredScore: nil,
            requiredCount: 1
        ),
        Achievement(
            id: "score_5",
            title: "Gay雷达启动",
            description: "获得5分或以上",
            emoji: "📡",
            requiredScore: 5,
            requiredCount: nil
        ),
        Achievement(
            id: "score_7",
            title: "姐妹预备役",
            description: "获得7分或以上",
            emoji: "💅",
            requiredScore: 7,
            requiredCount: nil
        ),
        Achievement(
            id: "score_9",
            title: "Drama Queen",
            description: "获得9分",
            emoji: "👑",
            requiredScore: 9,
            requiredCount: nil
        ),
        Achievement(
            id: "score_10",
            title: "Gay Icon",
            description: "获得满分10分",
            emoji: "🌟",
            requiredScore: 10,
            requiredCount: nil
        ),
        Achievement(
            id: "test_3",
            title: "测试狂魔",
            description: "完成3次测试",
            emoji: "🔥",
            requiredScore: nil,
            requiredCount: 3
        ),
        Achievement(
            id: "test_10",
            title: "资深玩家",
            description: "完成10次测试",
            emoji: "⭐",
            requiredScore: nil,
            requiredCount: 10
        ),
        Achievement(
            id: "share_first",
            title: "分享达人",
            description: "第一次分享海报",
            emoji: "📤",
            requiredScore: nil,
            requiredCount: nil
        )
    ]
}

/// 用户统计数据
struct UserStats: Codable {
    var testCount: Int = 0              // 测试次数
    var highestScore: Int = 0           // 最高分数
    var averageScore: Double = 0.0      // 平均分数
    var shareCount: Int = 0             // 分享次数
    var unlockedAchievements: [String] = [] // 已解锁成就ID列表
    
    /// 添加新的测试结果
    mutating func addTestResult(score: Int) {
        testCount += 1
        if score > highestScore {
            highestScore = score
        }
        
        // 更新平均分
        averageScore = (averageScore * Double(testCount - 1) + Double(score)) / Double(testCount)
    }
}
