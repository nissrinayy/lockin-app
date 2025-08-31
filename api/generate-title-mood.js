const axios = require('axios');
require('dotenv').config();

const DEEPSEEK_API_KEY = process.env.DEEPSEEK_API_KEY;

export default async function handler(req, res) {
  if (req.method !== 'POST') {
    res.status(405).json({ error: 'Method not allowed' });
    return;
  }
  const journalContent = req.body.content || '';
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
          'Authorization': `Bearer ${DEEPSEEK_API_KEY}`,
          'Content-Type': 'application/json'
        }
      }
    );
    const text = response.data.choices[0].message.content;
    res.status(200).json({ result: text });
  } catch (err) {
    res.status(500).json({ error: err.toString() });
  }
}
