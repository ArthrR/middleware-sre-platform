#!/bin/bash

echo "========================================"
echo "WSO2 Health Check Script"
echo "========================================"

# Cores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

health_check() {
  local service=$1
  local url=$2
  local method=${3:-GET}

  echo -n "Verificando $service... "
  
  if curl -s -f -X $method "$url" &>/dev/null; then
    echo -e "${GREEN}✓ OK${NC}"
    return 0
  else
    echo -e "${RED}✗ FALHA${NC}"
    return 1
  fi
}

# Verificações
health_check "API Manager" "https://localhost:9443/am/services/HealthCheckService" "GET"
health_check "Prometheus" "http://localhost:9090/-/healthy" "GET"
health_check "Grafana" "http://localhost:3000/api/health" "GET"
health_check "Elasticsearch" "http://localhost:9200" "GET"
health_check "MySQL" "mysql://wso2_user:wso2_password@localhost:3306/wso2am_db" "CONNECT"

# Kubernetes
echo ""
echo "Kubernetes Status:"
kubectl get pods -n wso2
kubectl get svc -n wso2

echo ""
echo "========================================"