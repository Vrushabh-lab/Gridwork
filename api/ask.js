// Vercel serverless function — POST /api/ask
// Keeps your Anthropic API key on the server. The browser never sees it.
// Set ANTHROPIC_API_KEY as an environment variable in your Vercel project
// (Project Settings -> Environment Variables), not in this file.

module.exports = async function handler(req, res) {
  if (req.method !== 'POST') {
    res.status(405).json({ error: 'Method not allowed' });
    return;
  }

  var apiKey = process.env.ANTHROPIC_API_KEY;
  if (!apiKey) {
    res.status(500).json({ error: 'ANTHROPIC_API_KEY is not set on the server. Add it in Vercel: Project Settings -> Environment Variables, then redeploy.' });
    return;
  }

  var body = req.body || {};
  var prompt = body.prompt;
  if (!prompt || typeof prompt !== 'string') {
    res.status(400).json({ error: 'Missing "prompt" in request body.' });
    return;
  }
  if (prompt.length > 60000) {
    res.status(400).json({ error: 'Prompt too large.' });
    return;
  }

  try {
    var upstream = await fetch('https://api.anthropic.com/v1/messages', {
      method: 'POST',
      headers: {
        'content-type': 'application/json',
        'x-api-key': apiKey,
        'anthropic-version': '2023-06-01'
      },
      body: JSON.stringify({
        model: 'claude-haiku-4-5-20251001',
        max_tokens: 600,
        messages: [{ role: 'user', content: prompt }]
      })
    });

    var data = await upstream.json();

    if (!upstream.ok) {
      var msg = (data && data.error && data.error.message) || ('Upstream error (' + upstream.status + ')');
      res.status(upstream.status).json({ error: msg });
      return;
    }

    var text = (data.content || []).map(function (block) { return block.text || ''; }).join('');
    res.status(200).json({ text: text });
  } catch (err) {
    res.status(500).json({ error: 'Could not reach the AI service.' });
  }
};
