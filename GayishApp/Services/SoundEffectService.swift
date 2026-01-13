//
//  SoundEffectService.swift
//  Gayish
//
//  Created on 2026-01-13.
//

import AVFoundation
import UIKit

/// 音效和震动服务
class SoundEffectService {
    
    // MARK: - 系统音效ID
    private enum SystemSound: UInt32 {
        case beep = 1103
        case ping = 1104
        case pop = 1105
        case click = 1306  // 修复重复的原始值
    }
    
    // MARK: - 播放音效方法
    
    /// 播放上传音效（相机快门）
    func playUploadSound() {
        AudioServicesPlaySystemSound(1108) // 相机快门声
    }
    
    /// 播放分析中音效（系统提示音）
    func playAnalyzingSound() {
        AudioServicesPlaySystemSound(SystemSound.beep.rawValue)
    }
    
    /// 播放指针摆动音效
    func playPointerSwingSound() {
        AudioServicesPlaySystemSound(SystemSound.click.rawValue)
    }
    
    /// 播放揭晓音效（叮！）
    func playRevealSound() {
        AudioServicesPlaySystemSound(1013) // 发送成功音效
    }
    
    /// 播放解锁音效
    func playUnlockSound() {
        AudioServicesPlaySystemSound(SystemSound.pop.rawValue)
    }
    
    // MARK: - 震动反馈
    
    /// 触发震动反馈
    func triggerHaptic(style: UIImpactFeedbackGenerator.FeedbackStyle = .heavy) {
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.impactOccurred()
    }
    
    /// 触发通知震动
    func triggerNotificationHaptic(type: UINotificationFeedbackGenerator.FeedbackType = .success) {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(type)
    }
    
    /// 触发选择震动
    func triggerSelectionHaptic() {
        let generator = UISelectionFeedbackGenerator()
        generator.selectionChanged()
    }
}
