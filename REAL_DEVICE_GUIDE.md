# 真机运行指南 📱

## ❌ 遇到的错误

```
error: Signing for "Gayish" requires a development team. 
Select a development team in the Signing & Capabilities editor.
```

## ✅ 解决方案

### 方式一：使用 Xcode（推荐）

#### 1. 在 Xcode 中打开项目
```bash
open Gayish.xcodeproj
```

#### 2. 配置签名
```
1. 选择项目 "Gayish" (左侧导航)
2. 选择 Target "Gayish"
3. 点击 "Signing & Capabilities" 标签
4. ✅ 勾选 "Automatically manage signing"
5. 选择你的 Team（Apple ID 或开发者账号）
```

#### 3. 连接真机并运行
```
1. 用数据线连接 iPhone
2. 在 Xcode 顶部选择你的 iPhone
3. 点击运行按钮 ▶️
4. 首次运行需要在 iPhone 上信任开发者：
   设置 → 通用 → VPN与设备管理 → 信任
```

---

### 方式二：在 Cursor 中配置（如果有 Apple Developer 账号）

#### 1. 获取你的 Team ID

在终端运行：
```bash
# 方法1：使用 security 命令
security find-identity -v -p codesigning

# 方法2：登录 Apple Developer 网站
# https://developer.apple.com/account
# 在 Membership 页面查看 Team ID
```

#### 2. 修改 project.yml

```yaml
settings:
  DEVELOPMENT_TEAM: "YOUR_TEAM_ID"  # 填入你的 Team ID
  CODE_SIGN_STYLE: Automatic
  CODE_SIGN_IDENTITY: "iPhone Developer"
```

#### 3. 重新生成项目
```bash
cd "/Users/mac/iCloud Drive (Archive) - 1/Documents/Documents - bluerose/Demohive/gayish"
xcodegen generate
```

#### 4. 在 Cursor 中运行
```
⌘ + R
选择你的真机设备
```

---

### 方式三：免费 Apple ID（个人开发）

#### 1. 在 Xcode 中添加 Apple ID

```
Xcode → Settings → Accounts
点击 "+" → Apple ID
登录你的 Apple ID（免费）
```

#### 2. 选择团队

返回项目的 Signing & Capabilities：
```
Team 下拉菜单 → 选择你的 Apple ID (Personal Team)
```

#### 3. 修改 Bundle Identifier（重要！）

免费账号需要唯一的 Bundle ID：
```
Bundle Identifier: com.yourname.gayish
（不能用别人已注册的 ID）
```

#### 4. 运行到真机
```
连接 iPhone → 选择设备 → 运行
```

---

## 📝 详细步骤（Xcode 方式）

### Step 1: 打开 Xcode
```bash
cd "/Users/mac/iCloud Drive (Archive) - 1/Documents/Documents - bluerose/Demohive/gayish"
open Gayish.xcodeproj
```

### Step 2: 配置签名

#### 2.1 选择项目
- 左侧导航栏点击 "Gayish" 项目（最顶部蓝色图标）

#### 2.2 选择 Target
- 在中间 TARGETS 列表中选择 "Gayish"

#### 2.3 配置自动签名
```
在 "Signing & Capabilities" 标签中：

✅ Automatically manage signing

Team: 
├─ 如果有 Apple Developer 账号
│  └─ 选择你的开发者团队
│
└─ 如果没有（使用免费账号）
   ├─ 点击 "Add Account..."
   ├─ 登录你的 Apple ID
   └─ 选择 "Your Name (Personal Team)"

⚠️ 如果使用免费账号，需要修改：
Bundle Identifier: com.yourname.gayish
（改成你自己的唯一 ID）
```

### Step 3: 连接真机

#### 3.1 连接 iPhone
- 用 USB 数据线连接 Mac 和 iPhone
- iPhone 上点击"信任此电脑"

#### 3.2 选择设备
- Xcode 顶部中间，点击设备选择器
- 选择你的 iPhone（如 "Yinong's iPhone"）

#### 3.3 运行
- 点击 ▶️ 按钮
- 等待构建和安装

### Step 4: 信任开发者证书（首次运行）

在 iPhone 上：
```
设置 
  → 通用 
    → VPN与设备管理 
      → 开发者 App 
        → 你的 Apple ID 
          → 信任
```

然后返回主屏幕，App 就可以正常打开了！

---

## 🆚 模拟器 vs 真机

| 特性 | 模拟器 | 真机 |
|------|--------|------|
| **签名要求** | ❌ 不需要 | ✅ 需要 |
| **Apple ID** | ❌ 不需要 | ✅ 需要 |
| **相机功能** | ❌ 不支持 | ✅ 支持 |
| **性能** | 较慢 | 更快 |
| **网络** | Mac 网络 | 真实网络 |

---

## 💡 推荐方案

### 开发测试阶段
```
✅ 使用模拟器
   - 无需签名配置
   - 快速迭代
   - 已开启模拟数据模式
```

### 真机测试阶段
```
✅ 使用 Xcode
   1. open Gayish.xcodeproj
   2. 配置自动签名
   3. 选择真机运行
```

---

## 🔧 快速解决方案

### 最简单的方法（2 分钟）

```bash
# 1. 打开 Xcode
open Gayish.xcodeproj

# 2. 在 Xcode 中：
#    - 选择项目
#    - Signing & Capabilities
#    - ✅ Automatically manage signing
#    - 选择你的 Apple ID

# 3. 连接 iPhone 并运行
```

---

## ❓ 常见问题

### Q1: 没有 Apple Developer 账号怎么办？
**A:** 使用免费的 Apple ID 即可！
```
1. 在 Xcode 中添加 Apple ID
2. 选择 Personal Team
3. 修改 Bundle ID 为你自己的
4. 可以在真机运行（有效期 7 天）
```

### Q2: Bundle Identifier 已被占用？
**A:** 改成你自己的唯一 ID：
```yaml
# project.yml
PRODUCT_BUNDLE_IDENTIFIER: com.yourname.gayish
```

### Q3: 证书过期怎么办？
**A:** 免费账号证书 7 天后过期，重新运行即可自动更新。

### Q4: 能在 Cursor 中直接运行真机吗？
**A:** 可以，但需要先在 Xcode 中配置好签名，之后就能在 Cursor 中运行。

---

## 🎯 现在开始

### 推荐流程：

```bash
# 1. 继续使用模拟器开发（无需签名）
⌘ + R

# 2. 需要真机测试时，在 Xcode 中配置
open Gayish.xcodeproj
```

---

**有问题随时告诉我！** 📱✨
