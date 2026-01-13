# ⚡ 快速开始指南

最简单的 5 步部署流程！

## 🚀 5 分钟部署到 Vercel

### Step 1: 准备 Google Cloud（3 分钟）

```bash
# 1. 登录 Google Cloud
open https://console.cloud.google.com

# 2. 创建项目，记录项目 ID

# 3. 启用 API
gcloud config set project YOUR_PROJECT_ID
gcloud services enable aiplatform.googleapis.com

# 4. 创建服务账号并下载密钥
gcloud iam service-accounts create gayish-vercel-sa --display-name="Gayish Vercel SA"

gcloud projects add-iam-policy-binding YOUR_PROJECT_ID \
  --member="serviceAccount:gayish-vercel-sa@YOUR_PROJECT_ID.iam.gserviceaccount.com" \
  --role="roles/aiplatform.user"

gcloud iam service-accounts keys create ~/gayish-key.json \
  --iam-account=gayish-vercel-sa@YOUR_PROJECT_ID.iam.gserviceaccount.com
```

### Step 2: 推送到 GitHub（30 秒）

```bash
cd /Users/mac/iCloud\ Drive\ \(Archive\)\ -\ 1/Documents/Documents\ -\ bluerose/Demohive/gayish

git add backend/
git commit -m "Add Vercel backend"
git push origin main
```

如果还没有 GitHub 仓库：
```bash
# 在 GitHub 创建仓库
open https://github.com/new

# 推送代码
git remote add origin https://github.com/YOUR_USERNAME/gayish-app.git
git branch -M main
git push -u origin main
```

### Step 3: 导入到 Vercel（30 秒）

1. 访问: https://vercel.com/new
2. 选择你的 GitHub 仓库
3. Root Directory: `backend`
4. **不要点 Deploy！** 先配置环境变量

### Step 4: 配置环境变量（1 分钟）

添加 3 个环境变量：

1. **GOOGLE_CLOUD_PROJECT** = `your-project-id`
2. **GOOGLE_CLOUD_LOCATION** = `us-central1`
3. **GOOGLE_APPLICATION_CREDENTIALS_JSON** = `复制 ~/gayish-key.json 的全部内容`

### Step 5: 部署！（1 分钟）

点击 "Deploy" → 等待部署完成 → 获取 URL

---

## 🧪 测试

```bash
# 替换为你的 Vercel URL
export API_URL="https://your-app.vercel.app"

# 测试健康检查
curl $API_URL/api/health
```

---

## 📱 集成到 iOS 应用

只需修改一个地方：

```swift
// GayishApp/Services/AIAnalysisService.swift

private let backendURL = "https://your-app.vercel.app"

func analyzeImage(_ image: UIImage) async throws -> ChatAnalysisResult {
    guard let url = URL(string: "\(backendURL)/api/analyze") else {
        throw NSError(domain: "InvalidURL", code: -1)
    }
    
    // 将图片转为 Base64
    guard let imageData = image.jpegData(compressionQuality: 0.7) else {
        throw NSError(domain: "ImageCompressionFailed", code: -1)
    }
    
    let base64Image = imageData.base64EncodedString()
    
    // 构建 JSON 请求
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    
    let body: [String: Any] = [
        "image_base64": base64Image,
        "mime_type": "image/jpeg"
    ]
    
    request.httpBody = try JSONSerialization.data(withJSONObject: body)
    
    // 发送请求
    let (data, response) = try await URLSession.shared.data(for: request)
    
    guard let httpResponse = response as? HTTPURLResponse,
          httpResponse.statusCode == 200 else {
        throw NSError(domain: "APIError", code: -1)
    }
    
    // 解析响应
    let decoder = JSONDecoder()
    decoder.keyDecodingStrategy = .convertFromSnakeCase
    return try decoder.decode(ChatAnalysisResult.self, from: data)
}
```

---

## ✅ 完成！

现在你的应用已连接到 Vercel 后端，可以使用 Vertex AI 进行分析了！

**详细文档：** 查看 `VERCEL_DEPLOYMENT.md`
