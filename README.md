# 🤖 AI Platform Lab

> **AI/MLOps Learning Lab** | Production-grade platform for deploying, testing, and monitoring AI workloads

[![Docker](https://img.shields.io/badge/Docker-Compose-2496ED?logo=docker)](docker-compose/)
[![Kubernetes](https://img.shields.io/badge/Kubernetes-Manifests-326CE5?logo=kubernetes)](kubernetes/)
[![Monitoring](https://img.shields.io/badge/Monitoring-Prometheus%20%7C%20Grafana-E6522C)](docker-compose/prometheus/)

---

## 📖 About This Project

This repository is a hands-on **AI Platform / MLOps reference lab** focused on deploying and observing real AI workloads in production-style environments.

It combines my infrastructure background with modern AI tooling to simulate how AI teams ship and operate:
- LLM serving
- Retrieval-Augmented Generation (RAG)
- Experiment tracking
- Model/data versioning
- AI observability
- Kubernetes-based deployment

**Purpose:** educational sandbox to practice AI platform engineering, MLOps workflows, and production deployment patterns for GenAI systems.

---

## 🎯 What's Inside

### 🐳 Core Platform Stack

| Category | Services | Purpose |
|----------|----------|---------|
| **LLM Serving** | Ollama / vLLM | Local model serving and inference |
| **RAG Layer** | FastAPI + LangChain | AI API and orchestration |
| **Vector Database** | Qdrant | Embeddings storage and semantic retrieval |
| **MLOps** | MLflow, DVC | Experiment tracking and data/model versioning |
| **Orchestration** | Airflow / Kubernetes | Pipeline and workload orchestration |
| **Observability** | Prometheus + Grafana | Metrics, dashboards, and alerting |
| **Logging** | ELK Stack | Centralized logs and troubleshooting |

---

## 💻 AI Use Cases

### LLM Inference API
- REST API for chat and completion requests
- Local model serving with open-source LLMs
- Request latency and throughput monitoring

### RAG Pipeline
- Document ingestion and embedding generation
- Vector search with Qdrant
- Context-aware prompting with LangChain

### MLOps Workflow
- Track experiments and runs with MLflow
- Version datasets and artifacts with DVC
- Automate workflow steps with pipelines

### AI Observability
- Latency, error rate, and throughput metrics
- Dashboarding in Grafana
- Logging and troubleshooting for model-serving workloads

---

## 🛠️ Technical Foundation

This project still uses infrastructure skills, but now applied to AI workloads:

- Kubernetes
- Docker
- GitHub Actions
- Terraform
- Ansible
- Prometheus
- Grafana
- Bash
- Python
- PowerShell

---

## 📁 Repository Structure

```text
ai-platform-lab/
├── services/
│   ├── api/             # FastAPI + LangChain
│   ├── ollama/          # Local LLM serving
│   ├── qdrant/          # Vector database
│   └── mlflow/          # Experiment tracking
├── kubernetes/          # K8s manifests
├── docker-compose/       # Local development stack
├── scripts/              # Automation scripts
└── docs/                 # Documentation and architecture notes
```

---

## 🚀 Getting Started

### Prerequisites
- Docker Desktop 20.10+
- Kubernetes cluster (Minikube/Kind/Docker Desktop)
- 8GB RAM minimum
- 20GB disk space

### Quick Deploy
```bash
git clone https://github.com/ArthrR/middleware-sre-platform.git
cd middleware-sre-platform

docker compose up -d
```

### Access Services
- **AI API**: http://localhost:8000
- **Grafana**: http://localhost:3000
- **Prometheus**: http://localhost:9090
- **Qdrant**: http://localhost:6333

---

## 📈 Roadmap

- [ ] LLM serving with Ollama or vLLM
- [ ] RAG pipeline with LangChain + Qdrant
- [ ] MLflow experiment tracking
- [ ] DVC for dataset versioning
- [ ] CI/CD for AI workloads
- [ ] AI observability dashboards
- [ ] Kubernetes deployment manifests

---

## 👤 Author

**Arthur Silvestre Oliveira**  
AI / MLOps / Platform Engineering  
📧 arthur.oliveiraa254@gmail.com  
🔗 [LinkedIn](https://linkedin.com/in/arthur-s-oliveira) | [GitHub](https://github.com/ArthrR)
