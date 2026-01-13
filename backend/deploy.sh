#!/bin/bash

# Gayish Backend 快速部署脚本

set -e

echo "🚀 开始部署 Gayish Backend 到 Google Cloud Run..."

# 检查是否设置了项目 ID
if [ -z "$PROJECT_ID" ]; then
    echo "❌ 错误：请先设置 PROJECT_ID 环境变量"
    echo "   export PROJECT_ID=your-project-id"
    exit 1
fi

# 设置变量
REGION="us-central1"
SERVICE_NAME="gayish-backend"
IMAGE_NAME="gcr.io/$PROJECT_ID/$SERVICE_NAME"
VERSION=${VERSION:-"v$(date +%s)"}

echo "📋 配置信息："
echo "   项目 ID: $PROJECT_ID"
echo "   区域: $REGION"
echo "   服务名: $SERVICE_NAME"
echo "   镜像版本: $VERSION"

# 1. 配置项目
echo ""
echo "1️⃣ 配置 gcloud 项目..."
gcloud config set project $PROJECT_ID

# 2. 启用必要的 API
echo ""
echo "2️⃣ 启用必要的 API..."
gcloud services enable cloudbuild.googleapis.com
gcloud services enable run.googleapis.com
gcloud services enable aiplatform.googleapis.com
gcloud services enable containerregistry.googleapis.com

# 3. 构建 Docker 镜像
echo ""
echo "3️⃣ 构建 Docker 镜像..."
docker build -t $IMAGE_NAME:$VERSION -t $IMAGE_NAME:latest .

# 4. 推送镜像
echo ""
echo "4️⃣ 推送镜像到 Google Container Registry..."
docker push $IMAGE_NAME:$VERSION
docker push $IMAGE_NAME:latest

# 5. 部署到 Cloud Run
echo ""
echo "5️⃣ 部署到 Cloud Run..."
gcloud run deploy $SERVICE_NAME \
  --image=$IMAGE_NAME:$VERSION \
  --platform=managed \
  --region=$REGION \
  --allow-unauthenticated \
  --set-env-vars="GOOGLE_CLOUD_PROJECT=$PROJECT_ID,GOOGLE_CLOUD_LOCATION=$REGION" \
  --memory=1Gi \
  --cpu=1 \
  --timeout=300 \
  --min-instances=0 \
  --max-instances=10

# 6. 获取服务 URL
echo ""
echo "6️⃣ 获取服务 URL..."
SERVICE_URL=$(gcloud run services describe $SERVICE_NAME --region=$REGION --format='value(status.url)')

echo ""
echo "✅ 部署成功！"
echo ""
echo "🌐 服务 URL: $SERVICE_URL"
echo ""
echo "📝 接下来的步骤："
echo "   1. 测试健康检查："
echo "      curl $SERVICE_URL/health"
echo ""
echo "   2. 在 iOS 应用中配置此 URL："
echo "      private let backendURL = \"$SERVICE_URL\""
echo ""
echo "   3. 查看日志："
echo "      gcloud run services logs tail $SERVICE_NAME --region=$REGION"
echo ""
