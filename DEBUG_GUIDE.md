# 调试指南 🐛

## ✅ 已完成的修复

### 1. 添加详细调试日志 📋
所有关键步骤现在都会打印日志：
- 🚀 分析开始
- 📤 上传状态
- 🤖 AI 调用
- ✅ 成功/失败
- 📡 API 响应详情

### 2. 错误提示界面 ⚠️
不再直接返回主页，而是显示友好的错误界面：
- ❌ 显示具体错误信息
- 🔄 提供"重试"按钮
- 🏠 提供"返回主页"按钮

### 3. 完善错误处理 🛡️
区分不同类型的错误：
- API 错误 (401, 404, 429)
- 网络错误
- 解析错误
- 图片错误

### 4. 网络超时处理 ⏱️
- 默认 30 秒超时
- 超时后显示友好提示

### 5. 模拟数据模式 🎭
- 用于测试和调试
- 绕过真实 API 调用
- 2 秒模拟延迟

---

## 🚀 现在如何运行

### 1️⃣ 使用模拟数据模式（推荐先测试）

在 `AIAnalysisService.swift` 第 14 行：
```swift
private let useMockData = true  // ✅ 使用模拟数据
```

**优点：**
- ✅ 无需 API Key
- ✅ 无需网络
- ✅ 立即看到完整流程
- ✅ 测试 UI 和动画

**运行：**
```
⌘ + R
```

上传任意图片 → 2秒后 → 显示 9分 Drama Queen 结果！

---

### 2️⃣ 使用真实 Gemini API

修改 `AIAnalysisService.swift` 第 14 行：
```swift
private let useMockData = false  // ⚠️ 使用真实 API
```

**运行并查看日志：**
```
⌘ + R

然后在 Xcode/Cursor 控制台查看：
📋 [AIAnalysisService] analyzeImage 开始
🌐 [AIAnalysisService] 调用真实 Gemini API
🚀 [AIAnalysisService] 调用 Gemini API...
   端点: https://...
   模型: gemini-3-flash
📡 [AIAnalysisService] Gemini API 响应状态: 200
✅ [AIAnalysisService] 分析完成，总分: X
```

---

## 📊 查看调试日志

### 在 Cursor/VS Code 中
1. 运行项目（⌘ + R）
2. 底部面板 → "OUTPUT" 标签
3. 选择 "SweetPad" 或 "Log"
4. 查看实时日志输出

### 常见日志标记
```
🚀 开始某个操作
📤 上传/发送
📥 接收
🤖 AI 处理
✅ 成功
❌ 失败
⚠️ 警告
📋 信息
🌐 网络请求
📡 网络响应
```

---

## 🐛 常见问题排查

### 问题 1: 选择图片后立即返回主页

**检查日志：**
```
❌ [AnalysisViewModel] 分析失败:
   错误类型: ...
   错误详情: ...
```

**可能原因：**
1. 模拟数据模式未开启，但 API 配置错误
2. 网络问题
3. 图片格式问题

**解决方案：**
```swift
// 暂时使用模拟数据测试
private let useMockData = true
```

---

### 问题 2: API 调用超时

**日志显示：**
```
❌ 错误: 请求超时，请检查网络连接
```

**解决方案：**
1. 检查网络连接
2. 增加超时时间：
```swift
private let requestTimeout: TimeInterval = 60.0  // 改为 60 秒
```

---

### 问题 3: API Key 无效

**日志显示：**
```
📡 Gemini API 响应状态: 401
❌ API密钥无效
```

**解决方案：**
1. 检查 API Key 是否正确
2. 检查 API Key 是否过期
3. 使用模拟数据模式测试

---

### 问题 4: 模型不存在

**日志显示：**
```
📡 Gemini API 响应状态: 404
❌ 模型不存在: gemini-3-flash
```

**解决方案：**
修改模型名称为可用的模型：
```swift
private let geminiModel = "gemini-1.5-pro"  // 或其他可用模型
```

---

## 🎯 测试流程

### 完整测试步骤

#### 1. 模拟数据模式测试
```bash
# 确保模拟模式开启
useMockData = true

# 运行
⌘ + R

# 测试步骤
1. 上传任意图片
2. 观察上传动画（1秒）
3. 观察分析动画（2秒）
4. 观察仪表盘指针摆动（3.5秒）
5. 观察故事卡片逐个弹出
6. 测试分享海报功能
7. 测试成就系统

# 预期结果
✅ 完整流程顺利完成
✅ 显示 9分 Drama Queen
✅ 4个LV卡片全部展示
```

#### 2. 真实 API 模式测试
```bash
# 启用真实 API
useMockData = false

# 运行
⌘ + R

# 测试步骤
1. 上传对话截图
2. 观察控制台日志
3. 等待 AI 分析（可能需要 10-30 秒）
4. 查看真实分析结果

# 如果出错
1. 查看错误界面显示的信息
2. 点击"重试"按钮
3. 或点击"返回主页"重新上传
```

---

## 📝 日志示例

### 成功的完整日志
```
🚀 [AnalysisViewModel] 开始分析流程
📸 [AnalysisViewModel] 图片大小: (750.0, 1334.0)
📤 [AnalysisViewModel] 状态: 上传中
🤖 [AnalysisViewModel] 状态: 分析中
📋 [AIAnalysisService] analyzeImage 开始
   模拟数据模式: 开启
🎭 [AIAnalysisService] 使用模拟数据
✅ [AnalysisViewModel] AI 分析成功！分数: 9
🏆 [AnalysisViewModel] 成就记录成功
🎯 [AnalysisViewModel] 状态: 揭晓分数
📖 [AnalysisViewModel] 状态: 故事模式
```

### 失败的日志（API错误）
```
🚀 [AnalysisViewModel] 开始分析流程
📤 [AnalysisViewModel] 状态: 上传中
🤖 [AnalysisViewModel] 状态: 分析中
🌐 [AnalysisViewModel] 调用 AI 服务...
📋 [AIAnalysisService] analyzeImage 开始
   模拟数据模式: 关闭
🌐 [AIAnalysisService] 调用真实 Gemini API
🚀 [AIAnalysisService] 调用 Gemini API...
   端点: https://...
   模型: gemini-3-flash
📡 [AIAnalysisService] Gemini API 响应状态: 404
❌ [AIAnalysisService] Gemini API 错误响应:
   { "error": { "message": "Model not found" } }
❌ [AnalysisViewModel] 分析失败:
   错误类型: NSError
   错误详情: Error Domain=APIError Code=404 "模型不存在: gemini-3-flash"
⚠️ [AnalysisViewModel] 状态: 错误 - 模型不存在: gemini-3-flash
```

---

## 🔧 快速修复建议

### 如果想快速看到效果
```swift
// AIAnalysisService.swift 第 14 行
private let useMockData = true  // ✅ 启用模拟数据

// 运行即可看到完整效果！
```

### 如果想使用真实 API
```swift
// 1. 确认 API Key 正确
private let geminiAPIKey = "你的真实API_KEY"

// 2. 使用可用的模型
private let geminiModel = "gemini-1.5-pro"

// 3. 关闭模拟模式
private let useMockData = false

// 4. 运行并查看日志
```

---

## 📞 需要帮助？

如果还有问题：
1. 📋 复制完整的错误日志
2. 📸 截图错误界面
3. 💬 描述操作步骤
4. 🔍 我会帮你分析

---

**现在试试吧！先用模拟数据模式看看完整效果！** 🎉
