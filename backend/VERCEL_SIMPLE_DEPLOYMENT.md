# 🚀 Vercel 部署指南（超简单版 - 仅需 1 个环境变量）

使用 Google GenAI SDK + Vertex AI 模式，配置超级简单！

---

## ✨ 优势

- ✅ **只需 1 个环境变量**：`GEMINI_API_KEY`
- ✅ **仍然使用 Vertex AI**：性能和功能完全相同
- ✅ **无需服务账号 JSON**：不需要复杂的 Google Cloud 配置
- ✅ **部署更快**：5 分钟搞定

---

## 📋 Vercel 环境变量配置

### 唯一需要的环境变量：

#### **GEMINI_API_KEY**
- **Key**: `GEMINI_API_KEY`
- **Value**: `AQ.Ab8RN6JJlq7fPmqoeYA3NYD1mZrZ9amifF-8NKh8u4WcIs-FmA`
- **Environment**: All (Production, Preview, Development)

就这么简单！✨

---

## 🎯 部署步骤

### 1. 推送代码到 GitHub

```bash
cd "/Users/mac/iCloud Drive (Archive) - 1/Documents/Documents - bluerose/Demohive/gayish"

# 添加后端代码
git add backend/

# 提交
git commit -m "Add Vercel backend with GenAI SDK + Vertex AI"

# 推送
git push origin main
```

### 2. 部署到 Vercel

1. 访问 https://vercel.com/new
2. 导入你的 GitHub 仓库
3. 配置项目设置：
   - **Framework Preset**: Other
   - **Root Directory**: `backend`
   - **Build Command**: 留空
   - **Output Directory**: 留空

4. **添加环境变量**（重要！）：
   - 点击 "Environment Variables"
   - Key: `GEMINI_API_KEY`
   - Value: `AQ.Ab8RN6JJlq7fPmqoeYA3NYD1mZrZ9amifF-8NKh8u4WcIs-FmA`
   - Environment: All

5. 点击 **Deploy**

等待 1-2 分钟，部署完成！🎉

---

## 🧪 测试 API

### 健康检查

```bash
curl https://your-app.vercel.app/api/analyze
```

应该返回：
```json
{
  "status": "ok",
  "service": "Gayish API",
  "version": "1.0.0",
  "platform": "Vercel",
  "genai_sdk_available": true,
  "configured": true
}
```

### 测试图片分析

```bash
# 将图片转为 Base64
BASE64_IMAGE=$(base64 -i your-image.jpg)

# 发送请求
curl -X POST https://your-app.vercel.app/api/analyze \
  -H "Content-Type: application/json" \
  -d "{\"image_base64\": \"$BASE64_IMAGE\", \"mime_type\": \"image/jpeg\"}"
```

---

## 🔧 技术原理

### 代码如何使用 Vertex AI

```python
# 1. 导入 GenAI SDK
from google import genai
from google.genai.types import HttpOptions, Part, Blob, GenerateContentConfig

# 2. 启用 Vertex AI 模式
os.environ["GOOGLE_GENAI_USE_VERTEXAI"] = "True"

# 3. 初始化客户端（使用 API Key）
http_options = HttpOptions(api_version="v1")
client = genai.Client(api_key=GEMINI_API_KEY, http_options=http_options)

# 4. 调用 API（实际调用的是 Vertex AI 端点）
response = client.models.generate_content(
    model="gemini-2.0-flash-exp",
    contents=[...],
    config=GenerateContentConfig(...)
)
```

### 关键设置

```python
os.environ["GOOGLE_GENAI_USE_VERTEXAI"] = "True"
```

这一行代码让 GenAI SDK 使用 **Vertex AI 的 API 端点**，而不是普通的 Gemini API 端点。

---

## 🆚 与传统 Vertex AI 方式对比

| 项目 | 传统方式 | GenAI SDK 方式 |
|------|---------|---------------|
| **环境变量数量** | 3 个 | 1 个 ✅ |
| **需要服务账号** | 是 | 否 ✅ |
| **需要 project_id** | 是 | 否 ✅ |
| **API 端点** | Vertex AI | Vertex AI ✅ |
| **功能和性能** | 完全相同 | 完全相同 ✅ |
| **配置复杂度** | 高 | 低 ✅ |

---

## 📦 依赖文件

### requirements-vercel.txt

```
google-genai
```

就这一个依赖！

---

## 🐛 故障排查

### 问题 1: "GenAI SDK not available"

**解决方案**：
- 确认 `requirements-vercel.txt` 中有 `google-genai`
- 在 Vercel 中重新部署

### 问题 2: "GenAI client not initialized"

**解决方案**：
- 检查环境变量 `GEMINI_API_KEY` 是否正确设置
- 确认 API Key 值正确

### 问题 3: 500 错误

**解决方案**：
- 查看 Vercel 部署日志
- 检查 API Key 是否有效
- 确认模型名称 `gemini-2.0-flash-exp` 可用

---

## 📝 完整的 API 文件

查看 `backend/api/analyze.py` 获取完整代码。

关键部分：

```python
# 初始化
http_options = HttpOptions(api_version="v1")
genai_client = genai.Client(api_key=GEMINI_API_KEY, http_options=http_options)

# 分析图片
parts = [
    Part(text=SYSTEM_PROMPT),
    Part(inline_data=Blob(mime_type=mime_type, data=image_data))
]

config = GenerateContentConfig(
    temperature=0.7,
    top_k=32,
    top_p=0.95,
    max_output_tokens=2048,
)

response = genai_client.models.generate_content(
    model=MODEL_NAME,
    contents=parts,
    config=config,
)
```

---

## ✅ 完成检查清单

- [ ] 推送代码到 GitHub
- [ ] 在 Vercel 导入项目
- [ ] 设置 Root Directory 为 `backend`
- [ ] 添加环境变量 `GEMINI_API_KEY`
- [ ] 点击 Deploy
- [ ] 测试 `/api/analyze` 接口
- [ ] 集成到 iOS 应用

---

## 🎉 大功告成！

你的后端现在使用：
- ✅ Google GenAI SDK
- ✅ Vertex AI 模式
- ✅ 只需 1 个环境变量
- ✅ 超级简单的配置

**下一步**：在 iOS 应用中更新 API 地址到你的 Vercel URL！
