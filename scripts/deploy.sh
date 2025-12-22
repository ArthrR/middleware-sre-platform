#!/bin/bash
set -e

echo "================================================"
echo "WSO2 API Manager - Deployment Script"
echo "================================================"

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Funções
log_info() {
  echo -e "${GREEN}[INFO]${NC} $1"
}

log_error() {
  echo -e "${RED}[ERROR]${NC} $1"
}

log_warn() {
  echo -e "${YELLOW}[WARN]${NC} $1"
}

# Verificar pré-requisitos
log_info "Verificando pré-requisitos..."

if ! command -v docker &> /dev/null; then
  log_error "Docker não encontrado!"
  exit 1
fi

if ! command -v kubectl &> /dev/null; then
  log_error "kubectl não encontrado!"
  exit 1
fi

if ! command -v terraform &> /dev/null; then
  log_warn "Terraform não encontrado - pulando IaC"
fi

# Docker Compose Deploy
log_info "Iniciando stack Docker Compose..."
cd "$(dirname "$0")/../docker-compose"
docker-compose up -d

log_info "Aguardando serviços iniciarem..."
sleep 30

# Verificar saúde
log_info "Verificando saúde dos containers..."
docker-compose ps

# Kubernetes Deploy
log_info "Deployando em Kubernetes..."
cd "$(dirname "$0")/../kubernetes"
kubectl apply -f deployment.yaml

log_info "Aguardando pods estarem prontos..."
kubectl wait --for=condition=available --timeout=300s \
  deployment/wso2-api-manager -n wso2

log_info "Verificando pods..."
kubectl get pods -n wso2

# Health Check
log_info "Executando health checks..."
sleep 10

# API Manager
log_info "Verificando API Manager..."
curl -k https://localhost:9443/am/services/HealthCheckService || log_warn "API Manager ainda iniciando..."

# Prometheus
log_info "Verificando Prometheus..."
curl -s http://localhost:9090/-/healthy || log_warn "Prometheus ainda iniciando..."

# Relatório
log_info "================================================"
log_info "✅ Deploy Concluído!"
log_info "================================================"
log_info "Serviços disponíveis:"
log_info "  API Manager:    https://localhost:9443"
log_info "  Prometheus:     http://localhost:9090"
log_info "  Grafana:        http://localhost:3000 (admin/admin)"
log_info "  Kibana:         http://localhost:5601"
log_info "  MySQL:          localhost:3306"
log_info "================================================"