# 📦 Google Cloud Run 部署指南

本指南将一步步教你如何将 Gayish Backend 部署到 Google Cloud Run。

## 📋 前置条件

- ✅ 拥有 Google Cloud 账号
- ✅ 安装 [gcloud CLI](https://cloud.google.com/sdk/docs/install)
- ✅ 安装 Docker Desktop
- ✅ 拥有有效的支付方式（Google Cloud 提供免费试用）

---

## 🎯 Step 1: 创建 Google Cloud 项目

### 1.1 登录 Google Cloud Console

访问：https://console.cloud.google.com

### 1.2 创建新项目

1. 点击顶部的项目选择器
2. 点击 "新建项目"
3. 输入项目名称：`gayish-backend`
4. 点击 "创建"

### 1.3 记录项目 ID

创建完成后，记下你的 **项目 ID**（例如：`gayish-backend-123456`）

---

## 🎯 Step 2: 启用必要的 API

在终端执行以下命令：

```bash
# 设置项目 ID（替换为你的实际项目 ID）
export PROJECT_ID="gayish-backend-123456"
gcloud config set project $PROJECT_ID

# 启用必要的 API
gcloud services enable cloudbuild.googleapis.com
gcloud services enable run.googleapis.com
gcloud services enable aiplatform.googleapis.com
gcloud services enable containerregistry.googleapis.com
```

等待几分钟，API 启用完成。

---

## 🎯 Step 3: 创建服务账号并配置权限

### 3.1 创建服务账号

```bash
# 创建服务账号
gcloud iam service-accounts create gayish-backend-sa \
  --display-name="Gayish Backend Service Account"
```

### 3.2 授予权限

```bash
# 授予 Vertex AI 用户权限
gcloud projects add-iam-policy-binding $PROJECT_ID \
  --member="serviceAccount:gayish-backend-sa@$PROJECT_ID.iam.gserviceaccount.com" \
  --role="roles/aiplatform.user"

# 授予 Cloud Run 调用权限
gcloud projects add-iam-policy-binding $PROJECT_ID \
  --member="serviceAccount:gayish-backend-sa@$PROJECT_ID.iam.gserviceaccount.com" \
  --role="roles/run.invoker"
```

### 3.3 下载密钥（用于本地开发）

```bash
gcloud iam service-accounts keys create ~/gayish-backend-key.json \
  --iam-account=gayish-backend-sa@$PROJECT_ID.iam.gserviceaccount.com
```

**重要：** 妥善保管此密钥文件！

---

## 🎯 Step 4: 本地测试

### 4.1 设置本地环境

```bash
cd backend

# 设置认证
export GOOGLE_APPLICATION_CREDENTIALS=~/gayish-backend-key.json
export GOOGLE_CLOUD_PROJECT=$PROJECT_ID

# 安装依赖
pip install -r requirements.txt
```

### 4.2 启动本地服务

```bash
python main.py
```

### 4.3 测试接口

打开新终端窗口：

```bash
# 测试健康检查
curl http://localhost:8080/health

# 应该返回：
# {"status":"healthy"}
```

---

## 🎯 Step 5: 构建并推送 Docker 镜像

### 5.1 配置 Docker 认证

```bash
gcloud auth configure-docker
```

### 5.2 构建镜像

```bash
# 确保在 backend 目录
cd backend

# 构建镜像
docker build -t gcr.io/$PROJECT_ID/gayish-backend:v1 .
```

### 5.3 推送到 Google Container Registry

```bash
docker push gcr.io/$PROJECT_ID/gayish-backend:v1
```

---

## 🎯 Step 6: 部署到 Cloud Run

### 6.1 部署服务

```bash
gcloud run deploy gayish-backend \
  --image=gcr.io/$PROJECT_ID/gayish-backend:v1 \
  --platform=managed \
  --region=us-central1 \
  --allow-unauthenticated \
  --service-account=gayish-backend-sa@$PROJECT_ID.iam.gserviceaccount.com \
  --set-env-vars="GOOGLE_CLOUD_PROJECT=$PROJECT_ID,GOOGLE_CLOUD_LOCATION=us-central1" \
  --memory=1Gi \
  --cpu=1 \
  --timeout=300 \
  --min-instances=0 \
  --max-instances=10
```

**参数说明：**
- `--allow-unauthenticated`: 允许公开访问（用于 iOS 应用调用）
- `--memory=1Gi`: 分配 1GB 内存
- `--cpu=1`: 分配 1 个 CPU
- `--timeout=300`: 超时时间 300 秒
- `--min-instances=0`: 无流量时缩减到 0（省钱）
- `--max-instances=10`: 最多 10 个实例

### 6.2 获取服务 URL

部署成功后，会显示服务 URL，类似：

```
https://gayish-backend-xxxxx-uc.a.run.app
```

**保存这个 URL！** 你的 iOS 应用需要用它。

---

## 🎯 Step 7: 测试部署的服务

```bash
# 替换为你的实际 URL
export SERVICE_URL="https://gayish-backend-xxxxx-uc.a.run.app"

# 测试健康检查
curl $SERVICE_URL/health

# 测试图片分析（使用测试图片）
curl -X POST $SERVICE_URL/analyze \
  -F "file=@/path/to/test-image.jpg"
```

---

## 🎯 Step 8: 集成到 iOS 应用

### 8.1 更新 AIAnalysisService.swift

打开 `GayishApp/Services/AIAnalysisService.swift`，修改：

```swift
// 将 API 端点改为你的 Cloud Run URL
private let backendURL = "https://gayish-backend-xxxxx-uc.a.run.app"

func analyzeImage(_ image: UIImage) async throws -> ChatAnalysisResult {
    // 构建请求 URL
    guard let url = URL(string: "\(backendURL)/analyze") else {
        throw NSError(domain: "InvalidURL", code: -1)
    }
    
    // 创建 multipart/form-data 请求
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    
    let boundary = UUID().uuidString
    request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
    
    // 压缩图片
    guard let imageData = image.jpegData(compressionQuality: 0.8) else {
        throw NSError(domain: "ImageCompressionFailed", code: -1)
    }
    
    // 构建 body
    var body = Data()
    
    body.append("--\(boundary)\r\n".data(using: .utf8)!)
    body.append("Content-Disposition: form-data; name=\"file\"; filename=\"image.jpg\"\r\n".data(using: .utf8)!)
    body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
    body.append(imageData)
    body.append("\r\n--\(boundary)--\r\n".data(using: .utf8)!)
    
    request.httpBody = body
    
    // 发送请求
    let (data, response) = try await URLSession.shared.data(for: request)
    
    // 检查响应
    guard let httpResponse = response as? HTTPURLResponse,
          httpResponse.statusCode == 200 else {
        throw NSError(domain: "APIError", code: -1)
    }
    
    // 解析响应
    let decoder = JSONDecoder()
    decoder.keyDecodingStrategy = .convertFromSnakeCase
    let result = try decoder.decode(ChatAnalysisResult.self, from: data)
    
    return result
}
```

### 8.2 更新数据模型

确保 `ChatAnalysisResult` 符合后端返回的格式：

```swift
struct ChatAnalysisResult: Codable {
    let totalScore: Int
    let levelTitle: String
    let breakdown: [BreakdownItem]
    let summary: String
    let rawText: String?
}

struct BreakdownItem: Codable {
    let category: String
    let score: Int
    let quote: String
    let description: String
    let isHighlight: Bool
}
```

---

## 🎯 Step 9: 监控和日志

### 9.1 查看日志

```bash
# 实时查看日志
gcloud run services logs tail gayish-backend --region=us-central1
```

### 9.2 查看指标

访问 Cloud Run Console：
https://console.cloud.google.com/run

查看：
- 请求数
- 延迟
- 错误率
- 内存使用

---

## 💰 成本估算

### Cloud Run 免费额度（每月）

- 2 百万次请求
- 360,000 GB-秒内存
- 180,000 vCPU-秒

### 预估成本（超出免费额度后）

假设每次请求：
- 处理时间：3 秒
- 内存：1GB

**每月 10,000 次请求：**
- 内存成本：$0.30
- CPU 成本：$0.60
- **总计：约 $1.00/月**

**每月 100,000 次请求：**
- **总计：约 $10.00/月**

### Vertex AI 成本

Gemini 2.0 Flash 价格：
- 输入：$0.075 / 百万 tokens
- 输出：$0.30 / 百万 tokens

**预估：每次请求约 $0.001 - $0.005**

---

## 🔄 更新部署

当你修改代码后，重新部署：

```bash
# 1. 构建新镜像
docker build -t gcr.io/$PROJECT_ID/gayish-backend:v2 .

# 2. 推送
docker push gcr.io/$PROJECT_ID/gayish-backend:v2

# 3. 更新服务
gcloud run deploy gayish-backend \
  --image=gcr.io/$PROJECT_ID/gayish-backend:v2 \
  --region=us-central1
```

---

## 🛡️ 安全建议

### 1. 启用身份验证（可选）

如果不想公开 API：

```bash
# 部署时移除 --allow-unauthenticated
gcloud run deploy gayish-backend \
  --image=gcr.io/$PROJECT_ID/gayish-backend:v1 \
  --no-allow-unauthenticated
```

然后在 iOS 应用中添加身份验证 token。

### 2. 添加 API 密钥验证

在 `main.py` 中添加：

```python
from fastapi import Header, HTTPException

API_KEY = os.getenv("API_KEY", "your-secret-key")

@app.post("/analyze")
async def analyze_image(
    file: UploadFile = File(...),
    x_api_key: str = Header(...)
):
    if x_api_key != API_KEY:
        raise HTTPException(status_code=401, detail="Invalid API Key")
    # ... 其余代码
```

### 3. 限流

使用 Cloud Armor 或在代码中添加限流逻辑。

---

## 🐛 常见问题

### Q: 部署失败，提示 "Permission Denied"

**A:** 检查服务账号权限：

```bash
gcloud projects get-iam-policy $PROJECT_ID \
  --flatten="bindings[].members" \
  --filter="bindings.members:serviceAccount:gayish-backend-sa@$PROJECT_ID.iam.gserviceaccount.com"
```

### Q: 请求超时

**A:** 增加超时时间：

```bash
gcloud run services update gayish-backend \
  --timeout=600 \
  --region=us-central1
```

### Q: 内存不足

**A:** 增加内存：

```bash
gcloud run services update gayish-backend \
  --memory=2Gi \
  --region=us-central1
```

---

## 📞 获取帮助

- [Cloud Run 文档](https://cloud.google.com/run/docs)
- [Vertex AI 文档](https://cloud.google.com/vertex-ai/docs)
- [FastAPI 文档](https://fastapi.tiangolo.com/)

---

## ✅ 检查清单

完成部署后，确认：

- [ ] Cloud Run 服务正常运行
- [ ] 健康检查接口返回 200
- [ ] 能成功调用 `/analyze` 接口
- [ ] iOS 应用能连接到后端
- [ ] 日志正常输出
- [ ] 成本在预算范围内

---

**🎉 恭喜！你的 Gayish Backend 已成功部署到 Google Cloud！**
