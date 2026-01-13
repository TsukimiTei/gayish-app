# Vercel 环境变量配置指南

根据你当前使用的 `google-genai` SDK，以下是完整的环境变量配置说明。

---

## 🔑 方式 1: 使用 API Key（推荐，最简单）

### 需要的环境变量

只需配置 **1 个**环境变量：

```
GEMINI_API_KEY=你的API密钥
```

### 如何获取 GEMINI_API_KEY

#### 方法 A: 使用 Google AI Studio（最简单）

1. **访问 AI Studio**
   ```
   https://aistudio.google.com/app/apikey
   ```

2. **创建 API Key**
   - 点击 "Create API key"
   - 选择一个 Google Cloud 项目（或创建新项目）
   - 复制生成的 API Key

3. **API Key 格式**
   ```
   AIzaSyAbc123def456ghi789jkl012mno345pqr678
   ```

#### 方法 B: 使用 Google Cloud Console

1. **打开 API & Services**
   ```
   https://console.cloud.google.com/apis/credentials
   ```

2. **创建凭据**
   - 点击 "Create Credentials"
   - 选择 "API key"
   - 复制生成的密钥

3. **限制 API Key（推荐）**
   - 点击刚创建的 API Key 编辑
   - API restrictions → 选择 "Restrict key"
   - 只允许：
     - ✅ Generative Language API
     - ✅ Vertex AI API
   - 保存

### 在 Vercel 中配置

1. **进入 Vercel Dashboard**
   ```
   https://vercel.com/dashboard
   ```

2. **选择你的项目** → **Settings** → **Environment Variables**

3. **添加环境变量**

   | Name | Value | Environment |
   |------|-------|-------------|
   | `GEMINI_API_KEY` | `AIzaSyAbc123...`（你的实际密钥） | All (Production, Preview, Development) |

4. **点击 "Save"**

5. **重新部署**
   - 回到 "Deployments" 标签
   - 点击最新部署的 "..." 菜单
   - 选择 "Redeploy"

---

## 🔐 方式 2: 使用服务账号（企业级）

如果你需要更细粒度的权限控制，可以使用服务账号。

### 需要的环境变量（3 个）

```
GOOGLE_CLOUD_PROJECT=你的项目ID
GOOGLE_CLOUD_LOCATION=us-central1
GOOGLE_APPLICATION_CREDENTIALS_JSON=服务账号JSON内容
```

### 步骤 1: 创建服务账号

```bash
# 1. 设置项目
export PROJECT_ID="你的项目ID"
gcloud config set project $PROJECT_ID

# 2. 启用 API
gcloud services enable aiplatform.googleapis.com
gcloud services enable generativelanguage.googleapis.com

# 3. 创建服务账号
gcloud iam service-accounts create gayish-vercel \
  --display-name="Gayish Vercel Service Account"

# 4. 授予权限
gcloud projects add-iam-policy-binding $PROJECT_ID \
  --member="serviceAccount:gayish-vercel@$PROJECT_ID.iam.gserviceaccount.com" \
  --role="roles/aiplatform.user"

# 5. 下载密钥
gcloud iam service-accounts keys create ~/gayish-key.json \
  --iam-account=gayish-vercel@$PROJECT_ID.iam.gserviceaccount.com
```

### 步骤 2: 在 Vercel 配置

| Name | Value | Environment |
|------|-------|-------------|
| `GOOGLE_CLOUD_PROJECT` | `你的项目ID` | All |
| `GOOGLE_CLOUD_LOCATION` | `us-central1` | All |
| `GOOGLE_APPLICATION_CREDENTIALS_JSON` | `复制 ~/gayish-key.json 的全部内容` | All |

### 步骤 3: 修改代码

你需要修改 `backend/api/analyze.py` 来使用服务账号：

```python
# 配置
GEMINI_API_KEY = os.getenv("GEMINI_API_KEY", "")
PROJECT_ID = os.getenv("GOOGLE_CLOUD_PROJECT", "")
LOCATION = os.getenv("GOOGLE_CLOUD_LOCATION", "us-central1")

# 初始化客户端
genai_client = None

if GEMINI_API_KEY:
    # 使用 API Key 模式
    try:
        http_options = HttpOptions(api_version="v1")
        genai_client = genai.Client(api_key=GEMINI_API_KEY, http_options=http_options)
    except Exception as e:
        print(f"Failed to initialize GenAI client with API key: {e}")
        
elif PROJECT_ID:
    # 使用服务账号模式
    creds_json = os.getenv("GOOGLE_APPLICATION_CREDENTIALS_JSON")
    if creds_json:
        import tempfile
        with tempfile.NamedTemporaryFile(mode='w', suffix='.json', delete=False) as f:
            f.write(creds_json)
            os.environ['GOOGLE_APPLICATION_CREDENTIALS'] = f.name
        
        try:
            # 使用 Vertex AI 客户端
            import vertexai
            from vertexai.generative_models import GenerativeModel
            vertexai.init(project=PROJECT_ID, location=LOCATION)
            # ... 使用 vertexai 的代码
        except Exception as e:
            print(f"Failed to initialize Vertex AI: {e}")
```

---

## 🎯 推荐配置

### ✅ 个人项目 / 快速开始

**使用方式 1: API Key**

只需配置：
```
GEMINI_API_KEY=AIzaSy...
```

**优点：**
- 最简单，只需 1 个环境变量
- 5 分钟完成配置
- 适合开发和测试

### 🏢 企业项目 / 生产环境

**使用方式 2: 服务账号**

配置 3 个环境变量：
```
GOOGLE_CLOUD_PROJECT=...
GOOGLE_CLOUD_LOCATION=...
GOOGLE_APPLICATION_CREDENTIALS_JSON=...
```

**优点：**
- 更细粒度的权限控制
- 更好的安全性
- 符合企业安全规范

---

## 🧪 测试配置

### 本地测试

```bash
# 设置环境变量
export GEMINI_API_KEY="你的API密钥"

# 运行 Vercel 开发服务器
cd backend
vercel dev

# 测试健康检查
curl http://localhost:3000/api/health
```

### Vercel 部署后测试

```bash
# 测试健康检查
curl https://your-app.vercel.app/api/health

# 应该返回
{
  "status": "ok",
  "service": "Gayish API",
  "version": "1.0.0",
  "platform": "Vercel",
  "genai_sdk_available": true,
  "configured": true
}
```

如果 `"configured": false`，说明环境变量没有正确配置。

---

## 🐛 常见问题

### Q1: 显示 "GenAI client not initialized"

**原因：** `GEMINI_API_KEY` 未设置或无效

**解决：**
1. 检查 Vercel 环境变量是否正确配置
2. 确认 API Key 格式正确（以 `AIza` 开头）
3. 确认 API Key 没有过期
4. 重新部署项目

### Q2: 401 Unauthorized 错误

**原因：** API Key 无权限或项目未启用 API

**解决：**
```bash
# 启用必要的 API
gcloud services enable generativelanguage.googleapis.com
gcloud services enable aiplatform.googleapis.com
```

### Q3: 403 Permission Denied

**原因：** API Key 没有访问 Vertex AI 的权限

**解决：**
1. 在 Google Cloud Console 检查 API Key 的限制
2. 确保启用了正确的 API
3. 或者使用服务账号方式

### Q4: 如何查看是否配置成功？

访问：
```
https://your-app.vercel.app/api/health
```

检查返回的 JSON：
- `"genai_sdk_available": true` - SDK 已安装 ✅
- `"configured": true` - 环境变量已配置 ✅

---

## 📝 快速配置清单

- [ ] 获取 GEMINI_API_KEY（从 AI Studio 或 Cloud Console）
- [ ] 在 Vercel 添加环境变量 `GEMINI_API_KEY`
- [ ] 重新部署 Vercel 项目
- [ ] 测试 `/api/health` 接口
- [ ] 测试 `/api/analyze` 接口
- [ ] 更新 iOS 应用中的 API 地址

---

## 🔗 相关链接

- [Google AI Studio](https://aistudio.google.com/app/apikey) - 获取 API Key
- [Google Cloud Console - API Keys](https://console.cloud.google.com/apis/credentials) - 管理 API Key
- [Vercel Environment Variables](https://vercel.com/docs/projects/environment-variables) - Vercel 文档
- [Google GenAI SDK](https://googleapis.github.io/python-genai/) - SDK 文档

---

**🎉 配置完成后，你的后端就可以正常工作了！**
