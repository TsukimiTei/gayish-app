# 🚀 Vercel 部署指南（最简单的方案）

Vercel 是最简单的部署方式！无需配置 Docker，自动 CI/CD，免费额度充足。

## ✨ 为什么选择 Vercel？

- ✅ **超级简单**：连接 GitHub 自动部署，无需配置
- ✅ **免费额度大**：每月 100GB 流量，10万次请求
- ✅ **自动 HTTPS**：无需配置 SSL 证书
- ✅ **全球 CDN**：自动优化访问速度
- ✅ **零运维**：自动扩容，无需管理服务器
- ✅ **实时日志**：方便调试

---

## 📋 前置条件

- ✅ 拥有 [GitHub](https://github.com) 账号
- ✅ 拥有 [Vercel](https://vercel.com) 账号（可用 GitHub 登录）
- ✅ 拥有 [Google Cloud](https://cloud.google.com) 账号（用于 Vertex AI）

---

## 🎯 Step 1: 准备 Google Cloud

### 1.1 创建项目

1. 访问 https://console.cloud.google.com
2. 创建新项目，命名为 `gayish-backend`
3. 记录项目 ID（例如：`gayish-backend-123456`）

### 1.2 启用 Vertex AI API

```bash
# 安装 gcloud CLI（如果还没有）：https://cloud.google.com/sdk/docs/install

# 登录
gcloud auth login

# 设置项目
gcloud config set project YOUR_PROJECT_ID

# 启用 API
gcloud services enable aiplatform.googleapis.com
```

### 1.3 创建服务账号

```bash
# 创建服务账号
gcloud iam service-accounts create gayish-vercel-sa \
  --display-name="Gayish Vercel Service Account"

# 授予 Vertex AI 权限
gcloud projects add-iam-policy-binding YOUR_PROJECT_ID \
  --member="serviceAccount:gayish-vercel-sa@YOUR_PROJECT_ID.iam.gserviceaccount.com" \
  --role="roles/aiplatform.user"

# 下载密钥（JSON 格式）
gcloud iam service-accounts keys create ~/gayish-vercel-key.json \
  --iam-account=gayish-vercel-sa@YOUR_PROJECT_ID.iam.gserviceaccount.com
```

**重要：保存好这个 JSON 文件！**

---

## 🎯 Step 2: 推送代码到 GitHub

### 2.1 检查 Git 状态

```bash
cd /Users/mac/iCloud\ Drive\ \(Archive\)\ -\ 1/Documents/Documents\ -\ bluerose/Demohive/gayish

# 检查状态
git status
```

### 2.2 提交新的后端代码

```bash
# 添加后端文件
git add backend/

# 提交
git commit -m "Add Vercel backend with Vertex AI"

# 推送到 GitHub
git push origin main
```

如果还没有 GitHub 仓库：

```bash
# 在 GitHub 创建新仓库：https://github.com/new
# 仓库名：gayish-app

# 添加远程仓库
git remote add origin https://github.com/YOUR_USERNAME/gayish-app.git

# 推送
git branch -M main
git push -u origin main
```

---

## 🎯 Step 3: 部署到 Vercel

### 3.1 导入项目

1. 访问 https://vercel.com/new
2. 使用 GitHub 登录（如果还没有 Vercel 账号）
3. 点击 "Import Git Repository"
4. 找到并选择你的 `gayish-app` 仓库
5. 点击 "Import"

### 3.2 配置项目设置

在 Vercel 导入界面配置：

| 设置项 | 值 |
|--------|-----|
| **Framework Preset** | Other |
| **Root Directory** | `backend` |
| **Build Command** | 留空 |
| **Output Directory** | 留空 |
| **Install Command** | `pip install -r requirements-vercel.txt` |

### 3.3 配置环境变量（重要！）

**不要点击 "Deploy"！** 先配置环境变量：

点击 "Environment Variables" 展开，添加以下变量：

#### 变量 1: GOOGLE_CLOUD_PROJECT
- **Key**: `GOOGLE_CLOUD_PROJECT`
- **Value**: `gayish-backend-123456`（你的实际项目 ID）
- **Environment**: All (Production, Preview, Development)

#### 变量 2: GOOGLE_CLOUD_LOCATION
- **Key**: `GOOGLE_CLOUD_LOCATION`
- **Value**: `us-central1`
- **Environment**: All

#### 变量 3: GOOGLE_APPLICATION_CREDENTIALS_JSON（最重要！）
- **Key**: `GOOGLE_APPLICATION_CREDENTIALS_JSON`
- **Value**: 打开 `~/gayish-vercel-key.json`，复制**全部内容**
- **Environment**: All

JSON 内容示例：
```json
{
  "type": "service_account",
  "project_id": "gayish-backend-123456",
  "private_key_id": "abc123...",
  "private_key": "-----BEGIN PRIVATE KEY-----\nMIIE...\n-----END PRIVATE KEY-----\n",
  "client_email": "gayish-vercel-sa@gayish-backend-123456.iam.gserviceaccount.com",
  "client_id": "123456789",
  "auth_uri": "https://accounts.google.com/o/oauth2/auth",
  "token_uri": "https://oauth2.googleapis.com/token",
  ...
}
```

**直接复制整个 JSON 对象，包括所有大括号和换行符！**

### 3.4 开始部署

配置完环境变量后，点击 **"Deploy"**。

等待 1-2 分钟，部署完成！

---

## 🎯 Step 4: 测试 API

### 4.1 获取 API 地址

部署成功后，Vercel 会显示你的服务地址，类似：

```
https://gayish-app-xxx.vercel.app
```

### 4.2 测试健康检查

```bash
curl https://your-app.vercel.app/api/health
```

应该返回：
```json
{
  "status": "healthy",
  "service": "Gayish API",
  "platform": "Vercel"
}
```

### 4.3 测试图片分析

由于 Vercel Serverless Functions 处理 multipart/form-data 比较复杂，我们使用 **Base64 + JSON** 格式：

```bash
# 先将图片转为 Base64
BASE64_IMAGE=$(base64 -i your-image.jpg)

# 发送请求
curl -X POST https://your-app.vercel.app/api/analyze \
  -H "Content-Type: application/json" \
  -d "{\"image_base64\": \"$BASE64_IMAGE\", \"mime_type\": \"image/jpeg\"}"
```

---

## 🎯 Step 5: 集成到 iOS 应用

### 5.1 更新 AIAnalysisService.swift

创建新文件 `GayishApp/Services/VercelAIService.swift`：

```swift
import UIKit

class VercelAIService {
    // 替换为你的 Vercel URL
    private let backendURL = "https://your-app.vercel.app"
    
    func analyzeImage(_ image: UIImage) async throws -> ChatAnalysisResult {
        // 1. 构建 URL
        guard let url = URL(string: "\(backendURL)/api/analyze") else {
            throw NSError(domain: "InvalidURL", code: -1)
        }
        
        // 2. 压缩图片并转 Base64
        guard let imageData = image.jpegData(compressionQuality: 0.7) else {
            throw NSError(domain: "ImageCompressionFailed", code: -1)
        }
        
        let base64Image = imageData.base64EncodedString()
        
        // 3. 构建请求
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: Any] = [
            "image_base64": base64Image,
            "mime_type": "image/jpeg"
        ]
        
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        
        // 4. 发送请求
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw NSError(domain: "APIError", code: -1, userInfo: [
                NSLocalizedDescriptionKey: "API 请求失败"
            ])
        }
        
        // 5. 解析响应
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        let result = try decoder.decode(ChatAnalysisResult.self, from: data)
        
        return result
    }
}
```

### 5.2 更新 ChatAnalysisResult 模型

确保数据模型匹配后端返回格式：

```swift
struct ChatAnalysisResult: Codable {
    let totalScore: Int
    let levelTitle: String
    let breakdown: [BreakdownItem]
    let summary: String
    let rawText: String?
    
    enum CodingKeys: String, CodingKey {
        case totalScore = "total_score"
        case levelTitle = "level_title"
        case breakdown
        case summary
        case rawText = "raw_text"
    }
}

struct BreakdownItem: Codable {
    let category: String
    let score: Int
    let quote: String
    let description: String
    let isHighlight: Bool
    
    enum CodingKeys: String, CodingKey {
        case category
        case score
        case quote
        case description
        case isHighlight = "isHighlight"
    }
}
```

### 5.3 在 AnalysisViewModel 中使用

```swift
class AnalysisViewModel: ObservableObject {
    // ...
    private let aiService = VercelAIService()
    
    func analyzeSelectedImage() async {
        // ...
        do {
            let result = try await aiService.analyzeImage(selectedImage!)
            await MainActor.run {
                self.analysisResult = result
                self.currentState = .showingResult
            }
        } catch {
            // 错误处理
        }
    }
}
```

---

## 🎯 Step 6: 查看日志和监控

### 6.1 实时日志

1. 访问 Vercel Dashboard: https://vercel.com/dashboard
2. 选择你的项目
3. 点击 "Deployments" → 选择最新部署
4. 点击 "Functions" → 选择 `api/analyze.py`
5. 点击 "View Logs" 查看实时日志

### 6.2 监控面板

在项目页面可以看到：
- 请求数量
- 响应时间
- 错误率
- 带宽使用

---

## 💰 成本估算

### Vercel 免费额度（Hobby 计划）

每月免费：
- ✅ 100GB 带宽
- ✅ 100,000 次函数调用
- ✅ 100 小时函数执行时间
- ✅ 无限项目和部署

### Google Cloud Vertex AI

Gemini 2.0 Flash 定价：
- 输入：$0.075 / 百万 tokens（约 $0.0001/次请求）
- 输出：$0.30 / 百万 tokens（约 $0.0005/次请求）

**预估：**
- 每次分析成本：约 $0.0006
- 1000 次分析：约 $0.60
- 10000 次分析：约 $6.00

**大部分个人项目完全免费！**

---

## 🔄 更新部署

当你修改代码后：

```bash
# 提交更改
git add backend/
git commit -m "Update API logic"
git push origin main
```

**Vercel 会自动重新部署！** 无需任何手动操作。

---

## 🐛 故障排查

### 问题 1: 部署失败 "Module not found"

**原因**：依赖未安装

**解决**：确保 `requirements-vercel.txt` 文件存在，内容为：
```
google-cloud-aiplatform==1.42.1
```

### 问题 2: 500 错误 "Vertex AI not available"

**原因**：环境变量未配置

**解决**：
1. 检查 Vercel 项目设置 → Environment Variables
2. 确认 3 个环境变量都已添加
3. 重新部署：在 Deployments 页面点击 "Redeploy"

### 问题 3: 403 权限错误

**原因**：服务账号权限不足

**解决**：
```bash
gcloud projects add-iam-policy-binding YOUR_PROJECT_ID \
  --member="serviceAccount:gayish-vercel-sa@YOUR_PROJECT_ID.iam.gserviceaccount.com" \
  --role="roles/aiplatform.user"
```

### 问题 4: 超时错误

**原因**：Vercel 免费版函数超时限制 10 秒

**解决**：
1. 优化图片压缩（降低质量到 0.5-0.6）
2. 使用更快的 Gemini 模型（已使用 flash 版本）
3. 升级到 Vercel Pro（60 秒超时）

### 问题 5: 查看详细错误信息

在 `api/analyze.py` 中添加更多日志：

```python
try:
    result = analyze_with_vertex_ai(image_data, mime_type)
    return result
except Exception as e:
    import traceback
    error_detail = traceback.format_exc()
    print(f"Error: {error_detail}")  # 会显示在 Vercel 日志中
    raise
```

---

## 🛡️ 安全建议

### 1. 添加 API 密钥验证（可选）

在 `api/analyze.py` 中：

```python
API_KEY = os.getenv("API_KEY", "your-secret-key")

def do_POST(self):
    # 验证 API Key
    auth_header = self.headers.get('Authorization', '')
    if not auth_header.startswith('Bearer ') or auth_header[7:] != API_KEY:
        self._send_error("Unauthorized", 401)
        return
    
    # 继续处理...
```

在 iOS 应用中：

```swift
request.setValue("Bearer your-secret-key", forHTTPHeaderField: "Authorization")
```

### 2. 限制请求频率

使用 Vercel 的 Edge Config 或第三方服务（如 Upstash Redis）实现限流。

### 3. 保护敏感数据

- ✅ 不要把 JSON 密钥提交到 Git
- ✅ 使用 Vercel 环境变量存储敏感信息
- ✅ 定期轮换服务账号密钥

---

## ✅ 完成检查清单

部署完成后，确认：

- [ ] Vercel 项目显示 "Ready"
- [ ] `/api/health` 返回 200
- [ ] `/api/analyze` 能成功处理请求
- [ ] iOS 应用能连接到 Vercel API
- [ ] 日志中没有错误信息
- [ ] 成本在免费额度内

---

## 📚 参考资料

- [Vercel 文档](https://vercel.com/docs)
- [Vercel Python Runtime](https://vercel.com/docs/functions/serverless-functions/runtimes/python)
- [Vertex AI 文档](https://cloud.google.com/vertex-ai/docs)

---

## 🎉 大功告成！

恭喜！你的 Gayish 后端已成功部署到 Vercel！

**下一步：**
1. 在 iOS 应用中更新 API 地址
2. 测试完整流程
3. 享受你的应用！🌈
