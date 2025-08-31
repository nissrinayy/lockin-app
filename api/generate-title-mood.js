const axios = require('axios');
require('dotenv').config();

module.exports = async (req, res) => {
  if (req.method !== 'POST') {
    return res.status(405).json({ error: 'Method not allowed' });
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
          'Authorization': `Bearer ${process.env.DEEPSEEK_API_KEY}`,
          'Content-Type': 'application/json'
        }
      }
    );
    const text = response.data.choices[0].message.content;
    res.json({ result: text });
  } catch (err) {
    res.status(500).json({ error: err.toString() });
  }
};
