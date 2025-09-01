const fetch = require('node-fetch');

exports.handler = async function(event, context) {
  try {
    const body = JSON.parse(event.body || '{}');
    const journals = body.journals || [];
    // Gabungkan semua isi jurnal untuk prompt AI
    const journalText = journals.map(j => `Tanggal: ${j.date}\nJudul: ${j.title}\nIsi: ${j.content}`).join('\n\n');

    // Prompt untuk AI
    const prompt = `Buatkan ringkasan (summary) dan saran (advice) produktifitas/kesehatan dari jurnal mingguan berikut:\n\n${journalText}\n\nFormat balasan JSON:\n{\n  "summary": "...",\n  "advice": "..."\n}`;

    // Ganti dengan API key dan endpoint AI Anda (misal OpenAI, Gemini, dsb)
    const openaiApiKey = process.env.OPENAI_API_KEY;
    const openaiUrl = 'https://api.openai.com/v1/chat/completions';
    const aiRes = await fetch(openaiUrl, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${openaiApiKey}`,
      },
      body: JSON.stringify({
        model: 'gpt-3.5-turbo',
        messages: [
          { role: 'system', content: 'Kamu adalah asisten kesehatan dan produktifitas.' },
          { role: 'user', content: prompt },
        ],
        max_tokens: 512,
        temperature: 0.7,
      }),
    });
    const aiJson = await aiRes.json();
    const aiText = aiJson.choices?.[0]?.message?.content || '';
    return {
      statusCode: 200,
      body: JSON.stringify({ result: aiText })
    };
  } catch (e) {
    return {
      statusCode: 500,
      body: JSON.stringify({ error: e.message })
    };
  }
};
