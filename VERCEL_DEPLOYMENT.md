# Vercel 部署指南

## 📦 项目结构

```
gayish/
├── api/
│   └── analyze.js       # Gemini API 调用接口
├── vercel.json          # Vercel 配置
├── package.json         # Node.js 依赖
└── GayishApp/          # Swift iOS 应用
```

## 🚀 部署步骤

### 1. 安装 Vercel CLI（可选，用于本地测试）

```bash
npm install -g vercel
```

### 2. 部署到 Vercel

有两种方式：

#### 方式 A：通过 GitHub 自动部署（推荐）

1. 前往 [Vercel Dashboard](https://vercel.com/new)
2. 点击 "Import Project"
3. 选择你的 GitHub 仓库：`TsukimiTei/gayish-app`
4. Vercel 会自动检测配置并部署

#### 方式 B：通过 CLI 手动部署

```bash
cd "/path/to/gayish"
vercel --prod
```

### 3. 配置环境变量

在 Vercel Dashboard 中配置以下环境变量：

1. 前往项目 → Settings → Environment Variables
2. 添加以下变量：

| 变量名 | 值 | 说明 |
|--------|-----|------|
| `GEMINI_API_KEY` | `your_api_key_here` | 你的 Gemini API Key |
| `GEMINI_MODEL` | `gemini-1.5-flash` | 使用的模型名称（可选） |

### 4. 获取 API 端点

部署成功后，你会得到一个 URL，例如：

```
https://gayish-app.vercel.app
```

你的 API 端点将是：

```
https://gayish-app.vercel.app/api/analyze
```

### 5. 在 Swift 应用中配置

在 `AIAnalysisService.swift` 中更新 `vercelEndpoint`：

```swift
private let vercelEndpoint = "https://gayish-app.vercel.app/api/analyze"
```

## 🧪 测试 API

### 使用 curl 测试

```bash
curl -X POST https://gayish-app.vercel.app/api/analyze \
  -H "Content-Type: application/json" \
  -d '{
    "image": "BASE64_ENCODED_IMAGE_DATA",
    "prompt": "分析这张图片"
  }'
```

### 预期响应

```json
{
  "success": true,
  "text": "分析结果...",
  "model": "gemini-1.5-flash"
}
```

## 📊 监控和日志

- **日志查看**：Vercel Dashboard → 你的项目 → Deployments → 选择部署 → Function Logs
- **实时监控**：Vercel Dashboard → 你的项目 → Analytics

## 🔒 安全说明

- ✅ API Key 存储在 Vercel 环境变量中，不会暴露给客户端
- ✅ CORS 已配置，允许来自任何源的请求
- ⚠️ 考虑添加请求频率限制和身份验证

## 🐛 常见问题

### 1. 部署后 API 返回 500 错误

检查环境变量是否正确配置：
- 前往 Vercel Dashboard → Settings → Environment Variables
- 确认 `GEMINI_API_KEY` 已设置

### 2. CORS 错误

已在代码中配置 CORS，如果仍有问题，检查请求头设置。

### 3. 超时错误

Vercel Serverless Functions 默认超时 10 秒，如需更长时间：
- 升级到 Pro 计划（最长 60 秒）
- 或优化 API 调用

## 📝 更新部署

### 通过 GitHub（自动）

```bash
git add .
git commit -m "update: API improvements"
git push origin main
```

Vercel 会自动重新部署。

### 通过 CLI（手动）

```bash
vercel --prod
```

## 🔗 相关链接

- [Vercel 文档](https://vercel.com/docs)
- [Serverless Functions](https://vercel.com/docs/functions)
- [环境变量配置](https://vercel.com/docs/environment-variables)
