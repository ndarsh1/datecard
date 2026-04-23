const { createPool } = require('@vercel/postgres');

const pool = createPool({ connectionString: process.env.DATABASE_URL });

module.exports = async function handler(req, res) {
  if (req.method !== 'GET') {
    return res.status(405).json({ error: 'Method not allowed' });
  }

  try {
    await pool.sql`
      CREATE TABLE IF NOT EXISTS waitlist (
        id SERIAL PRIMARY KEY,
        phone VARCHAR(20) UNIQUE NOT NULL,
        created_at TIMESTAMP DEFAULT NOW()
      )
    `;

    const { rows } = await pool.sql`SELECT COUNT(*)::int as count FROM waitlist`;

    return res.status(200).json({ count: rows[0].count });
  } catch (err) {
    console.error('Count error:', err.message);
    return res.status(500).json({ error: 'Failed to get count' });
  }
};
