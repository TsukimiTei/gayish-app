# Gayish App 🌈

一个娱乐化的社交分析产品，通过AI分析聊天对话截图的"Gay度"，生成有趣的分析报告和分享海报。

## 功能特点

### 核心功能
- 📸 **截图上传**：支持相册选择和相机拍摄
- 🤖 **AI分析**：使用GPT-4 Vision进行智能分析
- 🎯 **悬疑揭晓**：仪表盘指针左右摆动，制造紧张感
- 📖 **故事模式**：逐级解锁分析细节，沉浸式体验
- 🎨 **分享海报**：精美的证书风格海报生成

### 视觉设计
- **仪表盘动画**：Gay-O-Meter 半圆形仪表盘，指针悬疑摆动
- **分数等级**：
  - 1-2分：直男铁憨憨
  - 3-4分：普通朋友
  - 5-6分：Gay雷达有反应
  - 7-8分：姐妹预备役
  - 9分：Drama Queen ⭐
  - 10分：Gay Icon本人
- **彩虹配色**：根据分数动态改变背景渐变
- **卡片动画**：LV卡片逐个弹出，带音效和震动反馈

### 技术栈
- **框架**：SwiftUI + MVVM架构
- **AI服务**：
  - Vision Framework (OCR文字识别)
  - OpenAI GPT-4 Vision API
- **动画**：SwiftUI原生动画 + Spring动画
- **音效**：AVFoundation + UIImpactFeedbackGenerator

## 项目结构

```
GayishApp/
├── Models/
│   └── ChatAnalysisResult.swift      # 分析结果数据模型
├── Views/
│   ├── UploadView.swift              # 上传截图页
│   ├── UploadingView.swift           # 上传中动画
│   ├── AnalyzingView.swift           # 分析中动画
│   ├── GayOMeterView.swift           # 仪表盘视图
│   ├── StoryModeView.swift           # 故事模式
│   └── SharePosterView.swift         # 分享海报
├── ViewModels/
│   └── AnalysisViewModel.swift       # 业务逻辑
├── Services/
│   ├── ImagePickerService.swift      # 图片选择
│   ├── AIAnalysisService.swift       # AI分析
│   └── SoundEffectService.swift      # 音效管理
├── Utilities/
│   └── ColorExtension.swift          # 颜色扩展
├── Info.plist
├── GayishApp.swift
└── ContentView.swift
```

## 使用说明

### 配置API Key

在 `AIAnalysisService.swift` 中配置你的OpenAI API Key：

```swift
private let apiKey = "YOUR_OPENAI_API_KEY"
```

### 运行项目

1. 使用Xcode打开项目
2. 选择目标设备（iOS 17.0+）
3. 运行项目（⌘R）

### 使用流程

1. **上传截图**：点击"从相册选择"或"拍摄截图"
2. **等待分析**：AI正在分析对话内容（2-5秒）
3. **观看揭晓**：仪表盘指针悬疑摆动，最终定格分数
4. **查看详情**：自动滚动到故事模式，查看详细分析
5. **生成海报**：点击"生成分享海报"保存和分享

## 系统要求

- iOS 17.0+
- Xcode 15.0+
- Swift 5.9+

## 权限说明

App需要以下权限：
- **相册访问**：选择聊天截图
- **相机访问**：拍摄聊天截图
- **照片库写入**：保存分享海报

## 注意事项

⚠️ **这是一个纯娱乐产品，仅供娱乐使用！**

- AI分析结果仅作娱乐参考，不代表任何实际判断
- 请尊重他人隐私，不要上传他人的私密对话
- 分享时请注意保护个人信息

## 开发计划

### 已完成 ✅
- [x] 基础架构搭建
- [x] 截图上传功能
- [x] Gay-O-Meter仪表盘
- [x] 指针悬疑摆动动画
- [x] 故事模式和卡片动画
- [x] AI API集成
- [x] 分享海报生成器
- [x] 音效和震动反馈

### 待开发 🚧
- [ ] 成就系统和排行榜
- [ ] 本地历史记录
- [ ] 多语言支持
- [ ] 深色模式适配
- [ ] 更多分享样式

## 贡献

欢迎提交Issue和Pull Request！

## 许可证

MIT License

---

**Made with 🌈 by the Gayish Team**
