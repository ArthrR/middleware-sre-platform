# Kubernetes Manifests - Enterprise Middleware Platform

Complete Kubernetes deployment for enterprise middleware stack with autoscaling, monitoring, and best practices.

## 🏗️ Architecture

```
                     [Ingress Controller]
                            │
          ┌─────────────────┼─────────────────┐
          │                 │                 │
    [Nginx LB]      [Grafana]        [Prometheus]
          │
    ┌─────┴─────┐
    │           │
[Tomcat]   [Node.js]
  (HPA)      (2 pods)
    │           │
    └─────┬─────┘
          │
    [PostgreSQL]────[Redis]
   (StatefulSet)   (Cache)
```

## 📦 Components

| Component | Type | Replicas | Purpose |
|-----------|------|----------|---------|
| Nginx | Deployment | 2 | Reverse proxy & load balancer |
| Tomcat | Deployment + HPA | 2-10 | Java application server |
| Node.js | Deployment | 2 | REST API service |
| PostgreSQL | StatefulSet | 1 | Primary database |
| Redis | Deployment | 1 | Cache layer |
| Prometheus | Deployment | 1 | Metrics collection |
| Grafana | Deployment | 1 | Visualization |

## 🚀 Deployment

### Prerequisites
- Kubernetes cluster (Minikube, Kind, EKS, AKS, GKE)
- kubectl configured
- 4GB RAM minimum per node
- Ingress controller (nginx-ingress)

### Install Ingress Controller (if needed)
```bash
# For Minikube
minikube addons enable ingress

# For other clusters
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.8.2/deploy/static/provider/cloud/deploy.yaml
```

### Deploy All Resources
```bash
# Apply in order
kubectl apply -f k8s-namespace.yaml
kubectl apply -f k8s-postgres.yaml
kubectl apply -f k8s-redis.yaml
kubectl apply -f k8s-tomcat.yaml
kubectl apply -f k8s-nodejs.yaml
kubectl apply -f k8s-nginx.yaml
kubectl apply -f k8s-monitoring.yaml
kubectl apply -f k8s-ingress.yaml

# Or apply all at once
kubectl apply -f .
```

### Verify Deployment
```bash
# Check all resources
kubectl get all -n enterprise-middleware

# Check pods status
kubectl get pods -n enterprise-middleware -w

# Check services
kubectl get svc -n enterprise-middleware

# Check ingress
kubectl get ingress -n enterprise-middleware
```

## 📊 Access Services

### Get External IPs
```bash
# For LoadBalancer services
kubectl get svc -n enterprise-middleware

# For Minikube
minikube service list -n enterprise-middleware
```

### Access Points
- **Application**: http://<NGINX_EXTERNAL_IP>
- **Grafana**: http://<GRAFANA_EXTERNAL_IP>:3000 (admin/admin)
- **Prometheus**: http://<PROMETHEUS_EXTERNAL_IP>:9090

### Port Forwarding (Alternative)
```bash
# Nginx
kubectl port-forward -n enterprise-middleware svc/nginx-service 8080:80

# Grafana
kubectl port-forward -n enterprise-middleware svc/grafana-service 3000:3000

# Prometheus
kubectl port-forward -n enterprise-middleware svc/prometheus-service 9090:9090

# PostgreSQL (for debugging)
kubectl port-forward -n enterprise-middleware svc/postgres-service 5432:5432
```

## 🔧 Configuration

### Update Database Credentials
```bash
# Edit secret
kubectl edit secret db-secret -n enterprise-middleware

# Or recreate
kubectl delete secret db-secret -n enterprise-middleware
kubectl create secret generic db-secret \
  --from-literal=username=newuser \
  --from-literal=password=newpass \
  --from-literal=database=newdb \
  -n enterprise-middleware
```

### Scale Applications
```bash
# Manual scaling
kubectl scale deployment tomcat-app --replicas=5 -n enterprise-middleware
kubectl scale deployment nodejs-api --replicas=3 -n enterprise-middleware

# HPA (automatic) - already configured for Tomcat
kubectl get hpa -n enterprise-middleware
```

### Update Nginx Config
```bash
# Edit ConfigMap
kubectl edit configmap nginx-config -n enterprise-middleware

# Restart pods to apply
kubectl rollout restart deployment nginx-lb -n enterprise-middleware
```

## 🐛 Troubleshooting

### Check Pod Logs
```bash
# Specific pod
kubectl logs <pod-name> -n enterprise-middleware

# Follow logs
kubectl logs -f <pod-name> -n enterprise-middleware

# Previous container (if crashed)
kubectl logs <pod-name> --previous -n enterprise-middleware
```

### Debug Pod Issues
```bash
# Describe pod
kubectl describe pod <pod-name> -n enterprise-middleware

# Execute commands in pod
kubectl exec -it <pod-name> -n enterprise-middleware -- sh

# Check events
kubectl get events -n enterprise-middleware --sort-by='.lastTimestamp'
```

### Common Issues

**Pods in Pending state:**
```bash
# Check resource availability
kubectl describe node

# Check PVC status
kubectl get pvc -n enterprise-middleware
```

**ImagePullBackOff:**
```bash
# Check image name in deployment
kubectl describe pod <pod-name> -n enterprise-middleware

# Verify image exists
docker pull <image-name>
```

**CrashLoopBackOff:**
```bash
# Check logs
kubectl logs <pod-name> -n enterprise-middleware

# Check resource limits
kubectl describe pod <pod-name> -n enterprise-middleware
```

## 📈 Monitoring

### Prometheus Queries
```promql
# CPU usage by pod
sum(rate(container_cpu_usage_seconds_total[5m])) by (pod)

# Memory usage by pod
sum(container_memory_usage_bytes) by (pod)

# HTTP request rate
rate(http_requests_total[5m])

# Pod restart count
kube_pod_container_status_restarts_total
```

### Grafana Dashboards
1. Access Grafana
2. Add Prometheus datasource: http://prometheus-service:9090
3. Import dashboards:
   - Kubernetes Cluster Monitoring (ID: 315)
   - Kubernetes Pods (ID: 6417)
   - Node Exporter Full (ID: 1860)

## 🔄 Updates & Rollback

### Rolling Update
```bash
# Update image
kubectl set image deployment/tomcat-app tomcat=tomcat:10-jdk17 -n enterprise-middleware

# Check rollout status
kubectl rollout status deployment/tomcat-app -n enterprise-middleware

# Pause rollout
kubectl rollout pause deployment/tomcat-app -n enterprise-middleware

# Resume rollout
kubectl rollout resume deployment/tomcat-app -n enterprise-middleware
```

### Rollback
```bash
# Rollback to previous version
kubectl rollout undo deployment/tomcat-app -n enterprise-middleware

# Rollback to specific revision
kubectl rollout undo deployment/tomcat-app --to-revision=2 -n enterprise-middleware

# Check history
kubectl rollout history deployment/tomcat-app -n enterprise-middleware
```

## 🗑️ Cleanup

### Delete Specific Resources
```bash
# Delete deployment
kubectl delete deployment nginx-lb -n enterprise-middleware

# Delete service
kubectl delete svc nginx-service -n enterprise-middleware
```

### Delete Everything
```bash
# Delete entire namespace (⚠️ all data will be lost)
kubectl delete namespace enterprise-middleware

# Or delete all manifests
kubectl delete -f .
```

## 🔒 Security Best Practices

- ✅ Secrets used for sensitive data
- ✅ Resource limits defined
- ✅ Liveness/readiness probes configured
- ✅ Network policies (TODO)
- ✅ RBAC for Prometheus
- ⚠️ Default passwords (change in production!)

## 📚 Next Steps

1. Configure persistent volumes for PostgreSQL
2. Set up Network Policies
3. Implement Pod Security Policies
4. Add Horizontal Pod Autoscaler for Node.js
5. Configure TLS/SSL certificates
6. Set up CI/CD pipeline

---

**Author**: Arthur Oliveira | SRE @ IBM  
**GitHub**: github.com/ArthrR/middleware-sre-platform
