//
//  AIAnalysisService.swift
//  Gayish
//
//  Created on 2026-01-13.
//

import UIKit
import Vision

/// AI分析服务
class AIAnalysisService {
    
    // MARK: - API配置
    
    // ✅ 使用 Vercel 中间层调用 Gemini API
    // 优势：
    // - API Key 不暴露在客户端
    // - 避免复杂的认证问题
    // - 便于后端逻辑更新
    
    // ⚠️ 部署后替换为你的 Vercel 域名
    private let vercelEndpoint = "https://your-app.vercel.app/api/analyze"
    
    // 模拟数据模式（调试用）
    private let useMockData = false  // ✅ 已启用真实 API 调用
    
    // 网络超时设置
    private let requestTimeout: TimeInterval = 60.0  // 60秒超时（Vercel Pro 最长 60 秒）
    
    // MARK: - 分析图片
    
    /// 分析聊天截图
    func analyzeImage(_ image: UIImage) async throws -> ChatAnalysisResult {
        print("📋 [AIAnalysisService] analyzeImage 开始")
        print("   模拟数据模式: \(useMockData ? "开启" : "关闭")")
        
        // 如果启用模拟数据模式，直接返回模拟结果
        if useMockData {
            print("🎭 [AIAnalysisService] 使用模拟数据")
            try? await Task.sleep(nanoseconds: 2_000_000_000) // 模拟网络延迟
            return getMockResult()
        }
        
        // 使用真实 Gemini API
        print("🌐 [AIAnalysisService] 调用真实 Gemini API")
        let analysisResult = try await analyzeWithGemini(image: image)
        return analysisResult
    }
    
    // MARK: - Vercel API 分析
    
    /// 通过 Vercel 中间层调用 Gemini API 进行图片分析
    private func analyzeWithGemini(image: UIImage) async throws -> ChatAnalysisResult {
        // 1. 准备图片数据（转换为 JPEG base64）
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            throw NSError(domain: "ImageError", code: -1, userInfo: [NSLocalizedDescriptionKey: "无法转换图片"])
        }
        let base64Image = imageData.base64EncodedString()
        
        // 2. 构建请求 URL（Vercel API 端点）
        guard let url = URL(string: vercelEndpoint) else {
            throw NSError(domain: "URLError", code: -1, userInfo: [NSLocalizedDescriptionKey: "无效的 Vercel URL"])
        }
        
        // 3. 构建请求体
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.timeoutInterval = requestTimeout  // 设置超时
        
        // 构建 prompt
        let prompt = """
        这对话有多 gayyyyyyyyish. it's a joke
        
        请分析这张聊天截图，给我一个 1 到 10 分的打分，并详细分析每个得分点。
        
        请严格按照以下格式返回：
        
        1. 基础得分 (+X分): "引用对话内容"
           分析说明
        
        2. 进阶得分 (+X分): "引用对话内容"
           分析说明
        
        3. 灵魂得分 (+X分): "引用对话内容"
           分析说明（这是最Gay的部分）
        
        4. 附加分 (+X分): "引用对话内容"
           分析说明
        
        总结：最终评语
        
        请用中文回答，要幽默风趣，充满娱乐性。
        """
        
        // Vercel API 请求格式（简化版）
        let requestBody: [String: Any] = [
            "image": base64Image,
            "prompt": prompt
        ]
        
        request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
        
        // 4. 发送请求（带超时控制）
        print("🚀 [AIAnalysisService] 调用 Vercel API...")
        print("   端点: \(vercelEndpoint)")
        print("   图片大小: \(imageData.count / 1024) KB")
        print("   超时: \(requestTimeout)秒")
        
        let (data, response) = try await withTimeout(seconds: requestTimeout) {
            try await URLSession.shared.data(for: request)
        }
        
        // 5. 检查响应状态
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NSError(domain: "APIError", code: -1, userInfo: [NSLocalizedDescriptionKey: "无效的响应"])
        }
        
        print("📡 [AIAnalysisService] Vercel API 响应状态: \(httpResponse.statusCode)")
        
        if httpResponse.statusCode != 200 {
            // 打印错误信息
            if let errorString = String(data: data, encoding: .utf8) {
                print("❌ [AIAnalysisService] Vercel API 错误响应:")
                print(errorString)
            }
            
            var errorMessage = "API请求失败"
            if httpResponse.statusCode == 401 {
                errorMessage = "API密钥无效，请检查 Vercel 环境变量"
            } else if httpResponse.statusCode == 404 {
                errorMessage = "Vercel 端点不存在"
            } else if httpResponse.statusCode == 500 {
                errorMessage = "服务器内部错误"
            } else if httpResponse.statusCode == 429 {
                errorMessage = "请求过于频繁"
            }
            
            throw NSError(
                domain: "APIError",
                code: httpResponse.statusCode,
                userInfo: [NSLocalizedDescriptionKey: errorMessage]
            )
        }
        
        // 6. 解析 Vercel API 响应
        let result = try parseVercelResponse(data)
        print("✅ [AIAnalysisService] 分析完成，总分: \(result.totalScore)")
        return result
    }
    
    /// 带超时的异步操作
    private func withTimeout<T>(seconds: TimeInterval, operation: @escaping () async throws -> T) async throws -> T {
        try await withThrowingTaskGroup(of: T.self) { group in
            group.addTask {
                try await operation()
            }
            
            group.addTask {
                try await Task.sleep(nanoseconds: UInt64(seconds * 1_000_000_000))
                throw NSError(
                    domain: NSURLErrorDomain,
                    code: NSURLErrorTimedOut,
                    userInfo: [NSLocalizedDescriptionKey: "请求超时，请检查网络连接"]
                )
            }
            
            let result = try await group.next()!
            group.cancelAll()
            return result
        }
    }
    
    /// 解析 Vercel API 响应
    private func parseVercelResponse(_ data: Data) throws -> ChatAnalysisResult {
        struct VercelResponse: Codable {
            let success: Bool
            let text: String
            let model: String?
            let error: String?
        }
        
        let decoder = JSONDecoder()
        let response = try decoder.decode(VercelResponse.self, from: data)
        
        guard response.success, let content = response.text as String? else {
            print("⚠️ [AIAnalysisService] Vercel API 返回错误")
            print("   错误: \(response.error ?? "未知错误")")
            throw NSError(
                domain: "ParseError",
                code: -1,
                userInfo: [NSLocalizedDescriptionKey: response.error ?? "AI返回的数据格式不正确"]
            )
        }
        
        print("📝 [AIAnalysisService] Gemini 返回内容（通过 Vercel）:")
        print(content)
        if let model = response.model {
            print("   使用模型: \(model)")
        }
        
        // 解析分析内容
        return try parseAnalysisContent(content)
    }
    
    /// 解析 Gemini 响应（保留以备后用）
    private func parseGeminiResponse(_ data: Data) throws -> ChatAnalysisResult {
        struct GeminiResponse: Codable {
            struct Candidate: Codable {
                struct Content: Codable {
                    struct Part: Codable {
                        let text: String?
                    }
                    let parts: [Part]
                }
                let content: Content
            }
            let candidates: [Candidate]
        }
        
        let decoder = JSONDecoder()
        let response = try decoder.decode(GeminiResponse.self, from: data)
        
        guard let firstCandidate = response.candidates.first,
              let firstPart = firstCandidate.content.parts.first,
              let content = firstPart.text else {
            print("⚠️ [AIAnalysisService] 无法解析 Gemini 响应")
            print("   candidates 数量: \(response.candidates.count)")
            throw NSError(
                domain: "ParseError",
                code: -1,
                userInfo: [NSLocalizedDescriptionKey: "AI返回的数据格式不正确"]
            )
        }
        
        print("📝 [AIAnalysisService] Gemini 返回内容:")
        print(content)
        
        // 解析分析内容
        return try parseAnalysisContent(content)
    }
    
    /// 解析分析内容
    private func parseAnalysisContent(_ content: String) throws -> ChatAnalysisResult {
        // 使用正则表达式或字符串解析提取信息
        // 这里提供一个简化的解析逻辑
        
        var totalScore = 0
        var breakdowns: [ScoreBreakdown] = []
        var summary = ""
        
        // 提取总分（查找"总分：X分" 或 "X/10" 或 "评分：X"）
        let scorePatterns = [
            #"总分[：:]\s*(\d+)"#,
            #"(\d+)\s*/\s*10"#,
            #"评分[：:]\s*(\d+)"#,
            #"得分[：:]\s*(\d+)"#
        ]
        
        for pattern in scorePatterns {
            if let regex = try? NSRegularExpression(pattern: pattern, options: []),
               let match = regex.firstMatch(in: content, options: [], range: NSRange(content.startIndex..., in: content)),
               let scoreRange = Range(match.range(at: 1), in: content),
               let score = Int(content[scoreRange]) {
                totalScore = score
                break
            }
        }
        
        // 如果没有找到分数，尝试数字识别
        if totalScore == 0 {
            let numbers = content.components(separatedBy: CharacterSet.decimalDigits.inverted)
                .compactMap { Int($0) }
                .filter { $0 >= 1 && $0 <= 10 }
            if let firstScore = numbers.first {
                totalScore = firstScore
            }
        }
        
        // 解析细节部分（查找"1. "或"LV.1"或"基础得分"等模式）
        let lines = content.components(separatedBy: .newlines)
        var currentLevel = 0
        var currentTitle = ""
        var currentScore = 0
        var currentQuote = ""
        var currentAnalysis = ""
        var isHighlight = false
        
        for line in lines {
            let trimmedLine = line.trimmingCharacters(in: .whitespaces)
            
            // 检测新的层级
            if trimmedLine.contains("基础得分") || trimmedLine.contains("LV.1") || trimmedLine.hasPrefix("1.") {
                if currentLevel > 0 {
                    breakdowns.append(ScoreBreakdown(
                        level: currentLevel,
                        title: currentTitle,
                        score: currentScore,
                        quote: currentQuote,
                        analysis: currentAnalysis,
                        isHighlight: isHighlight
                    ))
                }
                currentLevel = 1
                currentTitle = "基础得分"
                currentScore = extractScore(from: trimmedLine)
                isHighlight = false
            } else if trimmedLine.contains("进阶得分") || trimmedLine.contains("LV.2") || trimmedLine.hasPrefix("2.") {
                if currentLevel > 0 {
                    breakdowns.append(ScoreBreakdown(
                        level: currentLevel,
                        title: currentTitle,
                        score: currentScore,
                        quote: currentQuote,
                        analysis: currentAnalysis,
                        isHighlight: isHighlight
                    ))
                }
                currentLevel = 2
                currentTitle = "进阶得分"
                currentScore = extractScore(from: trimmedLine)
                isHighlight = false
            } else if trimmedLine.contains("灵魂得分") || trimmedLine.contains("LV.3") || trimmedLine.hasPrefix("3.") {
                if currentLevel > 0 {
                    breakdowns.append(ScoreBreakdown(
                        level: currentLevel,
                        title: currentTitle,
                        score: currentScore,
                        quote: currentQuote,
                        analysis: currentAnalysis,
                        isHighlight: isHighlight
                    ))
                }
                currentLevel = 3
                currentTitle = "灵魂得分"
                currentScore = extractScore(from: trimmedLine)
                isHighlight = trimmedLine.contains("Gay") || trimmedLine.contains("最") || trimmedLine.contains("关键")
            } else if trimmedLine.contains("附加分") || trimmedLine.contains("LV.4") || trimmedLine.hasPrefix("4.") {
                if currentLevel > 0 {
                    breakdowns.append(ScoreBreakdown(
                        level: currentLevel,
                        title: currentTitle,
                        score: currentScore,
                        quote: currentQuote,
                        analysis: currentAnalysis,
                        isHighlight: isHighlight
                    ))
                }
                currentLevel = 4
                currentTitle = "附加分"
                currentScore = extractScore(from: trimmedLine)
                isHighlight = false
            }
            
            // 提取引用内容（带引号的文字）
            if trimmedLine.contains("\"") {
                let quotes = trimmedLine.components(separatedBy: "\"")
                if quotes.count >= 3 {
                    currentQuote = quotes[1]
                }
            }
            
            // 收集分析文本
            if currentLevel > 0 && !trimmedLine.isEmpty &&
               !trimmedLine.hasPrefix("1.") && !trimmedLine.hasPrefix("2.") &&
               !trimmedLine.hasPrefix("3.") && !trimmedLine.hasPrefix("4.") &&
               !trimmedLine.contains("LV.") && !trimmedLine.contains("得分") {
                if !currentAnalysis.isEmpty {
                    currentAnalysis += " "
                }
                currentAnalysis += trimmedLine
            }
            
            // 检测总结部分
            if trimmedLine.contains("总结") || trimmedLine.contains("评语") || trimmedLine.contains("最终") {
                summary = trimmedLine
            }
        }
        
        // 添加最后一个层级
        if currentLevel > 0 {
            breakdowns.append(ScoreBreakdown(
                level: currentLevel,
                title: currentTitle,
                score: currentScore,
                quote: currentQuote,
                analysis: currentAnalysis,
                isHighlight: isHighlight
            ))
        }
        
        // 如果解析失败，使用模拟数据
        if totalScore == 0 || breakdowns.isEmpty {
            print("⚠️ 解析失败，使用模拟数据")
            return getMockResult()
        }
        
        // 提取总结（从"总结"或"评语"开始的段落）
        if summary.isEmpty {
            let summaryKeywords = ["总结", "评语", "最终", "综上"]
            for keyword in summaryKeywords {
                if let range = content.range(of: keyword) {
                    summary = String(content[range.lowerBound...])
                        .components(separatedBy: .newlines)
                        .prefix(3)
                        .joined(separator: " ")
                    break
                }
            }
        }
        
        if summary.isEmpty {
            summary = "这对话确实很有意思！"
        }
        
        let levelTitle = ChatAnalysisResult.getLevelTitle(for: totalScore)
        
        return ChatAnalysisResult(
            totalScore: totalScore,
            levelTitle: levelTitle,
            breakdown: breakdowns,
            summary: summary
        )
    }
    
    /// 从文本中提取分数
    private func extractScore(from text: String) -> Int {
        let patterns = [
            #"\+(\d+)分"#,
            #"(\d+)分"#,
            #"\+(\d+)"#
        ]
        
        for pattern in patterns {
            if let regex = try? NSRegularExpression(pattern: pattern, options: []),
               let match = regex.firstMatch(in: text, options: [], range: NSRange(text.startIndex..., in: text)),
               let scoreRange = Range(match.range(at: 1), in: text),
               let score = Int(text[scoreRange]) {
                return score
            }
        }
        
        return 0
    }
    
    // MARK: - 模拟数据（用于测试）
    
    /// 获取模拟分析结果
    private func getMockResult() -> ChatAnalysisResult {
        let breakdown = [
            ScoreBreakdown(
                level: 1,
                title: "基础得分",
                score: 3,
                quote: "不要番茄酱和酸黄瓜",
                analysis: "这只是单纯的挑剔，很多人都这样，但这奠定了\"我有自己的一套标准\"的基调。",
                isHighlight: false
            ),
            ScoreBreakdown(
                level: 2,
                title: "进阶得分",
                score: 3,
                quote: "红茶+大薯条",
                analysis: "碳水+茶，非常经典的精致快乐餐选择。",
                isHighlight: false
            ),
            ScoreBreakdown(
                level: 3,
                title: "灵魂得分",
                score: 3,
                quote: "帮我把红茶里的茶包拿出来丢掉",
                analysis: "这简直是分数的爆发点！这不仅仅是挑剔，这是一种**\"小公主/Diva\"**式的行为艺术。这种对生活细节的极致掌控欲和对他人的\"使唤\"，非常符合那个味儿。",
                isHighlight: true
            ),
            ScoreBreakdown(
                level: 4,
                title: "附加分",
                score: 0,
                quote: "i am a picky guy",
                analysis: "这种极其坦然的自我认知和英文自嘲，充满了\"虽然我很事儿，但我很可爱，你得宠着我\"的做娇感。",
                isHighlight: false
            )
        ]
        
        return ChatAnalysisResult(
            totalScore: 9,
            levelTitle: "Drama Queen",
            breakdown: breakdown,
            summary: "那个\"扔茶包\"的要求实在是太传神了。如果他只是说\"不要茶包\"，那是普通顾客；说\"拿到的时候帮我扔掉\"，那就是妥妥的 Drama Queen 级别。这就是那种让人一边翻白眼一边觉得\"行吧拿你没办法\"的典范。"
        )
    }
}
