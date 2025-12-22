# Prometheus Queries Úteis para WSO2

## API Manager Metrics

### Taxa de Requisições por Segundo
```promql
rate(wso2_apim_requests_total[5m])
```

### Taxa de Erros (4xx + 5xx)
```promql
rate(wso2_apim_errors_total[5m])
```

### Latência Mediana
```promql
histogram_quantile(0.5, rate(wso2_apim_request_duration_seconds_bucket[5m]))
```

### Latência P99
```promql
histogram_quantile(0.99, rate(wso2_apim_request_duration_seconds_bucket[5m]))
```

### Taxa de Sucesso
```promql
100 * (1 - rate(wso2_apim_errors_total[5m]) / rate(wso2_apim_requests_total[5m]))
```

## Docker Metrics

### Uso de CPU
```promql
rate(container_cpu_usage_seconds_total[5m])
```

### Uso de Memória
```promql
container_memory_usage_bytes / 1024 / 1024
```

### I/O de Disco
```promql
rate(container_fs_io_time_seconds_total[5m])
```

## Kubernetes Metrics

### Node CPU
```promql
100 * (1 - avg by (node) (rate(node_cpu_seconds_total{mode="idle"}[5m])))
```

### Node Memória
```promql
100 * (1 - (node_memory_MemAvailable_bytes / node_memory_MemTotal_bytes))
```

### Pod Restarts
```promql
increase(kube_pod_container_status_restarts_total[1h]) > 0
```