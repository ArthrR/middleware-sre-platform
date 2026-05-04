# 🚀 Enterprise Middleware & Infrastructure Platform

> **SRE Learning Lab** | Production-grade infrastructure patterns for study and demonstration

[![Docker](https://img.shields.io/badge/Docker-Compose-2496ED?logo=docker)](docker-compose/)
[![Kubernetes](https://img.shields.io/badge/Kubernetes-Manifests-326CE5?logo=kubernetes)](kubernetes/)
[![Monitoring](https://img.shields.io/badge/Monitoring-Prometheus%20%7C%20Grafana-E6522C)](docker-compose/prometheus/)

---

## 📖 About This Project

This repository serves as a **comprehensive SRE reference platform** showcasing enterprise-grade infrastructure patterns, monitoring strategies, and automation practices. It provides a full-stack learning environment covering the core technologies found in 95% of modern enterprise environments.

**Purpose:** Educational sandbox for practicing SRE workflows, troubleshooting scenarios, and demonstrating technical proficiency across diverse middleware technologies.

---

## 🎯 What's Inside

### 🐳 Docker Compose Stack (12 Services)

Complete containerized environment with real-world integrations:

| Category | Services | Purpose |
|----------|----------|---------|
| **Web Tier** | Nginx | Reverse proxy & load balancer |
| **Application Tier** | Tomcat 10 + Node.js 18 | Java & JavaScript runtime environments |
| **Data Tier** | PostgreSQL 15 + Redis 7 | Relational database + distributed cache |
| **Messaging** | RabbitMQ | Async message queue |
| **Observability** | Prometheus + Grafana + Node Exporter | Metrics collection & visualization |
| **Logging** | Elasticsearch + Logstash + Kibana | Centralized log management (ELK Stack) |

**Quick Start:**
```bash
cd docker-compose
bash setup.sh
docker compose up -d
```

---

### ☸️ Kubernetes Manifests (9 Production-Ready Deployments)

Enterprise patterns with best practices:

- **Horizontal Pod Autoscaler (HPA)** on Tomcat (CPU-based scaling)
- **StatefulSet** for PostgreSQL with persistent volumes
- **Secrets** for credential management
- **RBAC** for Prometheus service discovery
- **Ingress Controller** for routing
- **Health checks** and resource limits on all pods

**Deploy:**
```bash
cd kubernetes
kubectl apply -f .
kubectl get all -n enterprise-middleware
```

---

## 💻 Sample Applications

### Node.js Express API
- REST endpoints with PostgreSQL integration
- Redis caching layer
- Prometheus metrics endpoint
- Health check implementation

### Java Spring Boot API
- Actuator endpoints
- JPA/Hibernate integration
- Production-ready structure

### Responsive Frontend
- HTML/CSS/JS dashboard
- Service monitoring interface

---

## 📊 Monitoring & Observability

### Metrics (Prometheus + Grafana)
- System metrics via Node Exporter
- Application metrics from custom endpoints
- Pre-configured dashboards

### Logs (ELK Stack)
- Centralized log aggregation
- Real-time log analysis with Kibana
- Logstash pipelines for parsing

### Health Checks
- Liveness and readiness probes
- Service dependency verification
- Automated restart policies

---

## 🛠️ Automation & Scripts

### PowerShell
- IIS app pool monitoring
- Windows service health checks

### Bash
- Nginx status verification
- Container orchestration helpers

### Python
- Tomcat automation
- Deployment validation

### Makefile
Quick commands for Docker Compose operations:
```bash
make up      # Start services
make down    # Stop services
make logs    # View logs
make clean   # Remove all data
```

---

## 📚 Learning Objectives

This platform demonstrates proficiency in:

✅ **Container Orchestration** - Docker Compose + Kubernetes  
✅ **Infrastructure as Code** - Declarative configs, GitOps-ready  
✅ **Observability** - Metrics, logs, traces, health checks  
✅ **High Availability** - Autoscaling, replication, load balancing  
✅ **Security** - Secrets management, RBAC, network policies  
✅ **Automation** - Scripts across Windows/Linux environments  
✅ **Multi-language Support** - Java, Node.js, Python, Bash, PowerShell  

---

## 🎓 Use Cases

- **Troubleshooting Practice**: Simulate failures, debug issues
- **Performance Testing**: Load testing with realistic stack
- **Interview Preparation**: Demonstrate hands-on SRE skills
- **Technology Evaluation**: Compare middleware solutions
- **Training Material**: Onboarding new team members

---

## 🚀 Getting Started

### Prerequisites
- Docker Desktop 20.10+
- Kubernetes cluster (Minikube/Kind/Docker Desktop)
- 8GB RAM minimum
- 20GB disk space

### Quick Deploy
```bash
# Clone repository
git clone https://github.com/ArthrR/middleware-sre-platform.git
cd middleware-sre-platform

# Option 1: Docker Compose
cd docker-compose && docker compose up -d

# Option 2: Kubernetes
cd kubernetes && kubectl apply -f .
```

### Access Services
- **Application**: http://localhost
- **Grafana**: http://localhost:3000 (admin/admin)
- **Prometheus**: http://localhost:9090
- **Kibana**: http://localhost:5601
- **RabbitMQ**: http://localhost:15672 (admin/admin)

---

## 📁 Repository Structure

```
middleware-sre-platform/
├── docker-compose/          # Container orchestration
│   ├── apps/               # Sample applications
│   │   ├── nodejs/        # Express API
│   │   └── java/          # Spring Boot API
│   ├── nginx/             # Reverse proxy configs
│   ├── prometheus/        # Monitoring configs
│   └── docker-compose.yml # Service definitions
├── kubernetes/             # K8s manifests
│   ├── namespace.yaml
│   ├── deployments/
│   ├── services/
│   └── monitoring/
├── scripts/               # Automation scripts
│   ├── powershell/       # Windows automation
│   ├── bash/             # Linux automation
│   └── python/           # Cross-platform tools
└── docs/                 # Additional documentation
```

---

## 🔧 Configuration

All services use environment variables for configuration. See `.env.example` in each directory.

**Key Configuration Files:**
- `docker-compose/.env` - Service credentials
- `prometheus/prometheus.yml` - Scrape configs
- `kubernetes/secrets.yaml` - K8s secrets

---

## 📈 Roadmap

Future enhancements planned:

- [ ] Service mesh integration (Istio)
- [ ] CI/CD pipeline examples
- [ ] Terraform infrastructure provisioning
- [ ] Ansible playbooks
- [ ] Network policy examples
- [ ] Vault integration for secrets

---

## 🤝 Contributing

This is a personal learning project, but suggestions are welcome! Open an issue to discuss improvements.

---

## 📄 License

MIT License - Feel free to use for learning purposes.

---

## 👤 Author

**Arthur Silvestre Oliveira**  
Site Reliability Engineer | Open to Work  
📧 arthur.oliveiraa254@gmail.com  
🔗 [LinkedIn](https://linkedin.com/in/arthur-s-oliveira) | [GitHub](https://github.com/ArthrR) | [Credly](https://www.credly.com/users/arthur-silvestre-oliveira)

---

## 🌟 Acknowledgments

Inspired by real-world enterprise environments and industry best practices. Built as a demonstration of SRE skills covering:
- Container orchestration
- Infrastructure automation
- Observability implementation
- Multi-tier application architecture
- Cross-platform scripting

---

**⚠️ Note**: This is a learning environment. For production deployments, additional security hardening, high-availability configurations, and disaster recovery strategies should be implemented.
