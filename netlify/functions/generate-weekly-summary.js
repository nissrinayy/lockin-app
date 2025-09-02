const fetch = require('node-fetch');

exports.handler = async function (event, context) {
  try {
    const body = JSON.parse(event.body || '{}');
    const journals = body.journals || [];

    // Gabungkan semua jurnal jadi satu teks
    const journalText = journals
      .map(j => `Tanggal: ${j.date}\nJudul: ${j.title}\nIsi: ${j.content}`)
      .join('\n\n');

    // Prompt untuk AI
    const prompt = `Buatkan ringkasan (summary) dan saran (advice) produktifitas/kesehatan dari jurnal mingguan berikut:\n\n${journalText}\n\nFormat balasan JSON:\n{\n  "summary": "...",\n  "advice": "..."\n}`;

    // API KEY dari Google AI Studio
    const apiKey = process.env.GEMINI_API_KEY;
    const geminiUrl = `https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=${apiKey}`;

    // Request ke Gemini
    const aiRes = await fetch(geminiUrl, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        contents: [
          {
            parts: [{ text: prompt }]
          }
        ]
      }),
    });

    const aiJson = await aiRes.json();

    // Ambil hasil teks dari Gemini
    const aiText = aiJson.candidates?.[0]?.content?.parts?.[0]?.text || '';

    // Bersihkan format kalau ada backtick
    const cleanText = aiText.replace(/```json|```/g, '').trim();

    return {
      statusCode: 200,
      body: JSON.stringify({
        result: cleanText,
        debug: {
          prompt,
          rawResponse: aiJson
        }
      }),
    };
  } catch (e) {
    return {
      statusCode: 500,
      body: JSON.stringify({ error: e.message }),
    };
  }
};
