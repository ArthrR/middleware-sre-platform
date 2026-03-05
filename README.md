# Middleware & Infrastructure SRE Platform 🚀

End-to-end **Site Reliability Engineering lab** covering enterprise middleware stack: **IIS, Nginx, Tomcat** + container orchestration, cloud infrastructure, and automation.

Built to practice real-world SRE scenarios: deployment pipelines, incident response, performance optimization, and multi-platform operations.

---

## 🎯 Objectives

✅ Master **multi-platform middleware** (Windows/Linux, IIS/Nginx/Tomcat)  
✅ Practice **container orchestration** (Docker Compose → Kubernetes)  
✅ Build **Infrastructure as Code** (Terraform for Azure/AWS)  
✅ Implement **observability** (Prometheus, Grafana, centralized logging)  
✅ Automate **operational tasks** (PowerShell, Python, Bash)  
✅ Simulate **CI/CD workflows** (Jenkins, Octopus Deploy concepts)

---

## 🛠️ Technology Stack

| Layer | Technologies |
|-------|-------------|
| **Web Servers** | IIS 10, Nginx, Apache Tomcat |
| **Middleware** | WSO2 API Manager, Message Queues |
| **Containers** | Docker, Docker Compose, Kubernetes |
| **Orchestration** | K8s Deployments, Services, Ingress |
| **Cloud** | Azure (VMs, AKS, App Services), AWS (comparative) |
| **IaC** | Terraform (multi-cloud) |
| **Scripting** | PowerShell (Windows/IIS), Python (automation), Bash (Linux ops) |
| **Databases** | MS SQL Server, PostgreSQL |
| **Monitoring** | Prometheus, Grafana, ELK Stack |
| **CI/CD** | Jenkins pipelines, Octopus Deploy patterns |

---

## 📁 Repository Structure

```
├── docker-compose/
│   ├── nginx/              # Reverse proxy + load balancer setup
│   ├── tomcat/             # Java application server
│   ├── wso2/               # WSO2 API Manager stack
│   └── observability/      # Prometheus, Grafana, Elasticsearch
│
├── kubernetes/
│   ├── nginx-ingress/      # Ingress controller manifests
│   ├── tomcat-app/         # Tomcat deployment + service
│   └── monitoring/         # Prometheus Operator, Grafana
│
├── scripts/
│   ├── powershell/         # IIS app pool checks, SSL validation, Windows ops
│   ├── python/             # Middleware health checks, API testing, log analysis
│   └── bash/               # Nginx/Tomcat operations, Linux sys admin
│
├── terraform/
│   ├── azure/              # Azure VMs, AKS, networking
│   └── aws/                # Comparative cloud infrastructure
│
├── ci-cd/
│   ├── jenkins/            # Jenkinsfile examples (build, test, deploy)
│   └── octopus/            # Deployment process documentation
│
└── docs/
    ├── runbooks/           # Incident response procedures
    ├── architecture/       # System diagrams
    └── troubleshooting/    # Common issues & solutions
```

---

## 🚀 Quick Start

### Local Environment (Docker)
```bash
# Start Nginx + Tomcat + monitoring
cd docker-compose
docker compose up -d

# Verify services
docker compose ps
```

**Access points:**
- Nginx: `http://localhost:80`
- Tomcat Manager: `http://localhost:8080/manager`
- Prometheus: `http://localhost:9090`
- Grafana: `http://localhost:3000`

### Kubernetes (Minikube/Kind)
```bash
cd kubernetes
kubectl apply -f nginx-ingress/
kubectl apply -f tomcat-app/
kubectl get pods -A
```

### Automation Scripts
```bash
# Linux/Nginx health check
./scripts/bash/check-nginx-status.sh

# Python API testing
python3 scripts/python/tomcat-health-check.py

# Windows/IIS (PowerShell - requires admin)
.\scripts\powershell\Check-IISAppPools.ps1
```

---

## 🎓 Skills Demonstrated

### Middleware Administration
- IIS 10 configuration (bindings, app pools, SSL)
- Nginx reverse proxy & load balancing
- Apache Tomcat deployment & tuning
- Cross-platform troubleshooting

### Site Reliability Engineering
- Observability stack setup (metrics, logs, alerts)
- Incident response automation
- Performance optimization
- Capacity planning

### Infrastructure as Code
- Terraform modules (Azure VMs, networking, AKS)
- Repeatable infrastructure patterns
- State management best practices

### Automation & Scripting
- PowerShell for Windows/IIS operations
- Python for middleware automation
- Bash for Linux system administration
- Health checks, deployments, log analysis

### Container & Orchestration
- Multi-container applications (Docker Compose)
- Kubernetes manifests (Deployments, Services, Ingress)
- Container security & optimization

### CI/CD Concepts
- Jenkins pipeline design
- Octopus Deploy deployment patterns
- Automated testing integration

---

## 📈 Current Status & Roadmap

**✅ Implemented:**
- Docker Compose multi-service environments
- Kubernetes base manifests
- Terraform Azure VM setup
- Python/Bash automation scripts
- Prometheus + Grafana monitoring

**🚧 In Progress:**
- IIS containerization (Windows containers)
- PowerShell script library expansion
- Azure AKS deployment
- Jenkins pipeline examples

**📋 Planned:**
- Octopus Deploy integration
- Advanced Nginx configurations (caching, SSL termination)
- Tomcat clustering setup
- Comprehensive runbook library
- Automated SSL certificate renewal

---

## 🧪 Use Cases

| Scenario | Implementation |
|----------|----------------|
| **Deploy multi-tier app** | Docker Compose → K8s migration path |
| **Configure reverse proxy** | Nginx configs in `docker-compose/nginx/` |
| **Monitor middleware health** | Scripts in `scripts/` + Grafana dashboards |
| **Troubleshoot performance** | Prometheus queries + log analysis tools |
| **Practice IaC** | Terraform modules in `terraform/azure/` |
| **Simulate incidents** | Runbooks in `docs/runbooks/` |

---

## 🔧 Prerequisites

- **Docker Desktop** (20.10+)
- **kubectl** + **Minikube/Kind** (for Kubernetes)
- **Terraform** (1.0+)
- **PowerShell 7+** (cross-platform)
- **Python 3.8+**
- **Azure CLI** (for cloud deployments)

---

## 📚 Learning Resources

- IIS Administration: [Microsoft Docs](https://docs.microsoft.com/en-us/iis/)
- Nginx Docs: [nginx.org/en/docs/](https://nginx.org/en/docs/)
- Tomcat Guides: [tomcat.apache.org](https://tomcat.apache.org/)
- Prometheus Best Practices: [prometheus.io](https://prometheus.io/)
- SRE Book: [sre.google/books/](https://sre.google/books/)

---

## 🤝 Contributing

This is a personal learning lab, but suggestions are welcome! Open an issue or submit a PR.

---

## 👨‍💻 Author

**Arthur Oliveira**  
Site Reliability Engineer @ IBM | 4+ years middleware & infrastructure  
🔗 [LinkedIn](https://linkedin.com/in/arthur-s-oliveira) | 🐙 [GitHub](https://github.com/ArthrR)

---

**Built to prepare for enterprise SRE/DevOps roles** | Real-world practices, not tutorials
