//
//  AchievementService.swift
//  Gayish
//
//  Created on 2026-01-13.
//

import Foundation

/// 成就管理服务
class AchievementService: ObservableObject {
    @Published var userStats: UserStats
    @Published var achievements: [Achievement]
    @Published var newlyUnlockedAchievements: [Achievement] = []
    
    private let userDefaultsKey = "userStats"
    private let achievementsKey = "achievements"
    
    init() {
        // 加载用户统计数据
        if let data = UserDefaults.standard.data(forKey: userDefaultsKey),
           let stats = try? JSONDecoder().decode(UserStats.self, from: data) {
            self.userStats = stats
        } else {
            self.userStats = UserStats()
        }
        
        // 加载成就数据
        if let data = UserDefaults.standard.data(forKey: achievementsKey),
           let savedAchievements = try? JSONDecoder().decode([Achievement].self, from: data) {
            self.achievements = savedAchievements
        } else {
            self.achievements = Achievement.allAchievements
        }
    }
    
    // MARK: - 保存数据
    
    private func saveUserStats() {
        if let data = try? JSONEncoder().encode(userStats) {
            UserDefaults.standard.set(data, forKey: userDefaultsKey)
        }
    }
    
    private func saveAchievements() {
        if let data = try? JSONEncoder().encode(achievements) {
            UserDefaults.standard.set(data, forKey: achievementsKey)
        }
    }
    
    // MARK: - 记录测试结果
    
    /// 记录新的测试结果
    func recordTestResult(score: Int) {
        userStats.addTestResult(score: score)
        saveUserStats()
        
        // 检查并解锁成就
        checkAndUnlockAchievements(score: score)
    }
    
    /// 记录分享
    func recordShare() {
        userStats.shareCount += 1
        saveUserStats()
        
        // 检查分享成就
        if userStats.shareCount == 1 {
            unlockAchievement(id: "share_first")
        }
    }
    
    // MARK: - 成就检查与解锁
    
    /// 检查并解锁成就
    private func checkAndUnlockAchievements(score: Int) {
        newlyUnlockedAchievements.removeAll()
        
        for index in achievements.indices {
            var achievement = achievements[index]
            
            // 跳过已解锁的成就
            if achievement.isUnlocked {
                continue
            }
            
            var shouldUnlock = false
            
            // 检查分数条件
            if let requiredScore = achievement.requiredScore {
                if score >= requiredScore {
                    shouldUnlock = true
                }
            }
            
            // 检查次数条件
            if let requiredCount = achievement.requiredCount {
                if userStats.testCount >= requiredCount {
                    shouldUnlock = true
                }
            }
            
            // 解锁成就
            if shouldUnlock {
                achievement.isUnlocked = true
                achievement.unlockedDate = Date()
                achievements[index] = achievement
                newlyUnlockedAchievements.append(achievement)
                userStats.unlockedAchievements.append(achievement.id)
            }
        }
        
        if !newlyUnlockedAchievements.isEmpty {
            saveAchievements()
            saveUserStats()
        }
    }
    
    /// 手动解锁成就
    private func unlockAchievement(id: String) {
        guard let index = achievements.firstIndex(where: { $0.id == id }),
              !achievements[index].isUnlocked else {
            return
        }
        
        var achievement = achievements[index]
        achievement.isUnlocked = true
        achievement.unlockedDate = Date()
        achievements[index] = achievement
        newlyUnlockedAchievements.append(achievement)
        userStats.unlockedAchievements.append(id)
        
        saveAchievements()
        saveUserStats()
    }
    
    // MARK: - 获取统计信息
    
    /// 获取解锁进度百分比
    var unlockProgress: Double {
        let unlockedCount = achievements.filter { $0.isUnlocked }.count
        return Double(unlockedCount) / Double(achievements.count)
    }
    
    /// 获取已解锁成就数量
    var unlockedCount: Int {
        achievements.filter { $0.isUnlocked }.count
    }
}
