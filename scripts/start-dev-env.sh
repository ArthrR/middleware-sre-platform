#!/bin/bash
echo "Starting WSO2 SRE Development Environment..."

# Start Docker containers
docker-compose -f ../docker-compose/docker-compose.yml up -d

# Verify containers
echo "Checking containers..."
docker ps

# Print access URLs
echo ""
echo "Environment is ready!"
echo "Prometheus: http://localhost:9090"
echo "Grafana: http://localhost:3000 (admin/admin)"
echo "Kubernetes: kubectl get nodes"