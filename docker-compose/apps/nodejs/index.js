const express = require('express');
const app = express();
const port = 3000;

app.use(express.json());

app.get('/health', (req, res) => {
  res.json({ status: 'healthy', timestamp: new Date() });
});

app.get('/', (req, res) => {
  res.json({ 
    message: 'Enterprise API v2',
    endpoints: ['/health', '/api/users']
  });
});

app.listen(port, () => {
  console.log(\`API listening on port \${port}\`);
});
