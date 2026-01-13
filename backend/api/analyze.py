# Vercel Serverless Function
# API 路径: /api/analyze

from http.server import BaseHTTPRequestHandler
import json
import base64
import re
import os
from urllib.parse import parse_qs

# 导入 Google GenAI SDK (支持 Vertex AI 模式)
try:
    from google import genai
    from google.genai.types import HttpOptions, Part, Blob, GenerateContentConfig
    HAS_GENAI_SDK = True
except ImportError:
    HAS_GENAI_SDK = False

# 配置
GEMINI_API_KEY = os.getenv("GEMINI_API_KEY", "")
MODEL_NAME = "gemini-2.0-flash-exp"

# 设置 Vertex AI 模式
if GEMINI_API_KEY:
    os.environ["GEMINI_API_KEY"] = GEMINI_API_KEY
    os.environ["GOOGLE_GENAI_USE_VERTEXAI"] = "True"
    
    # 清除可能影响认证的环境变量（避免使用 ADC）
    for key in ["GOOGLE_APPLICATION_CREDENTIALS", "GCLOUD_PROJECT", "GOOGLE_CLOUD_PROJECT"]:
        if key in os.environ:
            del os.environ[key]

# 初始化客户端
genai_client = None
if HAS_GENAI_SDK and GEMINI_API_KEY:
    try:
        http_options = HttpOptions(api_version="v1")
        genai_client = genai.Client(api_key=GEMINI_API_KEY, http_options=http_options)
    except Exception as e:
        print(f"Failed to initialize GenAI client: {e}")

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


def analyze_with_genai(image_data: bytes, mime_type: str) -> dict:
    """使用 Google GenAI SDK 分析图片（Vertex AI 模式）"""
    
    if not HAS_GENAI_SDK:
        raise Exception("Google GenAI SDK not available")
    
    if not genai_client:
        raise Exception("GenAI client not initialized. Check GEMINI_API_KEY")
    
    # 构建请求 parts
    parts = [
        Part(text=SYSTEM_PROMPT),  # 文本 prompt
        Part(inline_data=Blob(
            mime_type=mime_type,
            data=image_data,
        ))  # 图片数据
    ]
    
    # 配置生成参数
    config = GenerateContentConfig(
        temperature=0.7,
        top_k=32,
        top_p=0.95,
        max_output_tokens=2048,
    )
    
    # 调用 GenAI API
    response = genai_client.models.generate_content(
        model=MODEL_NAME,
        contents=parts,
        config=config,
    )
    
    # 提取响应文本
    if not response.candidates:
        raise Exception("AI 未返回结果")
    
    # 从响应中提取文本
    raw_text = ""
    if response.candidates[0].content and response.candidates[0].content.parts:
        for part in response.candidates[0].content.parts:
            if hasattr(part, 'text') and part.text:
                raw_text += part.text
    
    if not raw_text:
        raise Exception("AI 返回的内容为空")
    
    # 解析结果
    parsed_result = parse_analysis_result(raw_text)
    
    return {
        "total_score": parsed_result["total_score"],
        "level_title": get_level_title(parsed_result["total_score"]),
        "breakdown": parsed_result["breakdown"],
        "summary": parsed_result["summary"],
        "raw_text": raw_text
    }


class handler(BaseHTTPRequestHandler):
    """Vercel Serverless Function Handler"""
    
    def _set_headers(self, status_code=200, content_type='application/json'):
        """设置响应头"""
        self.send_response(status_code)
        self.send_header('Content-Type', content_type)
        self.send_header('Access-Control-Allow-Origin', '*')
        self.send_header('Access-Control-Allow-Methods', 'GET, POST, OPTIONS')
        self.send_header('Access-Control-Allow-Headers', 'Content-Type')
        self.end_headers()
    
    def _send_json(self, data, status_code=200):
        """发送 JSON 响应"""
        self._set_headers(status_code)
        self.wfile.write(json.dumps(data, ensure_ascii=False).encode('utf-8'))
    
    def _send_error(self, message, status_code=500):
        """发送错误响应"""
        self._send_json({
            "error": message,
            "status": "error"
        }, status_code)
    
    def do_OPTIONS(self):
        """处理 CORS 预检请求"""
        self._set_headers(204)
    
    def do_GET(self):
        """处理 GET 请求（健康检查）"""
        self._send_json({
            "status": "ok",
            "service": "Gayish API",
            "version": "1.0.0",
            "platform": "Vercel",
            "genai_sdk_available": HAS_GENAI_SDK,
            "configured": bool(genai_client)
        })
    
    def do_POST(self):
        """处理 POST 请求（图片分析）"""
        
        try:
            # 获取 Content-Type
            content_type = self.headers.get('Content-Type', '')
            
            if 'application/json' in content_type:
                # JSON 格式（Base64）
                content_length = int(self.headers.get('Content-Length', 0))
                body = self.rfile.read(content_length)
                data = json.loads(body.decode('utf-8'))
                
                image_base64 = data.get('image_base64', '')
                mime_type = data.get('mime_type', 'image/jpeg')
                
                if not image_base64:
                    self._send_error("缺少 image_base64 参数", 400)
                    return
                
                # 解码 Base64
                image_data = base64.b64decode(image_base64)
                
            elif 'multipart/form-data' in content_type:
                # Multipart 格式（文件上传）
                # 注意：Vercel Serverless Functions 处理 multipart 比较复杂
                # 建议使用 Base64 方式
                self._send_error("请使用 JSON + Base64 格式上传图片", 400)
                return
                
            else:
                self._send_error("不支持的 Content-Type", 400)
                return
            
            # 调用 GenAI 分析
            result = analyze_with_genai(image_data, mime_type)
            
            # 返回结果
            self._send_json(result)
            
        except Exception as e:
            print(f"Error: {str(e)}")
            self._send_error(f"分析失败: {str(e)}", 500)
