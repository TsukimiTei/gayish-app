# Gayish Backend API 🌈

为 Gayish iOS 应用提供 AI 分析功能的后端服务，基于 Vertex AI。

---

## 📊 部署方案对比

我为你准备了**两种部署方案**，选择最适合你的：

| 对比项 | ✅ Vercel（推荐） | Google Cloud Run |
|--------|------------------|------------------|
| **难度** | ⭐ 超简单 | ⭐⭐⭐ 中等 |
| **部署时间** | 5 分钟 | 30 分钟 |
| **需要 Docker** | ❌ 不需要 | ✅ 需要 |
| **自动部署** | ✅ Push 即部署 | ❌ 需手动构建 |
| **免费额度** | 10万次请求/月 | 200万次请求/月 |
| **冷启动** | ~1-2 秒 | ~2-3 秒 |
| **全球 CDN** | ✅ 内置 | ❌ 需额外配置 |
| **日志查看** | ✅ 实时面板 | ✅ Cloud Logging |
| **适合场景** | 个人项目、快速原型 | 企业应用、高流量 |

---

## 🎯 推荐方案：Vercel

### 为什么选择 Vercel？

1. **超级简单**：连接 GitHub，自动部署，零配置
2. **完全免费**：对于大多数个人项目，永久免费
3. **开发体验好**：实时日志，一键回滚，自动 HTTPS
4. **全球加速**：内置 CDN，访问速度快

### 快速开始

查看：**[QUICK_START.md](./QUICK_START.md)** - 5 分钟完成部署！

### 详细指南

查看：**[VERCEL_DEPLOYMENT.md](./VERCEL_DEPLOYMENT.md)** - 完整的分步教程

---

## 🏢 企业方案：Google Cloud Run

### 什么时候选择 Cloud Run？

1. **高流量**：每月超过 10 万次请求
2. **企业需求**：需要 SLA 保证和技术支持
3. **复杂部署**：需要自定义运行环境
4. **已有 GCP**：公司已在使用 Google Cloud

### 详细指南

查看：**[DEPLOYMENT_GUIDE.md](./DEPLOYMENT_GUIDE.md)** - Cloud Run 完整部署流程

---

## 📁 项目结构

```
backend/
├── api/                          # Vercel Serverless Functions
│   ├── analyze.py               # 图片分析接口
│   └── health.py                # 健康检查接口
├── main.py                      # Cloud Run 完整应用
├── Dockerfile                   # Cloud Run 容器配置
├── requirements.txt             # Cloud Run 依赖
├── requirements-vercel.txt      # Vercel 依赖
├── vercel.json                  # Vercel 配置文件
├── QUICK_START.md              # ⚡ 5分钟快速开始
├── VERCEL_DEPLOYMENT.md        # 📦 Vercel 详细部署
├── DEPLOYMENT_GUIDE.md         # 🏢 Cloud Run 部署
└── README_CN.md                # 本文件
```

---

## 🔧 技术架构

### 整体架构

```
┌─────────────────┐
│   iOS 应用      │
│   (Gayish)      │
└────────┬────────┘
         │ HTTPS POST /api/analyze
         │ (image_base64 + mime_type)
         ↓
┌─────────────────┐
│  后端 API       │
│  (Vercel/       │
│   Cloud Run)    │
└────────┬────────┘
         │ gRPC
         ↓
┌─────────────────┐
│ Google Cloud    │
│ Vertex AI       │
│ (Gemini 2.0)    │
└─────────────────┘
```

### API 接口

#### 1. 健康检查

```http
GET /api/health
```

响应：
```json
{
  "status": "healthy",
  "service": "Gayish API"
}
```

#### 2. 图片分析

```http
POST /api/analyze
Content-Type: application/json

{
  "image_base64": "base64编码的图片数据",
  "mime_type": "image/jpeg"
}
```

响应：
```json
{
  "total_score": 9,
  "level_title": "Drama Queen",
  "breakdown": [
    {
      "category": "基础得分",
      "score": 2,
      "quote": "对话引用",
      "description": "分析说明",
      "isHighlight": false
    }
  ],
  "summary": "总体评价",
  "raw_text": "AI原始返回"
}
```

---

## 💰 成本估算

### Vercel 方案

**免费额度（每月）：**
- ✅ 100,000 次函数调用
- ✅ 100GB 带宽
- ✅ 100 小时执行时间

**超出后价格：**
- 函数调用：$2.00 / 百万次
- 带宽：$40 / TB

**Vertex AI 成本：**
- 每次分析：约 $0.0006
- 1000 次：$0.60
- 10000 次：$6.00

**总成本示例（每月 5000 次分析）：**
- Vercel: $0（免费额度内）
- Vertex AI: $3.00
- **总计：$3.00/月**

### Cloud Run 方案

**免费额度（每月）：**
- ✅ 2,000,000 次请求
- ✅ 360,000 GB-秒内存
- ✅ 180,000 vCPU-秒

**超出后价格：**
- 请求：$0.40 / 百万次
- 内存：$0.0000025 / GB-秒
- CPU：$0.00001 / vCPU-秒

**总成本示例（每月 5000 次分析）：**
- Cloud Run: $0（免费额度内）
- Vertex AI: $3.00
- **总计：$3.00/月**

---

## 🧪 本地开发

### 环境准备

```bash
cd backend

# 安装依赖
pip install -r requirements.txt

# 配置环境变量
export GOOGLE_CLOUD_PROJECT="your-project-id"
export GOOGLE_CLOUD_LOCATION="us-central1"
export GOOGLE_APPLICATION_CREDENTIALS="/path/to/key.json"
```

### 运行 FastAPI 版本（Cloud Run）

```bash
python main.py
```

访问：http://localhost:8080

### 运行 Vercel 版本（本地模拟）

```bash
# 安装 Vercel CLI
npm install -g vercel

# 启动本地开发服务器
vercel dev
```

访问：http://localhost:3000

---

## 📝 环境变量说明

| 变量名 | 说明 | 示例值 |
|--------|------|--------|
| `GOOGLE_CLOUD_PROJECT` | GCP 项目 ID | `gayish-backend-123456` |
| `GOOGLE_CLOUD_LOCATION` | Vertex AI 区域 | `us-central1` |
| `GOOGLE_APPLICATION_CREDENTIALS` | 密钥文件路径（本地/Cloud Run） | `/app/key.json` |
| `GOOGLE_APPLICATION_CREDENTIALS_JSON` | 密钥 JSON 内容（Vercel） | `{"type":"service_account",...}` |

---

## 🔒 安全建议

### 1. 保护 API 密钥

```python
# 在代码中添加 API Key 验证
API_KEY = os.getenv("API_KEY")

if request_api_key != API_KEY:
    return {"error": "Unauthorized"}, 401
```

### 2. 限制请求频率

使用 Redis 或内存缓存实现简单的限流：

```python
# 每个 IP 每分钟最多 10 次请求
from collections import defaultdict
import time

request_counts = defaultdict(list)

def rate_limit(ip_address, limit=10, window=60):
    now = time.time()
    # 清理过期记录
    request_counts[ip_address] = [
        t for t in request_counts[ip_address] 
        if now - t < window
    ]
    # 检查限制
    if len(request_counts[ip_address]) >= limit:
        return False
    request_counts[ip_address].append(now)
    return True
```

### 3. 验证图片大小

```python
MAX_IMAGE_SIZE = 10 * 1024 * 1024  # 10MB

if len(image_data) > MAX_IMAGE_SIZE:
    return {"error": "图片过大"}, 400
```

---

## 🐛 故障排查

### 问题：API 返回 500 错误

**检查步骤：**
1. 查看日志（Vercel 或 Cloud Run）
2. 确认环境变量是否正确配置
3. 测试 Vertex AI 权限

```bash
# 测试 Vertex AI 连接
gcloud auth application-default login
python -c "
import vertexai
from vertexai.generative_models import GenerativeModel
vertexai.init(project='YOUR_PROJECT_ID', location='us-central1')
model = GenerativeModel('gemini-2.0-flash-exp')
print('成功连接 Vertex AI！')
"
```

### 问题：请求超时

**原因：** 图片太大或网络慢

**解决方案：**
1. 在客户端压缩图片（质量 0.5-0.7）
2. 使用更快的模型
3. 增加超时时间

### 问题：403 权限错误

**检查权限：**

```bash
# 查看服务账号权限
gcloud projects get-iam-policy YOUR_PROJECT_ID \
  --flatten="bindings[].members" \
  --filter="bindings.role:roles/aiplatform.user"
```

---

## 📚 相关文档

- [Vertex AI 文档](https://cloud.google.com/vertex-ai/docs)
- [Vercel 文档](https://vercel.com/docs)
- [FastAPI 文档](https://fastapi.tiangolo.com/)
- [Cloud Run 文档](https://cloud.google.com/run/docs)

---

## 🤝 贡献

欢迎提交 Issue 和 Pull Request！

---

## 📄 许可证

MIT License

---

## 📞 需要帮助？

1. **查看文档**：先查阅本目录下的详细指南
2. **查看日志**：大部分问题都能从日志找到原因
3. **搜索错误**：Google/Stack Overflow 是你的朋友
4. **提交 Issue**：描述问题 + 日志 + 复现步骤

---

**祝你部署顺利！🌈**
