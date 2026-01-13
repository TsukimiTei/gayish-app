/**
 * Vercel Serverless Function - Gemini API 分析接口
 * 使用 @google/genai SDK
 * 
 * 环境变量配置（在 Vercel Dashboard 中设置）：
 * - GEMINI_API_KEY: 你的 API Key
 * - GEMINI_MODEL: gemini-1.5-flash（或其他模型）
 */

import { GoogleGenAI } from "@google/genai";

// ❌ 不使用 Vertex AI 模式，不使用 ADC
// ✅ 直接使用 API Key
delete process.env.GOOGLE_GENAI_USE_VERTEXAI;
delete process.env.GOOGLE_APPLICATION_CREDENTIALS;
delete process.env.GCLOUD_PROJECT;
delete process.env.GOOGLE_CLOUD_PROJECT;

// GenAI 客户端缓存
let genAIClient = null;

// 获取 GenAI 客户端（单例）
function getGenAIClient() {
  if (!genAIClient) {
    const apiKey = process.env.GEMINI_API_KEY;
    if (!apiKey) {
      throw new Error("GEMINI_API_KEY environment variable is required");
    }
    
    // ✅ 只传 apiKey，不使用任何其他认证
    genAIClient = new GoogleGenAI({ apiKey });
    
    console.log('✅ [GenAI] 客户端初始化成功');
    console.log('   API Key:', apiKey.substring(0, 10) + '...');
    console.log('   使用 ADC: 否');
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

  if (req.method === 'OPTIONS') {
    res.status(200).end();
    return;
  }

  if (req.method !== 'POST') {
    return res.status(405).json({ error: '只支持 POST 请求' });
  }

  try {
    const { image, prompt } = req.body;

    if (!image) {
      return res.status(400).json({ error: '缺少图片数据' });
    }

    const model = process.env.GEMINI_MODEL || 'gemini-1.5-flash';

    console.log('🚀 [GenAI] 开始调用...');
    console.log('   模型:', model);

    const client = getGenAIClient();

    const parts = [
      {
        inlineData: {
          mimeType: 'image/jpeg',
          data: image.replace(/^data:image\/\w+;base64,/, '')
        }
      },
      {
        text: prompt || getDefaultPrompt()
      }
    ];

    console.log('📤 [GenAI] 发送请求...');
    
    const response = await client.models.generateContent({
      model: model,
      contents: [{ role: 'user', parts: parts }],
      config: {
        temperature: 0.7,
        topK: 32,
        topP: 0.95,
        maxOutputTokens: 2048
      }
    });

    console.log('📡 [GenAI] 收到响应');

    const candidate = response.candidates?.[0];
    if (candidate?.finishReason === 'SAFETY') {
      return res.status(400).json({ error: '内容被安全过滤阻止' });
    }

    const responseText = candidate?.content?.parts?.[0]?.text;

    if (!responseText) {
      return res.status(500).json({ error: '无法解析 API 响应' });
    }

    console.log('✅ [GenAI] 分析完成');
    
    return res.status(200).json({
      success: true,
      text: responseText,
      model: model
    });

  } catch (error) {
    console.error('❌ [GenAI] 错误:', error.message);
    return res.status(500).json({
      error: '服务器错误',
      message: error.message
    });
  }
}
