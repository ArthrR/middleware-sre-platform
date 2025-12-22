# WSO2 API Manager Kubernetes Deployment

## Deploy

```bash
# Criar namespace
kubectl apply -f deployment.yaml

# Verificar status
kubectl get pods -n wso2
kubectl describe deployment wso2-api-manager -n wso2

# Ver logs
kubectl logs -f deployment/wso2-api-manager -n wso2

# Port forward
kubectl port-forward svc/wso2-apim-service 8280:8280 -n wso2
```

## Escalar

```bash
kubectl scale deployment wso2-api-manager --replicas=5 -n wso2
```

## Remover

```bash
kubectl delete -f deployment.yaml
```