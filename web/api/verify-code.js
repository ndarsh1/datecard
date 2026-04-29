const twilio = require('twilio');
const { sql } = require('@vercel/postgres');

const client = twilio(process.env.TWILIO_ACCOUNT_SID, process.env.TWILIO_AUTH_TOKEN);

module.exports = async function handler(req, res) {
  if (req.method !== 'POST') {
    return res.status(405).json({ error: 'Method not allowed' });
  }

  const { phone, code } = req.body || {};
  if (!phone || !code) {
    return res.status(400).json({ error: 'Phone and code are required' });
  }

  const cleanCode = String(code).replace(/\D/g, '').trim();

  // Step 1: Verify with Twilio
  let check;
  try {
    check = await client.verify.v2
      .services(process.env.TWILIO_VERIFY_SERVICE_SID)
      .verificationChecks.create({ to: phone, code: cleanCode });
  } catch (err) {
    console.error('Twilio error:', err.status, err.message, err.code);
    if (err.code === 20404 || err.code === 60200) {
      return res.status(400).json({ error: 'Code expired or already used. Please request a new code.' });
    }
    return res.status(400).json({ error: err.message });
  }

  if (check.status !== 'approved') {
    return res.status(400).json({ error: 'Wrong code. Please try again.' });
  }

  // Step 2: Store in DB
  try {
    await sql`
      CREATE TABLE IF NOT EXISTS waitlist (
        id SERIAL PRIMARY KEY,
        phone VARCHAR(20) UNIQUE NOT NULL,
        created_at TIMESTAMP DEFAULT NOW()
      )
    `;

    await sql`
      INSERT INTO waitlist (phone)
      VALUES (${phone})
      ON CONFLICT (phone) DO NOTHING
    `;

    const { rows } = await sql`SELECT COUNT(*)::int as count FROM waitlist`;

    return res.status(200).json({ success: true, count: rows[0].count });
  } catch (err) {
    console.error('DB error:', err.message);
    return res.status(500).json({ error: 'Database error: ' + err.message });
  }
};
