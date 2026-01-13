/**
 * Vercel Serverless Function - Gemini API 分析接口
 * 使用 @google/genai SDK (Vertex AI 模式)
 * 
 * 环境变量配置（在 Vercel Dashboard 中设置）：
 * - GEMINI_API_KEY: 你的 Vertex AI API Key (AQ. 开头)
 * - GEMINI_MODEL: gemini-1.5-flash（或其他模型）
 */

import { GoogleGenAI } from "@google/genai";

// ✅ 启用 Vertex AI 模式
if (!process.env.GOOGLE_GENAI_USE_VERTEXAI) {
  process.env.GOOGLE_GENAI_USE_VERTEXAI = "true";
}

// GenAI 客户端缓存
let genAIClient = null;

// 获取 GenAI 客户端（单例）
function getVertexAIClient() {
  if (!genAIClient) {
    const apiKey = process.env.GEMINI_API_KEY;
    if (!apiKey) {
      throw new Error("GEMINI_API_KEY environment variable is required");
    }
    
    genAIClient = new GoogleGenAI({
      apiKey,
      // Vertex AI 模式通过环境变量 GOOGLE_GENAI_USE_VERTEXAI=true 自动启用
    });
    
    console.log('✅ [GenAI] 客户端初始化成功 (Vertex AI 模式)');
    console.log('   API Key:', apiKey.substring(0, 10) + '...');
  }
  return genAIClient;
}

// 默认 prompt
function getDefaultPrompt() {
  return `这对话有多 gayyyyyyyyish. it's a joke

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

请用中文回答，要幽默风趣，充满娱乐性。`;
}

export default async function handler(req, res) {
  // CORS 配置
  res.setHeader('Access-Control-Allow-Credentials', true);
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Methods', 'GET,OPTIONS,PATCH,DELETE,POST,PUT');
  res.setHeader(
    'Access-Control-Allow-Headers',
    'X-CSRF-Token, X-Requested-With, Accept, Accept-Version, Content-Length, Content-MD5, Content-Type, Date, X-Api-Version'
  );

  // 处理 OPTIONS 请求（预检）
  if (req.method === 'OPTIONS') {
    res.status(200).end();
    return;
  }

  // 只接受 POST 请求
  if (req.method !== 'POST') {
    return res.status(405).json({ error: '只支持 POST 请求' });
  }

  try {
    const { image, prompt } = req.body;

    // 验证请求数据
    if (!image) {
      return res.status(400).json({ error: '缺少图片数据' });
    }

    // 从环境变量读取配置
    const model = process.env.GEMINI_MODEL || 'gemini-1.5-flash';

    console.log('🚀 [Vertex AI] 开始调用 Gemini API...');
    console.log('   模型:', model);
    console.log('   GOOGLE_GENAI_USE_VERTEXAI:', process.env.GOOGLE_GENAI_USE_VERTEXAI);

    // 获取客户端
    const client = getVertexAIClient();

    // 构建请求内容
    const parts = [
      // 先添加图片
      {
        inlineData: {
          mimeType: 'image/jpeg',
          data: image.replace(/^data:image\/\w+;base64,/, '') // 去除 base64 前缀（如果有）
        }
      },
      // 再添加文本提示
      {
        text: prompt || getDefaultPrompt()
      }
    ];

    console.log('📤 [Vertex AI] 发送请求到 Gemini...');
    
    // ✅ 使用 SDK 调用 Vertex AI
    const response = await client.models.generateContent({
      model: model,
      contents: [
        {
          role: 'user',
          parts: parts
        }
      ],
      config: {
        temperature: 0.7,
        topK: 32,
        topP: 0.95,
        maxOutputTokens: 2048,
        safetySettings: [
          {
            category: 'HARM_CATEGORY_HARASSMENT',
            threshold: 'BLOCK_NONE'
          },
          {
            category: 'HARM_CATEGORY_HATE_SPEECH',
            threshold: 'BLOCK_NONE'
          },
          {
            category: 'HARM_CATEGORY_SEXUALLY_EXPLICIT',
            threshold: 'BLOCK_NONE'
          },
          {
            category: 'HARM_CATEGORY_DANGEROUS_CONTENT',
            threshold: 'BLOCK_NONE'
          }
        ]
      }
    });

    console.log('📡 [Vertex AI] 收到响应');

    // 检查安全过滤
    const candidate = response.candidates?.[0];
    if (candidate?.finishReason === 'SAFETY') {
      console.error('❌ [Vertex AI] 内容被安全过滤阻止');
      return res.status(400).json({ error: '内容被安全过滤阻止，请尝试调整图片' });
    }

    // 提取文本
    const responseText = candidate?.content?.parts?.[0]?.text;

    if (!responseText) {
      console.error('❌ [Vertex AI] 响应中没有文本内容');
      return res.status(500).json({ error: '无法解析 API 响应' });
    }

    console.log('✅ [Vertex AI] 分析完成');
    console.log('   返回文本长度:', responseText.length);
    
    // 返回成功响应
    return res.status(200).json({
      success: true,
      text: responseText,
      model: model
    });

  } catch (error) {
    console.error('❌ [Vertex AI] 错误:', error);
    console.error('   错误详情:', error.message);
    console.error('   错误堆栈:', error.stack);
    
    return res.status(500).json({
      error: '服务器内部错误',
      message: error.message,
      details: error.toString()
    });
  }
}
