# WSO2 Demo Lab – SRE / DevOps Practice

This repository contains a local lab to practice SRE and DevOps concepts using WSO2 and an observability stack.  
It is organized to simulate a small production-like environment with APIs, metrics, logs and infrastructure as code.

## Structure

- `docker-compose/` – Brings up the core services (WSO2 API Manager, database, Prometheus, Grafana, ELK, etc.).
- `kubernetes/` – Manifests (Deployment, Service, ConfigMap) to practice running similar components on Kubernetes.
- `terraform/` – Infrastructure as Code experiments (providers, resources, basic cloud setup).
- `prometheus/` – Prometheus configuration for scraping metrics.
- `scripts/` – Helper scripts (deploy, health checks, monitoring setup).
- `.vscode/` – Editor configuration to speed up development and consistency.

## Goals

- Practice deploying and managing WSO2-based services.
- Exercise monitoring and troubleshooting using Prometheus and Grafana.
- Experiment with Terraform for IaC and Kubernetes manifests for container orchestration.
- Build material to discuss real, hands-on labs during SRE / DevOps interviews.

## How to run (local Docker)

From the `docker-compose` folder:

docker compose up -d
docker compose ps

Then access, for example:

- Prometheus: `http://localhost:9090`
- Grafana: `http://localhost:3000` (or the port configured in `docker-compose.yml`)
