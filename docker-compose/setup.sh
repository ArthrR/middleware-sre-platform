#!/bin/bash

###############################################################################
# Enterprise Middleware Stack - Setup Script
# Automatically creates required directory structure and sample configs
###############################################################################

set -e

echo "🚀 Setting up Enterprise Middleware Stack..."

# Create directory structure
echo "📁 Creating directory structure..."
mkdir -p nginx/{conf.d,ssl}
mkdir -p prometheus/alerts
mkdir -p grafana/{provisioning/{datasources,dashboards},dashboards}
mkdir -p logstash/{pipeline,config}
mkdir -p apps/{java,nodejs}
mkdir -p database/init

# Create sample Nginx virtual host
cat > nginx/conf.d/default.conf << 'EOF'
upstream tomcat_backend {
    least_conn;
    server tomcat-app:8080;
}

upstream nodejs_backend {
    least_conn;
    server nodejs-api:3000;
}

server {
    listen 80;
    server_name localhost;

    location / {
        root /usr/share/nginx/html;
        index index.html;
    }

    location /api/v1/ {
        proxy_pass http://tomcat_backend/;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }

    location /api/v2/ {
        proxy_pass http://nodejs_backend/;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }

    location /health {
        return 200 "healthy\n";
        add_header Content-Type text/plain;
    }
}
EOF

# Create sample Node.js app
cat > apps/nodejs/package.json << 'EOF'
{
  "name": "enterprise-api",
  "version": "1.0.0",
  "main": "index.js",
  "scripts": {
    "start": "node index.js"
  },
  "dependencies": {
    "express": "^4.18.0",
    "pg": "^8.11.0",
    "redis": "^4.6.0"
  }
}
EOF

cat > apps/nodejs/index.js << 'EOF'
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
EOF

# Create PostgreSQL init script
cat > database/init/01-init.sql << 'EOF'
-- Create sample tables
CREATE TABLE IF NOT EXISTS users (
    id SERIAL PRIMARY KEY,
    username VARCHAR(50) UNIQUE NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS api_logs (
    id SERIAL PRIMARY KEY,
    endpoint VARCHAR(255),
    method VARCHAR(10),
    status_code INTEGER,
    response_time INTEGER,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Insert sample data
INSERT INTO users (username, email) VALUES
    ('admin', 'admin@example.com'),
    ('user1', 'user1@example.com')
ON CONFLICT DO NOTHING;
EOF

# Create Grafana datasource provisioning
cat > grafana/provisioning/datasources/prometheus.yml << 'EOF'
apiVersion: 1

datasources:
  - name: Prometheus
    type: prometheus
    access: proxy
    url: http://prometheus:9090
    isDefault: true
    editable: true
EOF

# Create Logstash pipeline
cat > logstash/pipeline/nginx.conf << 'EOF'
input {
  file {
    path => "/logs/nginx/access.log"
    start_position => "beginning"
    type => "nginx-access"
  }
}

filter {
  if [type] == "nginx-access" {
    grok {
      match => { "message" => "%{COMBINEDAPACHELOG}" }
    }
  }
}

output {
  elasticsearch {
    hosts => ["elasticsearch:9200"]
    index => "nginx-access-%{+YYYY.MM.dd}"
  }
}
EOF

cat > logstash/config/logstash.yml << 'EOF'
http.host: "0.0.0.0"
xpack.monitoring.elasticsearch.hosts: [ "http://elasticsearch:9200" ]
EOF

# Create README
echo "✅ Directory structure created!"
echo "✅ Sample configurations created!"
echo ""
echo "🎯 Next steps:"
echo "   1. Review docker-compose.yml"
echo "   2. Edit .env file with your credentials"
echo "   3. Run: docker compose up -d"
echo "   4. Access services at http://localhost"
echo ""
echo "📚 Documentation: See README.md"
