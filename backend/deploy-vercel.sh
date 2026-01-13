#!/bin/bash

# Vercel 部署脚本
# 使用方法: ./deploy-vercel.sh

echo "🚀 开始部署 Gayish Backend 到 Vercel..."
echo ""

# 检查是否安装了 vercel CLI
if ! command -v vercel &> /dev/null; then
    echo "❌ 未检测到 Vercel CLI"
    echo "正在安装 Vercel CLI..."
    npm install -g vercel
fi

# 检查环境变量文件
if [ ! -f ".env.vercel" ]; then
    echo "⚠️  未找到 .env.vercel 文件"
    echo "请创建 .env.vercel 文件，包含以下内容："
    echo ""
    echo "GOOGLE_CLOUD_PROJECT=your-project-id"
    echo "GOOGLE_CLOUD_LOCATION=us-central1"
    echo "GOOGLE_APPLICATION_CREDENTIALS_JSON={...json content...}"
    echo ""
    exit 1
fi

# 读取环境变量
source .env.vercel

echo "✅ 环境变量已加载"
echo "📦 项目 ID: $GOOGLE_CLOUD_PROJECT"
echo ""

# 部署到 Vercel
echo "🚢 正在部署到 Vercel..."
vercel --prod

echo ""
echo "✅ 部署完成！"
echo ""
echo "📝 后续步骤："
echo "1. 在 Vercel Dashboard 配置环境变量"
echo "2. 测试 API: curl https://your-app.vercel.app/api/health"
echo "3. 更新 iOS 应用中的 API 地址"
echo ""
