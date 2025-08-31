
const express = require('express');
const axios = require('axios');
const cors = require('cors');
require('dotenv').config();

const app = express();
app.use(express.json());
app.use(cors());

const DEEPSEEK_API_KEY = process.env.DEEPSEEK_API_KEY;

app.post('/generate-title-mood', async (req, res) => {
  const journalContent = req.body.content || '';
  const prompt = `Buatkan judul singkat (maksimal 8 kata, bahasa Indonesia) dan satu mood dari [\"happy\", \"sad\", \"angry\", \"anxious\", \"relaxed\", \"tired\"] yang paling sesuai untuk jurnal berikut. Jawab dalam format JSON seperti {\"title\": \"...\", \"mood\": \"...\"} tanpa penjelasan lain.\n\n${journalContent}`;
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
    res.json({ result: text });
  } catch (err) {
    res.status(500).json({ error: err.toString() });
  }
});

app.get('/', (req, res) => {
  res.send('AI Journal API is running!');
});

module.exports = app;
