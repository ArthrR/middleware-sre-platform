# AI Gateway

FastAPI service that fronts a local LLM (Ollama) and a RAG pipeline (Qdrant) for the lab. Part of the `ai` docker-compose profile — see `docker-compose/docker-compose.yml`.

## Why Ollama, not vLLM

vLLM's value (PagedAttention, continuous batching, high-throughput serving) targets a Linux + CUDA GPU host. This lab runs on Docker Desktop without a confirmed GPU, so Ollama is the right choice here: official Docker image, runs fine CPU-only with small models, simple REST API, and — importantly for the metrics below — it returns **real** token/timing telemetry (`eval_count`, `eval_duration`) on every non-streamed response, so tokens/sec is measured, not estimated. In a production deployment with a GPU node pool, this gateway's Ollama client would be swapped for a vLLM/KServe backend; see `docs/ARCHITECTURE.md`.

## Endpoints

| Method | Path | Description |
|---|---|---|
| GET | `/health` | Liveness check |
| GET | `/metrics` | Prometheus exposition (scraped by the `ai-gateway` job in `prometheus.yml`) |
| POST | `/chat` | Direct chat completion via Ollama |
| POST | `/rag/query` | Embeds the question, retrieves matching chunks from Qdrant, answers grounded in that context |

## Running locally

```bash
cd docker-compose
docker compose --profile ai up -d ollama qdrant ai-gateway

# pull a small model (first run only)
docker compose exec ollama ollama pull llama3.2:1b
docker compose exec ollama ollama pull nomic-embed-text

# index the repo's own docs into Qdrant
docker compose --profile ai run --rm ai-gateway python -m ingest.ingest_docs
```

## Example requests

```bash
curl -s http://localhost:8000/chat \
  -H "Content-Type: application/json" \
  -d '{"message": "What is this lab for?"}'

curl -s http://localhost:8000/rag/query \
  -H "Content-Type: application/json" \
  -d '{"question": "What services does the docker-compose stack include?"}'
```

## Metrics exposed

`ai_gateway_http_requests_total`, `ai_gateway_http_request_duration_seconds`, `ai_gateway_inference_duration_seconds`, `ai_gateway_tokens_per_second`, `ai_gateway_rag_retrieved_chunks`, `ai_gateway_errors_total` — see `prometheus/queries.md` for example PromQL and the `ai-gateway` Grafana dashboard for a pre-built view.
