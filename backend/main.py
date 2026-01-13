# Gayish Backend API
# 使用 FastAPI + Vertex AI

from fastapi import FastAPI, UploadFile, File, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse
import vertexai
from vertexai.generative_models import GenerativeModel, Part, GenerationConfig
import base64
import os
from pydantic import BaseModel
from typing import Optional
import re

# 初始化 FastAPI
app = FastAPI(
    title="Gayish API",
    description="AI 分析聊天截图的 Gay 度",
    version="1.0.0"
)

# CORS 配置 - 允许 iOS 应用访问
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # 生产环境建议限制为你的应用域名
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# 环境变量
PROJECT_ID = os.getenv("GOOGLE_CLOUD_PROJECT", "your-project-id")
LOCATION = os.getenv("GOOGLE_CLOUD_LOCATION", "us-central1")
MODEL_NAME = "gemini-2.0-flash-exp"

# 初始化 Vertex AI
vertexai.init(project=PROJECT_ID, location=LOCATION)

# 数据模型
class AnalysisResponse(BaseModel):
    total_score: int
    level_title: str
    breakdown: list
    summary: str
    raw_text: str

# System Prompt
SYSTEM_PROMPT = """这对话有多 gayyyyyyyyish. it's a joke

请分析这张聊天截图，给我一个 1 到 10 分的打分，并详细分析每个得分点。

请严格按照以下格式返回：

1. 基础得分 (+X分): "引用对话内容"
   分析说明

2. 进阶得分 (+X分): "引用对话内容"
   分析说明

3. 灵魂得分 (+X分): "引用对话内容"
   分析说明（这是最Gay的部分）

4. 附加分 (+X分): "引用对话内容"
   分析说明

总结：最终评语

请用中文回答，要幽默风趣，充满娱乐性。"""


def get_level_title(score: int) -> str:
    """根据分数返回等级标题"""
    if score <= 2:
        return "直男铁憨憨"
    elif score <= 4:
        return "普通朋友"
    elif score <= 6:
        return "Gay雷达有反应"
    elif score <= 8:
        return "姐妹预备役"
    elif score == 9:
        return "Drama Queen"
    else:
        return "Gay Icon本人"


def parse_analysis_result(text: str) -> dict:
    """解析 AI 返回的文本，提取结构化数据"""
    
    breakdown = []
    summary = ""
    total_score = 0
    
    # 提取各个得分项
    patterns = [
        r"1\.\s*基础得分\s*\(\+?(\d+)分\):\s*[\""]?([^\""\n]+)[\""]?\s*\n\s*([^\n]+)",
        r"2\.\s*进阶得分\s*\(\+?(\d+)分\):\s*[\""]?([^\""\n]+)[\""]?\s*\n\s*([^\n]+)",
        r"3\.\s*灵魂得分\s*\(\+?(\d+)分\):\s*[\""]?([^\""\n]+)[\""]?\s*\n\s*([^\n]+)",
        r"4\.\s*附加分\s*\(\+?(\d+)分\):\s*[\""]?([^\""\n]+)[\""]?\s*\n\s*([^\n]+)",
    ]
    
    titles = ["基础得分", "进阶得分", "灵魂得分", "附加分"]
    
    for i, pattern in enumerate(patterns):
        match = re.search(pattern, text, re.MULTILINE)
        if match:
            score = int(match.group(1))
            quote = match.group(2).strip()
            description = match.group(3).strip()
            
            breakdown.append({
                "category": titles[i],
                "score": score,
                "quote": quote,
                "description": description,
                "isHighlight": (i == 2)  # 灵魂得分高亮
            })
            
            total_score += score
    
    # 提取总结
    summary_match = re.search(r"总结[：:]\s*(.+)", text, re.MULTILINE | re.DOTALL)
    if summary_match:
        summary = summary_match.group(1).strip()
    
    # 如果解析失败，使用默认值
    if total_score == 0:
        total_score = 5
        breakdown = [
            {
                "category": "基础得分",
                "score": 2,
                "quote": "对话内容",
                "description": "分析说明",
                "isHighlight": False
            },
            {
                "category": "进阶得分",
                "score": 1,
                "quote": "对话内容",
                "description": "分析说明",
                "isHighlight": False
            },
            {
                "category": "灵魂得分",
                "score": 2,
                "quote": "对话内容",
                "description": "这是最Gay的部分",
                "isHighlight": True
            },
            {
                "category": "附加分",
                "score": 0,
                "quote": "对话内容",
                "description": "分析说明",
                "isHighlight": False
            }
        ]
        summary = "AI分析完成，这是一个娱乐性的分析结果。"
    
    return {
        "total_score": min(total_score, 10),  # 最高10分
        "breakdown": breakdown,
        "summary": summary
    }


@app.get("/")
async def root():
    """健康检查接口"""
    return {
        "status": "ok",
        "service": "Gayish API",
        "version": "1.0.0",
        "vertex_ai_enabled": True
    }


@app.get("/health")
async def health_check():
    """健康检查"""
    return {"status": "healthy"}


@app.post("/analyze", response_model=AnalysisResponse)
async def analyze_image(file: UploadFile = File(...)):
    """
    分析上传的聊天截图
    
    Args:
        file: 上传的图片文件 (JPEG/PNG)
    
    Returns:
        AnalysisResponse: 分析结果
    """
    
    try:
        # 1. 读取图片数据
        image_data = await file.read()
        
        # 验证文件类型
        if not file.content_type or not file.content_type.startswith("image/"):
            raise HTTPException(status_code=400, detail="文件必须是图片格式")
        
        # 2. 创建 Vertex AI 模型实例
        model = GenerativeModel(MODEL_NAME)
        
        # 3. 准备图片数据
        image_part = Part.from_data(
            data=image_data,
            mime_type=file.content_type
        )
        
        # 4. 配置生成参数
        generation_config = GenerationConfig(
            temperature=0.7,
            top_p=0.95,
            top_k=32,
            max_output_tokens=2048,
        )
        
        # 5. 调用 Vertex AI 进行分析
        response = model.generate_content(
            contents=[SYSTEM_PROMPT, image_part],
            generation_config=generation_config,
        )
        
        # 6. 获取响应文本
        if not response.candidates:
            raise HTTPException(status_code=500, detail="AI 分析未返回结果")
        
        raw_text = response.text
        
        # 7. 解析结果
        parsed_result = parse_analysis_result(raw_text)
        
        # 8. 构建响应
        result = AnalysisResponse(
            total_score=parsed_result["total_score"],
            level_title=get_level_title(parsed_result["total_score"]),
            breakdown=parsed_result["breakdown"],
            summary=parsed_result["summary"],
            raw_text=raw_text
        )
        
        return result
        
    except Exception as e:
        print(f"Error during analysis: {str(e)}")
        raise HTTPException(
            status_code=500,
            detail=f"分析失败: {str(e)}"
        )


@app.post("/analyze-base64")
async def analyze_base64_image(image_base64: str, mime_type: str = "image/jpeg"):
    """
    分析 Base64 编码的图片
    
    Args:
        image_base64: Base64 编码的图片数据
        mime_type: 图片 MIME 类型
    
    Returns:
        AnalysisResponse: 分析结果
    """
    
    try:
        # 解码 Base64
        image_data = base64.b64decode(image_base64)
        
        # 调用相同的分析逻辑
        model = GenerativeModel(MODEL_NAME)
        
        image_part = Part.from_data(
            data=image_data,
            mime_type=mime_type
        )
        
        generation_config = GenerationConfig(
            temperature=0.7,
            top_p=0.95,
            top_k=32,
            max_output_tokens=2048,
        )
        
        response = model.generate_content(
            contents=[SYSTEM_PROMPT, image_part],
            generation_config=generation_config,
        )
        
        raw_text = response.text
        parsed_result = parse_analysis_result(raw_text)
        
        result = {
            "total_score": parsed_result["total_score"],
            "level_title": get_level_title(parsed_result["total_score"]),
            "breakdown": parsed_result["breakdown"],
            "summary": parsed_result["summary"],
            "raw_text": raw_text
        }
        
        return result
        
    except Exception as e:
        print(f"Error during analysis: {str(e)}")
        raise HTTPException(
            status_code=500,
            detail=f"分析失败: {str(e)}"
        )


if __name__ == "__main__":
    import uvicorn
    port = int(os.getenv("PORT", 8080))
    uvicorn.run(app, host="0.0.0.0", port=port)
