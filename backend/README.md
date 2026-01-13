# Gayish Backend API

基于 FastAPI + Vertex AI 的后端服务，为 Gayish iOS 应用提供 AI 分析功能。

## 🏗️ 架构说明

```
iOS App (Gayish)
    ↓
    ↓ HTTPS POST /analyze
    ↓
FastAPI Backend (Cloud Run)
    ↓
    ↓ 调用 Vertex AI API
    ↓
Google Cloud Vertex AI
```

## 📋 功能列表

- ✅ 接收图片上传（文件或 Base64）
- ✅ 调用 Vertex AI Gemini 模型分析
- ✅ 解析 AI 响应并结构化返回
- ✅ CORS 支持（允许 iOS 应用跨域）
- ✅ 健康检查接口
- ✅ Docker 容器化
- ✅ 适配 Google Cloud Run 部署

## 🚀 快速开始

### 本地开发

1. **安装依赖**
```bash
cd backend
pip install -r requirements.txt
```

2. **配置环境变量**
```bash
cp .env.example .env
# 编辑 .env 文件，填入你的 Google Cloud 项目 ID
```

3. **设置 Google Cloud 认证**
```bash
# 下载服务账号密钥并设置环境变量
export GOOGLE_APPLICATION_CREDENTIALS="/path/to/your-key.json"
```

4. **启动服务**
```bash
python main.py
```

服务将在 http://localhost:8080 启动

### Docker 本地测试

```bash
# 构建镜像
docker build -t gayish-backend .

# 运行容器
docker run -p 8080:8080 \
  -e GOOGLE_CLOUD_PROJECT=your-project-id \
  -e GOOGLE_APPLICATION_CREDENTIALS=/app/key.json \
  -v /path/to/your-key.json:/app/key.json \
  gayish-backend
```

## 📡 API 接口

### 1. 健康检查

```http
GET /
GET /health
```

**响应示例：**
```json
{
  "status": "ok",
  "service": "Gayish API",
  "version": "1.0.0",
  "vertex_ai_enabled": true
}
```

### 2. 分析图片（文件上传）

```http
POST /analyze
Content-Type: multipart/form-data
```

**请求参数：**
- `file`: 图片文件（JPEG/PNG）

**响应示例：**
```json
{
  "total_score": 9,
  "level_title": "Drama Queen",
  "breakdown": [
    {
      "category": "基础得分",
      "score": 2,
      "quote": "对话内容引用",
      "description": "分析说明",
      "isHighlight": false
    },
    {
      "category": "进阶得分",
      "score": 2,
      "quote": "对话内容引用",
      "description": "分析说明",
      "isHighlight": false
    },
    {
      "category": "灵魂得分",
      "score": 3,
      "quote": "对话内容引用",
      "description": "这是最Gay的部分",
      "isHighlight": true
    },
    {
      "category": "附加分",
      "score": 2,
      "quote": "对话内容引用",
      "description": "分析说明",
      "isHighlight": false
    }
  ],
  "summary": "总体评价内容",
  "raw_text": "AI 返回的原始文本"
}
```

### 3. 分析图片（Base64）

```http
POST /analyze-base64
Content-Type: application/json
```

**请求体：**
```json
{
  "image_base64": "base64编码的图片数据",
  "mime_type": "image/jpeg"
}
```

**响应格式：** 同上

## 🧪 测试接口

使用 curl 测试：

```bash
# 测试健康检查
curl http://localhost:8080/health

# 测试图片分析
curl -X POST http://localhost:8080/analyze \
  -F "file=@/path/to/your/image.jpg"
```

## 📦 部署到 Google Cloud Run

详见：[DEPLOYMENT_GUIDE.md](./DEPLOYMENT_GUIDE.md)

## 🔧 技术栈

- **框架**: FastAPI 0.109.0
- **AI 服务**: Google Cloud Vertex AI
- **Python**: 3.11+
- **部署**: Google Cloud Run
- **容器**: Docker

## 📝 环境变量

| 变量名 | 说明 | 默认值 |
|--------|------|--------|
| `GOOGLE_CLOUD_PROJECT` | Google Cloud 项目 ID | - |
| `GOOGLE_CLOUD_LOCATION` | Vertex AI 区域 | us-central1 |
| `PORT` | 服务端口 | 8080 |

## 🐛 故障排查

### 问题：403 权限错误

**原因：** 服务账号没有 Vertex AI 权限

**解决方案：**
```bash
# 为服务账号添加 Vertex AI 角色
gcloud projects add-iam-policy-binding YOUR_PROJECT_ID \
  --member="serviceAccount:YOUR_SERVICE_ACCOUNT@YOUR_PROJECT_ID.iam.gserviceaccount.com" \
  --role="roles/aiplatform.user"
```

### 问题：找不到模型

**原因：** Vertex AI 区域不支持该模型

**解决方案：**
- 检查 `GOOGLE_CLOUD_LOCATION` 是否正确
- 尝试使用 `us-central1` 或 `us-west1`
- 或更换模型名称为 `gemini-1.5-pro`

### 问题：请求超时

**原因：** 图片太大或网络慢

**解决方案：**
- 在客户端压缩图片
- 增加超时时间

## 📄 许可证

MIT License
