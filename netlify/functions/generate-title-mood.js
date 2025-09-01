const axios = require('axios');
//require('dotenv').config();

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
      'https://api.deepseek.com/v1/chat/completions',
      {
        model: 'deepseek-chat',
        messages: [{ role: 'user', content: prompt }],
        temperature: 0.7
      },
      {
        headers: {
          'Authorization': `Bearer ${process.env.DEEPSEEK_API_KEY}`,
          'Content-Type': 'application/json'
        }
      }
    );
    const text = response.data.choices[0].message.content;
    return {
      statusCode: 200,
      body: JSON.stringify({ result: text }),
    };
  } catch (err) {
    return {
      statusCode: 500,
      body: JSON.stringify({ error: err.toString() }),
    };
  }
};
