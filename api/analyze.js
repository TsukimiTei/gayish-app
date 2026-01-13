/**
 * Vercel Serverless Function - Gemini API 分析接口
 * 
 * 环境变量配置（在 Vercel Dashboard 中设置）：
 * - GEMINI_API_KEY: 你的 Gemini API Key
 * - GEMINI_MODEL: gemini-3-flash（或其他模型）
 */

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
    const apiKey = process.env.GEMINI_API_KEY;
    const model = process.env.GEMINI_MODEL || 'gemini-1.5-flash';

    if (!apiKey) {
      console.error('❌ 未配置 GEMINI_API_KEY 环境变量');
      return res.status(500).json({ error: 'API 配置错误' });
    }

    console.log('🚀 调用 Vertex AI Gemini API (GenAI SDK 模式)...');
    console.log('   模型:', model);
    console.log('   API Key (Vertex AI):', apiKey.substring(0, 10) + '...');
    console.log('   API Version: v1');
    console.log('   GOOGLE_GENAI_USE_VERTEXAI: True');

    // ✅ 按照用户的 Python 代码要求：
    // os.environ["GOOGLE_GENAI_USE_VERTEXAI"] = "True"
    // client = genai.Client(api_key=api_key, http_options=HttpOptions(api_version="v1"))
    
    // Vertex AI GenAI SDK 端点（v1 API）
    const vertexEndpoint = `https://generativelanguage.googleapis.com/v1/models/${model}:generateContent`;
    
    const requestBody = {
      contents: [
        {
          parts: [
            { text: prompt || getDefaultPrompt() },
            {
              inline_data: {
                mime_type: 'image/jpeg',
                data: image.replace(/^data:image\/\w+;base64,/, '') // 去除 base64 前缀（如果有）
              }
            }
          ]
        }
      ],
      generationConfig: {
        temperature: 0.7,
        topK: 32,
        topP: 0.95,
        maxOutputTokens: 2048
      }
    };

    // ✅ 使用 x-goog-api-key header（Vertex AI 认证方式）
    const response = await fetch(vertexEndpoint, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'x-goog-api-key': apiKey  // Vertex AI 使用这个 header
      },
      body: JSON.stringify(requestBody)
    });

    const responseData = await response.json();

    console.log('📡 Gemini API 响应状态:', response.status);

    if (!response.ok) {
      console.error('❌ Gemini API 错误:', responseData);
      return res.status(response.status).json({
        error: 'Gemini API 调用失败',
        details: responseData
      });
    }

    // 提取响应文本
    const text = responseData.candidates?.[0]?.content?.parts?.[0]?.text;
    
    if (!text) {
      console.error('❌ 响应中没有文本内容');
      return res.status(500).json({ error: '无法解析 API 响应' });
    }

    console.log('✅ 分析完成');
    
    // 返回成功响应
    return res.status(200).json({
      success: true,
      text: text,
      model: model
    });

  } catch (error) {
    console.error('❌ 服务器错误:', error);
    return res.status(500).json({
      error: '服务器内部错误',
      message: error.message
    });
  }
}

/**
 * 默认 prompt
 */
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
