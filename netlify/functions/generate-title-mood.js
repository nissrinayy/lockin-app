
const axios = require('axios');

exports.handler = async function(event, context) {
  if (event.httpMethod !== 'POST') {
    return {
      statusCode: 405,
      body: JSON.stringify({ error: 'Method not allowed' }),
    };
  }

  let body;
  try {
    body = JSON.parse(event.body);
  } catch {
    return {
      statusCode: 400,
      body: JSON.stringify({ error: 'Invalid JSON' }),
    };
  }

  const journalContent = body.content || '';
  const prompt = `Buatkan judul singkat (maksimal 8 kata, bahasa Indonesia) dan satu mood dari ["happy", "sad", "angry", "anxious", "relaxed", "tired"] yang paling sesuai untuk jurnal berikut. Jawab dalam format JSON seperti {"title": "...", "mood": "..."} tanpa penjelasan lain.\n\n${journalContent}`;

  try {
    const response = await axios.post(
      `https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=${process.env.GEMINI_API_KEY}`,
      {
        contents: [
          { parts: [{ text: prompt }] }
        ]
      }
    );
    const text = response.data.candidates?.[0]?.content?.parts?.[0]?.text || '';
    return {
      statusCode: 200,
      body: JSON.stringify({ result: text }),
    };
  } catch (err) {
    return {
      statusCode: 500,
      body: JSON.stringify({ error: err.toString(), response: err.response?.data }),
    };
  }
};
