const twilio = require('twilio');

const client = twilio(process.env.TWILIO_ACCOUNT_SID, process.env.TWILIO_AUTH_TOKEN);

module.exports = async function handler(req, res) {
  if (req.method !== 'POST') {
    return res.status(405).json({ error: 'Method not allowed' });
  }

  const { phone } = req.body;
  if (!phone || !/^\+1\d{10}$/.test(phone)) {
    return res.status(400).json({ error: 'Invalid US phone number' });
  }

  try {
    await client.verify.v2
      .services(process.env.TWILIO_VERIFY_SERVICE_SID)
      .verifications.create({ to: phone, channel: 'sms' });

    return res.status(200).json({ success: true });
  } catch (err) {
    console.error('Twilio send error:', err.message);
    return res.status(500).json({ error: 'Failed to send code' });
  }
};
