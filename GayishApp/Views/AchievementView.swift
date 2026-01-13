//
//  AchievementView.swift
//  Gayish
//
//  Created on 2026-01-13.
//

import SwiftUI

/// 成就页面
struct AchievementView: View {
    @ObservedObject var achievementService: AchievementService
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ZStack {
                // 背景
                LinearGradient(
                    colors: [Color(hex: "667EEA"), Color(hex: "764BA2")],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // 统计卡片
                        StatsCardView(stats: achievementService.userStats)
                            .padding(.top, 20)
                        
                        // 进度条
                        ProgressCardView(
                            progress: achievementService.unlockProgress,
                            unlockedCount: achievementService.unlockedCount,
                            totalCount: achievementService.achievements.count
                        )
                        
                        // 成就列表
                        VStack(spacing: 16) {
                            Text("🏆 成就列表")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            ForEach(achievementService.achievements) { achievement in
                                AchievementCardView(achievement: achievement)
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 40)
                }
            }
            .navigationTitle("成就中心")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("关闭") {
                        dismiss()
                    }
                    .foregroundColor(.white)
                }
            }
        }
    }
}

/// 统计卡片
struct StatsCardView: View {
    let stats: UserStats
    
    var body: some View {
        VStack(spacing: 16) {
            Text("📊 我的数据")
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            HStack(spacing: 20) {
                StatItemView(title: "测试次数", value: "\(stats.testCount)")
                StatItemView(title: "最高分", value: "\(stats.highestScore)")
                StatItemView(title: "平均分", value: String(format: "%.1f", stats.averageScore))
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white.opacity(0.2))
        )
    }
}

/// 单个统计项
struct StatItemView: View {
    let title: String
    let value: String
    
    var body: some View {
        VStack(spacing: 8) {
            Text(value)
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundColor(.white)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.white.opacity(0.8))
        }
        .frame(maxWidth: .infinity)
    }
}

/// 进度卡片
struct ProgressCardView: View {
    let progress: Double
    let unlockedCount: Int
    let totalCount: Int
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Text("解锁进度")
                    .font(.headline)
                    .foregroundColor(.white)
                
                Spacer()
                
                Text("\(unlockedCount) / \(totalCount)")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.9))
            }
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.white.opacity(0.2))
                    
                    RoundedRectangle(cornerRadius: 10)
                        .fill(
                            LinearGradient(
                                colors: [Color(hex: "FFD700"), Color(hex: "FFA500")],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: geometry.size.width * progress)
                }
            }
            .frame(height: 12)
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white.opacity(0.2))
        )
    }
}

/// 成就卡片
struct AchievementCardView: View {
    let achievement: Achievement
    
    var body: some View {
        HStack(spacing: 16) {
            // Emoji图标
            Text(achievement.emoji)
                .font(.system(size: 40))
                .frame(width: 60, height: 60)
                .background(
                    Circle()
                        .fill(
                            achievement.isUnlocked
                                ? Color.white.opacity(0.2)
                                : Color.black.opacity(0.3)
                        )
                )
                .grayscale(achievement.isUnlocked ? 0 : 1)
            
            // 文字信息
            VStack(alignment: .leading, spacing: 6) {
                Text(achievement.title)
                    .font(.headline)
                    .foregroundColor(achievement.isUnlocked ? .white : .white.opacity(0.5))
                
                Text(achievement.description)
                    .font(.subheadline)
                    .foregroundColor(achievement.isUnlocked ? .white.opacity(0.9) : .white.opacity(0.4))
                
                if achievement.isUnlocked, let date = achievement.unlockedDate {
                    Text("解锁于 \(formattedDate(date))")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.6))
                }
            }
            
            Spacer()
            
            // 解锁状态
            if achievement.isUnlocked {
                Image(systemName: "checkmark.circle.fill")
                    .font(.title2)
                    .foregroundColor(Color(hex: "FFD700"))
            } else {
                Image(systemName: "lock.fill")
                    .font(.title3)
                    .foregroundColor(.white.opacity(0.3))
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(
                    achievement.isUnlocked
                        ? Color.white.opacity(0.15)
                        : Color.black.opacity(0.2)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(
                            achievement.isUnlocked
                                ? Color.white.opacity(0.3)
                                : Color.white.opacity(0.1),
                            lineWidth: 1
                        )
                )
        )
    }
    
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd"
        return formatter.string(from: date)
    }
}

/// 成就解锁弹窗
struct AchievementUnlockedView: View {
    let achievement: Achievement
    @Binding var isPresented: Bool
    
    var body: some View {
        VStack(spacing: 20) {
            Text("🎉")
                .font(.system(size: 60))
            
            Text("成就解锁！")
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            VStack(spacing: 12) {
                HStack {
                    Text(achievement.emoji)
                        .font(.system(size: 40))
                    
                    Text(achievement.title)
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                }
                
                Text(achievement.description)
                    .font(.body)
                    .foregroundColor(.white.opacity(0.9))
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white.opacity(0.2))
            )
            
            Button("太棒了！") {
                isPresented = false
            }
            .font(.headline)
            .foregroundColor(Color(hex: "764BA2"))
            .frame(width: 200, height: 50)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white)
            )
        }
        .padding(40)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(
                    LinearGradient(
                        colors: [Color(hex: "667EEA"), Color(hex: "764BA2")],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
        )
        .shadow(color: .black.opacity(0.3), radius: 20, x: 0, y: 10)
    }
}

#Preview {
    AchievementView(achievementService: AchievementService())
}
