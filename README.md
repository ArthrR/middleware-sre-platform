# 🤖 AI Platform & Infrastructure Lab

> **AI/MLOps Learning Lab** | Production-grade infrastructure and AI platform patterns for study and demonstration

[![Docker](https://img.shields.io/badge/Docker-Compose-2496ED?logo=docker)](docker-compose/)
[![Kubernetes](https://img.shields.io/badge/Kubernetes-Manifests-326CE5?logo=kubernetes)](kubernetes/)
[![Monitoring](https://img.shields.io/badge/Monitoring-Prometheus%20%7C%20Grafana-E6522C)](prometheus/)
[![Terraform](https://img.shields.io/badge/Infra-Terraform-623CE4?logo=terraform)](terraform/)

---

## 📖 About This Project

This repository started as a **SRE reference platform** and is now evolving into a **full AI Platform / MLOps lab**.

It showcases:
- Enterprise-grade infrastructure patterns (Docker, Kubernetes, Terraform)
- Monitoring and observability (Prometheus, Grafana, ELK)
- Automation practices (scripts, CI/CD)
- And, increasingly, **AI workloads**: LLM serving, RAG pipelines, and MLOps tooling

**Purpose:** educational sandbox for:
- Practicing SRE and platform engineering
- Deploying and operating AI workloads in realistic environments
- Demonstrating technical proficiency across infra + AI tooling

---

## 🎯 What's Inside

### 🐳 Docker Compose Stack (12+ Services)

Complete containerized environment with real-world integrations:

| Category | Services | Purpose |
|----------|----------|---------|
| **Web Tier** | Nginx | Reverse proxy & load balancer |
| **Application Tier** | Tomcat 10 + Node.js 18 | Java & JavaScript runtime environments |
| **Data Tier** | PostgreSQL 15 + Redis 7 | Relational database + distributed cache |
| **Messaging** | RabbitMQ | Async message queue |
| **Observability** | Prometheus + Grafana + Node Exporter | Metrics collection & visualization |
| **Logging** | Elasticsearch + Logstash + Kibana | Centralized log management (ELK Stack) |
| **AI (planned)** | Ollama / vLLM + FastAPI + Qdrant | LLM serving and RAG pipelines |

**Quick Start:**
```bash
cd docker-compose
bash setup.sh
docker compose up -d
```

---

### ☸️ Kubernetes Manifests (Production-Ready Patterns)

Enterprise patterns with best practices:

- **Horizontal Pod Autoscaler (HPA)** on application workloads (CPU-based scaling)
- **StatefulSet** for PostgreSQL with persistent volumes
- **Secrets** for credential management
- **RBAC** for Prometheus service discovery
- **Ingress Controller** for routing
- **Health checks** and resource limits on all pods
- **(Planned)** AI workloads: LLM deployments and RAG services

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

### (Planned) AI Services
- FastAPI AI gateway
- LLM chat and completion endpoints
- RAG endpoint using vector search and context injection

---

## 📊 Monitoring & Observability

### Metrics (Prometheus + Grafana)
- System metrics via Node Exporter
- Application metrics from custom endpoints
- Pre-configured dashboards
- **Upcoming:** AI-specific metrics (inference latency, tokens/sec, error rates)

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
- **Future:** AI pipeline helpers (data ingestion, embedding generation)

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

This lab demonstrates proficiency in:

✅ **Container Orchestration** — Docker Compose + Kubernetes  
✅ **Infrastructure as Code** — Declarative configs, GitOps-ready  
✅ **Observability** — Metrics, logs, health checks  
✅ **High Availability** — Autoscaling, replication, load balancing  
✅ **Security** — Secrets management, RBAC, network policies  
✅ **Automation** — Scripts across Windows/Linux environments  
✅ **Emerging AI Platform Skills** — LLM serving, RAG, MLOps (ongoing work)  

---

## 🎓 Use Cases

- **Troubleshooting Practice**: Simulate failures, debug issues
- **Performance Testing**: Load testing with realistic stack
- **Interview Preparation**: Demonstrate hands-on platform and AI skills
- **Technology Evaluation**: Compare middleware and AI solutions
- **Training Material**: Onboarding for infra + AI platform topics

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
git clone https://github.com/ArthrR/ai-platform-lab.git
cd ai-platform-lab

# Option 1: Docker Compose
cd docker-compose && docker compose up -d

# Option 2: Kubernetes
cd kubernetes && kubectl apply -f .
```

---

## 📁 Repository Structure

```text
ai-platform-lab/
├── docker-compose/          # Container orchestration
│   ├── apps/                # Sample applications
│   ├── nginx/               # Reverse proxy configs
│   ├── prometheus/          # Monitoring configs
│   └── docker-compose.yml   # Service definitions
├── kubernetes/              # K8s manifests
│   ├── namespace.yaml
│   ├── deployments/
│   ├── services/
│   └── monitoring/
├── prometheus/              # Prometheus-specific configs
├── terraform/               # Infrastructure provisioning (cloud-ready)
├── scripts/                 # Automation scripts
│   ├── powershell/
│   ├── bash/
│   └── python/
└── docs/                    # Additional documentation
```

---

## 🔧 Configuration

All services use environment variables for configuration. See `.env.example` in each directory.

**Key Configuration Files:**
- `docker-compose/.env` - Service credentials
- `prometheus/prometheus.yml` - Scrape configs
- `kubernetes/secrets.yaml` - K8s secrets

---

## 📈 Roadmap (AI/MLOps Focus)

Future enhancements planned:

- [ ] LLM serving with Ollama or vLLM
- [ ] FastAPI AI gateway with chat and RAG endpoints
- [ ] Qdrant vector database for semantic search
- [ ] MLflow integration for experiment tracking
- [ ] DVC for dataset versioning
- [ ] CI/CD pipeline examples for AI workloads
- [ ] Evidently AI for model performance and data drift monitoring
- [ ] Terraform modules for cloud AI infrastructure (Azure/AWS)

---

## 👤 Author

**Arthur Silvestre Oliveira**  
AI Platform / MLOps Engineer (transitioning from SRE)  
📧 arthur.oliveiraa254@gmail.com  
🔗 [LinkedIn](https://linkedin.com/in/arthur-s-oliveira) | [GitHub](https://github.com/ArthrR)

---

**⚠️ Note**: This is a learning environment. For production deployments, additional security hardening, high-availability configurations, and disaster recovery strategies should be implemented.
