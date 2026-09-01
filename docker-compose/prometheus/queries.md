# Prometheus Queries — ai-platform-lab

Useful PromQL for the services actually scraped by this stack (see `prometheus/prometheus.yml`).

## Application Tier

### Request rate (Node.js API)
```promql
rate(http_requests_total{job="nodejs-api"}[5m])
```

### Error rate (4xx + 5xx)
```promql
rate(http_requests_total{job="nodejs-api", status=~"4..|5.."}[5m])
```

### Latency — p50 / p99
```promql
histogram_quantile(0.5, rate(http_request_duration_seconds_bucket{job="nodejs-api"}[5m]))
histogram_quantile(0.99, rate(http_request_duration_seconds_bucket{job="nodejs-api"}[5m]))
```

## Host / Container Metrics (Node Exporter)

### CPU usage
```promql
100 * (1 - avg by (instance) (rate(node_cpu_seconds_total{mode="idle"}[5m])))
```

### Memory usage
```promql
100 * (1 - (node_memory_MemAvailable_bytes / node_memory_MemTotal_bytes))
```

### Disk I/O
```promql
rate(node_disk_io_time_seconds_total[5m])
```

## Kafka (Message Queue, via `kafka-exporter`)

### Broker count (up = healthy cluster)
```promql
kafka_brokers
```

### Messages produced per topic (offset growth)
```promql
rate(kafka_topic_partition_current_offset[5m])
```

### Consumer group lag
```promql
kafka_consumergroup_lag
```

## Kubernetes (when deployed via `kubernetes/monitoring.yaml`)

### Node CPU
```promql
100 * (1 - avg by (node) (rate(node_cpu_seconds_total{mode="idle"}[5m])))
```

### Pod restarts
```promql
increase(kube_pod_container_status_restarts_total[1h]) > 0
```

### Pod availability (SLO-style check)
```promql
kube_deployment_status_replicas_available / kube_deployment_spec_replicas
```

## AI Gateway (LLM/RAG service — `ai` compose profile)

Available once `docker compose --profile ai up -d` is running; see `docker-compose/apps/ai-gateway/README.md`.

### Inference request rate
```promql
rate(ai_gateway_http_requests_total[5m])
```

### Inference latency — p99
```promql
histogram_quantile(0.99, rate(ai_gateway_inference_duration_seconds_bucket[5m]))
```

### Tokens per second (Ollama, real telemetry)
```promql
avg(ai_gateway_tokens_per_second)
```

### RAG retrieval size
```promql
histogram_quantile(0.5, rate(ai_gateway_rag_retrieved_chunks_bucket[5m]))
```

### AI gateway error rate
```promql
rate(ai_gateway_errors_total[5m])
```
