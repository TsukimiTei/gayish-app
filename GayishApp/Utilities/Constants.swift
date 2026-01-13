//
//  Constants.swift
//  Gayish
//
//  Created on 2026-01-13.
//

import Foundation

/// 全局常量
enum Constants {
    
    // MARK: - API配置
    enum API {
        static let openAIEndpoint = "https://api.openai.com/v1/chat/completions"
        static let model = "gpt-4o"
        static let maxTokens = 1000
        static let temperature = 0.7
    }
    
    // MARK: - 动画配置
    enum Animation {
        // 指针摆动动画时长
        static let pointerSwingDuration: Double = 3.5
        
        // 卡片弹出间隔
        static let cardPopInterval: Double = 0.5
        
        // 弹簧动画参数
        static let springResponse: Double = 0.6
        static let springDamping: Double = 0.7
    }
    
    // MARK: - UI配置
    enum UI {
        // 仪表盘尺寸
        static let meterWidth: CGFloat = 300
        static let meterHeight: CGFloat = 180
        
        // 海报尺寸（高分辨率）
        static let posterWidth: CGFloat = 1080
        static let posterHeight: CGFloat = 1920
        static let posterScale: CGFloat = 3.0
        
        // 圆角半径
        static let cornerRadius: CGFloat = 16
        static let cardCornerRadius: CGFloat = 20
    }
    
    // MARK: - 文案配置
    enum Text {
        static let appName = "Gayish"
        static let appSubtitle = "测测这对话有多 Gay"
        
        static let uploadPrompt = "请上传聊天对话截图"
        static let uploadingMessage = "正在上传截图..."
        static let analyzingMessage = "正在检测 Gay 能量波动"
        static let scrollHint = "向下滑动查看详情"
        
        static let shareButtonTitle = "生成分享海报"
        static let retryButtonTitle = "再测一次"
    }
    
    // MARK: - System Prompt
    enum Prompts {
        static let systemPrompt = """
        这对话有多 gayyyyyyyyish. it's a joke
        
        给我一个 1 到 10 分的打分，并详细分析每个得分点。
        
        请按照以下格式返回：
        
        1. 基础得分 (+X分): "引用对话内容"
           - 分析说明
        
        2. 进阶得分 (+X分): "引用对话内容"
           - 分析说明
        
        3. 灵魂得分 (+X分 - 最Gay部分): "引用对话内容"
           - 分析说明
        
        4. 附加分 (+X分): "引用对话内容"
           - 分析说明
        
        总结：最终评语
        """
    }
}
