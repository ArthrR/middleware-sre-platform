const express = require('express');
const { Pool } = require('pg');
const redis = require('redis');

const app = express();
const port = process.env.PORT || 3000;

// Middleware
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// PostgreSQL connection
const pool = new Pool({
  connectionString: process.env.DATABASE_URL || 'postgresql://appuser:apppass@postgres:5432/appdb'
});

// Redis connection
const redisClient = redis.createClient({
  url: process.env.REDIS_URL || 'redis://redis:6379',
  password: process.env.REDIS_PASSWORD || 'redispass'
});

redisClient.connect().catch(console.error);

// Health check endpoint
app.get('/health', async (req, res) => {
  try {
    // Check PostgreSQL
    await pool.query('SELECT 1');

    // Check Redis
    await redisClient.ping();

    res.json({
      status: 'healthy',
      timestamp: new Date().toISOString(),
      services: {
        database: 'connected',
        cache: 'connected'
      }
    });
  } catch (error) {
    res.status(503).json({
      status: 'unhealthy',
      error: error.message
    });
  }
});

// Get all users
app.get('/api/users', async (req, res) => {
  try {
    // Try cache first
    const cacheKey = 'users:all';
    const cached = await redisClient.get(cacheKey);

    if (cached) {
      return res.json({
        source: 'cache',
        data: JSON.parse(cached)
      });
    }

    // Query database
    const result = await pool.query('SELECT id, username, email, created_at FROM users ORDER BY created_at DESC');

    // Cache for 60 seconds
    await redisClient.setEx(cacheKey, 60, JSON.stringify(result.rows));

    res.json({
      source: 'database',
      data: result.rows
    });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Create user
app.post('/api/users', async (req, res) => {
  const { username, email } = req.body;

  if (!username || !email) {
    return res.status(400).json({ error: 'Username and email are required' });
  }

  try {
    const result = await pool.query(
      'INSERT INTO users (username, email) VALUES ($1, $2) RETURNING id, username, email, created_at',
      [username, email]
    );

    // Invalidate cache
    await redisClient.del('users:all');

    res.status(201).json(result.rows[0]);
  } catch (error) {
    if (error.code === '23505') { // Unique violation
      res.status(409).json({ error: 'Username or email already exists' });
    } else {
      res.status(500).json({ error: error.message });
    }
  }
});

// Get user by ID
app.get('/api/users/:id', async (req, res) => {
  const { id } = req.params;

  try {
    const result = await pool.query(
      'SELECT id, username, email, created_at FROM users WHERE id = $1',
      [id]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({ error: 'User not found' });
    }

    res.json(result.rows[0]);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// API info
app.get('/', (req, res) => {
  res.json({
    name: 'Enterprise Node.js API',
    version: '1.0.0',
    endpoints: {
      health: 'GET /health',
      users: {
        list: 'GET /api/users',
        create: 'POST /api/users',
        get: 'GET /api/users/:id'
      }
    },
    environment: process.env.NODE_ENV || 'development'
  });
});

// Prometheus metrics endpoint (basic)
app.get('/metrics', (req, res) => {
  res.set('Content-Type', 'text/plain');
  res.send(`# HELP nodejs_api_up Service up status
# TYPE nodejs_api_up gauge
nodejs_api_up 1

# HELP nodejs_api_requests_total Total number of requests
# TYPE nodejs_api_requests_total counter
nodejs_api_requests_total ${Math.floor(Math.random() * 1000)}
`);
});

// Start server
app.listen(port, () => {
  console.log(`✅ Enterprise API listening on port ${port}`);
  console.log(`📊 Health check: http://localhost:${port}/health`);
  console.log(`📖 API docs: http://localhost:${port}/`);
});

// Graceful shutdown
process.on('SIGTERM', async () => {
  console.log('SIGTERM received, closing connections...');
  await pool.end();
  await redisClient.quit();
  process.exit(0);
});
