# Docker Compose - Enterprise Middleware Stack

Complete local development and SRE practice environment with enterprise-grade services.

## 🏗️ Architecture

```
Internet/Users
      ↓
  [Nginx LB]
      ↓
   ┌──┴───┐
   ↓      ↓
[Tomcat] [Node.js]
   ↓      ↓
   └──┬───┘
      ↓
 [PostgreSQL]
 [Redis Cache]

[Monitoring: Prometheus + Grafana]
[Logging: ELK Stack]
[Queue: RabbitMQ]
```

## 📦 Services Included

| Service | Port | Description |
|---------|------|-------------|
| Nginx | 80, 443 | Reverse proxy & load balancer |
| Tomcat | 8080 | Java application server |
| Node.js API | 3001 | REST API service |
| PostgreSQL | 5432 | Relational database |
| Redis | 6379 | Cache layer |
| Prometheus | 9090 | Metrics collection |
| Node Exporter | 9100 | System metrics |
| Grafana | 3000 | Metrics visualization |
| Elasticsearch | 9200 | Log storage |
| Logstash | 5044, 9600 | Log processing |
| Kibana | 5601 | Log visualization |
| RabbitMQ | 5672, 15672 | Message queue |

## 🚀 Quick Start

### Prerequisites
- Docker 20.10+
- Docker Compose 2.0+
- 8GB RAM minimum
- 20GB free disk space

### Start All Services
```bash
# Clone and navigate to project
cd docker-compose

# Start the entire stack
docker compose up -d

# Check status
docker compose ps

# View logs
docker compose logs -f [service_name]
```

### Stop Services
```bash
# Stop all
docker compose down

# Stop and remove volumes (⚠️ data loss)
docker compose down -v
```

## 📊 Access Points

### Applications
- **Nginx**: http://localhost
- **Tomcat Manager**: http://localhost:8080/manager/html
- **Node.js API**: http://localhost:3001

### Monitoring
- **Prometheus**: http://localhost:9090
- **Grafana**: http://localhost:3000 (admin/admin)
- **Node Exporter**: http://localhost:9100/metrics

### Logging
- **Kibana**: http://localhost:5601
- **Elasticsearch**: http://localhost:9200

### Message Queue
- **RabbitMQ Management**: http://localhost:15672 (admin/admin)

## 🗂️ Directory Structure

```
docker-compose/
├── docker-compose.yml       # Main orchestration file
├── .env                     # Environment variables
├── nginx/
│   ├── nginx.conf          # Main Nginx config
│   ├── conf.d/
│   │   └── default.conf    # Virtual host config
│   └── ssl/                # SSL certificates (optional)
├── prometheus/
│   ├── prometheus.yml      # Prometheus config
│   └── alerts/             # Alert rules
├── grafana/
│   ├── provisioning/       # Auto-provisioning
│   └── dashboards/         # Pre-built dashboards
├── logstash/
│   ├── pipeline/           # Log processing pipelines
│   └── config/
│       └── logstash.yml
├── apps/
│   ├── java/               # Tomcat WAR files
│   └── nodejs/             # Node.js application
└── database/
    └── init/               # PostgreSQL init scripts
```

## 🛠️ Configuration

### Environment Variables
Edit `.env` file to customize:
- Database credentials
- Redis password
- Grafana admin credentials
- RabbitMQ credentials

### Nginx Configuration
- Main config: `nginx/nginx.conf`
- Virtual hosts: `nginx/conf.d/default.conf`
- Add SSL certificates to `nginx/ssl/`

### Prometheus Targets
Edit `prometheus/prometheus.yml` to add custom scrape targets.

## 🧪 Testing

### Health Checks
```bash
# Nginx
curl http://localhost/health

# Tomcat
curl http://localhost:8080

# Node.js API
curl http://localhost:3001/health

# PostgreSQL
docker compose exec postgres pg_isready -U appuser

# Redis
docker compose exec redis redis-cli ping
```

### Load Testing
```bash
# Install Apache Bench
apt-get install apache2-utils

# Test Nginx
ab -n 1000 -c 10 http://localhost/
```

## 📈 Monitoring

### Prometheus Queries
```promql
# CPU usage
rate(node_cpu_seconds_total[5m])

# Memory usage
node_memory_MemAvailable_bytes / node_memory_MemTotal_bytes

# HTTP request rate
rate(nginx_http_requests_total[5m])
```

### Grafana Dashboards
1. Access http://localhost:3000
2. Login: admin/admin
3. Import dashboards from `grafana/dashboards/`

## 🐛 Troubleshooting

### Container won't start
```bash
# Check logs
docker compose logs [service_name]

# Inspect container
docker compose exec [service_name] sh
```

### Port already in use
```bash
# Find process using port
lsof -i :[port]
netstat -tlnp | grep [port]

# Change port in docker-compose.yml
```

### Out of memory
```bash
# Check Docker resources
docker system df

# Prune unused data
docker system prune -a
```

## 🔒 Security Notes

⚠️ **This is a development environment**

- Default passwords are used (change for production!)
- No SSL/TLS configured by default
- Services exposed on all interfaces
- Recommended for local use only

## 📚 Next Steps

1. Deploy sample applications to Tomcat and Node.js
2. Configure Grafana dashboards
3. Set up log parsing in Logstash
4. Create Prometheus alerts
5. Implement CI/CD pipeline

## 🤝 Contributing

This is a learning lab. Feel free to:
- Add new services
- Improve configurations
- Create documentation
- Share your setups

---

**Author**: Arthur Oliveira | SRE @ IBM  
**GitHub**: github.com/ArthrR/middleware-sre-platform
