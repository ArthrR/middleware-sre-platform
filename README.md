# 🤖 AI Platform & Infrastructure Lab

> **AI/MLOps Learning Lab** | Production-grade infrastructure and AI platform patterns for study and demonstration

[![Docker](https://img.shields.io/badge/Docker-Compose-2496ED?logo=docker)](docker-compose/)
[![Kubernetes](https://img.shields.io/badge/Kubernetes-Manifests-326CE5?logo=kubernetes)](kubernetes/)
[![Monitoring](https://img.shields.io/badge/Monitoring-Prometheus%20%7C%20Grafana-E6522C)](docker-compose/prometheus/)
[![Terraform](https://img.shields.io/badge/Infra-Terraform-623CE4?logo=terraform)](terraform/)
[![MLflow](https://img.shields.io/badge/MLOps-MLflow-0194E2)](ml/)

---

## 📖 About This Project

This repository started as an SRE reference platform and now includes a working AI Platform / MLOps layer on top of it — not just a roadmap for one.

It showcases:
- Enterprise-grade infrastructure patterns (Docker, Kubernetes, Terraform)
- Monitoring and observability (Prometheus, Grafana, ELK) — extended with LLM inference metrics
- Automation practices (scripts, CI/CD) — extended with a matrix build/deploy for the AI services
- **AI workloads**: local LLM serving (Ollama), a RAG pipeline (Qdrant) that answers questions about this repo's own docs, and MLOps tooling (MLflow + DVC) for a model trained on this lab's own SRE metrics

**Purpose:** educational sandbox for:
- Practicing SRE and platform engineering
- Deploying and operating AI workloads in realistic environments
- Demonstrating technical proficiency across infra + AI tooling

---

## 🎯 What's Inside

### 🐳 Docker Compose Stack

Core services always on; AI services are an opt-in profile so a plain `docker compose up -d` stays lightweight.

| Category | Services | Purpose |
|----------|----------|---------|
| **Web Tier** | Nginx | Reverse proxy & load balancer |
| **Application Tier** | Tomcat 10 + Node.js 18 | Java & JavaScript runtime environments |
| **Data Tier** | PostgreSQL 15 + Redis 7 | Relational database + distributed cache |
| **Messaging** | RabbitMQ + Kafka | Async message queue + event streaming (Kafka in KRaft mode, no Zookeeper) |
| **Observability** | Prometheus + Grafana + Node Exporter | Metrics collection & visualization |
| **Logging** | Elasticsearch + Logstash + Kibana | Centralized log management (ELK Stack) |
| **AI** (`ai` profile) | Ollama + Qdrant + FastAPI AI Gateway | Local LLM serving, vector search, chat/RAG endpoints |
| **MLOps** (`ai` profile) | MLflow | Experiment tracking + model registry |

**Quick Start:**
```bash
cd docker-compose
docker compose up -d              # core stack
docker compose --profile ai up -d # + AI/MLOps services (see docker-compose/apps/ai-gateway/README.md)
```

---

### ☸️ Kubernetes Manifests (Production-Ready Patterns)

Enterprise patterns with best practices:

- **Horizontal Pod Autoscaler (HPA)** on application workloads (CPU-based scaling), including the AI gateway
- **StatefulSet** for PostgreSQL with persistent volumes
- **Secrets** for credential management
- **RBAC** for Prometheus service discovery
- **Ingress Controller** for routing
- **Health checks** and resource limits on all pods
- **AI workloads**: `ai-gateway` and `qdrant` Deployments (Ollama/MLflow stay docker-compose-only by design — see [`docs/ARCHITECTURE.md`](docs/ARCHITECTURE.md))

**Deploy:**
```bash
cd kubernetes
kubectl apply -f .
kubectl get all -n enterprise-middleware
```

---

## 💻 Sample Applications

### AI Gateway (FastAPI)
- `/chat` — direct LLM completion via Ollama
- `/rag/query` — retrieval-augmented answers grounded in this repo's own docs (Qdrant + Ollama embeddings)
- `/metrics` — Prometheus exposition: request rate, inference latency, real tokens/sec, RAG chunk counts, errors
- See [`docker-compose/apps/ai-gateway/README.md`](docker-compose/apps/ai-gateway/README.md)

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

## 🧪 MLOps

`ml/anomaly-detection/` trains an `IsolationForest` on SRE-shaped metrics (cpu/latency/error-rate) and logs the run to MLflow — params, metrics, a plot artifact, and a registered model. Chosen over a generic tutorial dataset specifically to tie back to this lab's SRE side (anomaly detection on infra metrics is a real AIOps pattern). Includes an optional path to train against this lab's own live Prometheus data instead of the committed synthetic set, and minimal DVC versioning for the dataset. See [`ml/README.md`](ml/README.md).

---

## 📊 Monitoring & Observability

### Metrics (Prometheus + Grafana)
- System metrics via Node Exporter
- Application metrics from custom endpoints
- **AI Gateway metrics**: inference latency, real tokens/sec (from Ollama's own telemetry), RAG retrieval size, error rate — pre-built Grafana dashboard auto-provisioned at `ai-gateway`
- **Kafka metrics**: broker health, topic offsets, consumer group lag via `kafka-exporter`
- See [`docker-compose/prometheus/queries.md`](docker-compose/prometheus/queries.md) for example PromQL

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
- Post-deploy health checks with automatic rollback (`scripts/bash/healthcheck-deploy.sh`), reused for both `nodejs-api` and `ai-gateway` deployments

### Python
- Tomcat automation
- Deployment validation
- Kafka producer/consumer example — simulated infra events (`scripts/python/kafka/`)
- MLOps training + Prometheus data export (`ml/anomaly-detection/`)

### Makefile
Quick commands for Docker Compose operations:
```bash
make up            # Start core services
make ai-up         # Start core + AI services
make ai-pull-model # Pull the Ollama chat + embedding models
make ai-ingest     # Index this repo's docs into Qdrant for RAG
make kafka-produce # Publish simulated infra events to Kafka
make kafka-consume # Consume infra events from Kafka
make down          # Stop all services
make logs          # View logs
make clean         # Remove all data
```

---

## 📚 Learning Objectives

This lab demonstrates proficiency in:

✅ **Container Orchestration** — Docker Compose + Kubernetes
✅ **Infrastructure as Code** — Terraform, declarative configs, GitOps-ready
✅ **Observability** — Metrics, logs, health checks, including LLM inference telemetry
✅ **High Availability** — Autoscaling, replication, load balancing
✅ **Security** — Secrets management, RBAC, network policies
✅ **Automation** — Scripts across Windows/Linux environments, matrix CI/CD
✅ **AI Platform Skills** — Local LLM serving, RAG pipelines, MLOps (MLflow, DVC), inference observability

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
- Kubernetes cluster (Minikube/Kind/Docker Desktop) — optional, for the k8s manifests
- 8GB RAM minimum (16GB recommended with the `ai` profile running)
- 20GB disk space (+ ~2GB for the default Ollama models)

### Quick Deploy
```bash
git clone https://github.com/ArthrR/ai-platform-lab.git
cd ai-platform-lab

# Option 1: Docker Compose (core stack)
cd docker-compose && docker compose up -d

# Option 1b: + AI/MLOps services
docker compose --profile ai up -d
docker compose exec ollama ollama pull llama3.2:1b
docker compose exec ollama ollama pull nomic-embed-text
docker compose --profile ai run --rm ai-gateway python -m ingest.ingest_docs

# Option 2: Kubernetes
cd kubernetes && kubectl apply -f .
```

---

## 📁 Repository Structure

```text
ai-platform-lab/
├── docker-compose/          # Container orchestration
│   ├── apps/                # Sample applications (nodejs, java, ai-gateway)
│   ├── nginx/                # Reverse proxy configs
│   ├── prometheus/          # Monitoring configs + PromQL cheat sheet
│   ├── grafana/              # Dashboard provisioning
│   └── docker-compose.yml   # Service definitions (core + "ai" profile)
├── kubernetes/               # K8s manifests (flat: namespace, per-service Deployment+Service, ai-gateway, qdrant)
├── terraform/                # Infrastructure provisioning (namespace/quota/network policies/Helm)
├── ml/                       # Offline MLOps: anomaly-detection training + MLflow + DVC
├── scripts/                  # Automation scripts (powershell/, bash/, python/)
└── docs/                     # ARCHITECTURE.md — design rationale for the AI platform additions
```

---

## 🔧 Configuration

All services use environment variables for configuration. See `.env.example` / `docker-compose/.env` in each directory.

**Key Configuration Files:**
- `docker-compose/.env` — service credentials + AI model/collection names
- `docker-compose/prometheus/prometheus.yml` — scrape configs (core + `ai-gateway`)
- `kubernetes/*.yaml` — per-service manifests, including `ai-gateway.yaml` / `qdrant.yaml`

---

## 👤 Author

**Arthur Silvestre Oliveira**
AI Platform / MLOps Engineer (transitioning from SRE)
📧 arthur.oliveiraa254@gmail.com
🔗 [LinkedIn](https://linkedin.com/in/arthur-s-oliveira) | [GitHub](https://github.com/ArthrR)

---

**⚠️ Note**: This is a learning environment. For production deployments, additional security hardening, high-availability configurations, and disaster recovery strategies should be implemented. See [`docs/ARCHITECTURE.md`](docs/ARCHITECTURE.md) for known limitations of the AI platform additions specifically.
