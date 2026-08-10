# Architecture — AI Platform Additions

This documents the AI/MLOps layer added on top of the existing SRE/middleware stack (Docker Compose, Kubernetes, Terraform, Prometheus/Grafana, CI/CD — see the top-level `README.md` for those). It exists to explain **why** things are built this way, not just what's there.

## Component overview

```
                     docker-compose "ai" profile (opt-in)
        ┌──────────────────────────────────────────────────────────┐
        │                                                            │
        │   ┌─────────┐   embeds/    ┌─────────┐                    │
        │   │ Ollama  │◄────chats────┤AI Gateway│──metrics──► Prometheus
        │   │ (LLM +  │              │ (FastAPI)│                    │
        │   │ embed)  │              └────┬─────┘                    │
        │   └─────────┘                   │ search                   │
        │                                 ▼                          │
        │                          ┌─────────────┐                   │
        │                          │   Qdrant    │                   │
        │                          │ (vectors)   │                   │
        │                          └─────────────┘                   │
        │                                                            │
        │   ┌─────────┐                                              │
        │   │ MLflow  │◄──logs runs/models── ml/anomaly-detection/   │
        │   │(tracking│                       train.py (offline,     │
        │   │+registry)                       run from host/CI)      │
        │   └─────────┘                                              │
        └──────────────────────────────────────────────────────────┘

        kubernetes/ (subset deployed): ai-gateway.yaml, qdrant.yaml
        terraform/ (opt-in via enable_ai_platform): ai-gateway ConfigMap, Qdrant Helm release
```

## Why Ollama, not vLLM

vLLM's value — PagedAttention, continuous batching, high-throughput serving — targets a Linux host with a CUDA GPU. This lab runs on Docker Desktop without a confirmed GPU node, so vLLM would mean either an unsupported CPU build or a stack that doesn't start. Ollama ships an official Docker image, runs fine CPU-only with small quantized models (`llama3.2:1b`, `nomic-embed-text`), and — the deciding factor for the metrics work below — returns **real** token/timing telemetry (`eval_count`, `eval_duration`) on every non-streamed response, so `ai_gateway_tokens_per_second` is measured, not estimated.

This is a deliberate trade-off, not a limitation being glossed over: a production deployment with a GPU node pool would swap the `OllamaClient` in `docker-compose/apps/ai-gateway/app/ollama_client.py` for a vLLM or KServe backend behind the same `/chat` and `/rag/query` API. The gateway's HTTP interface doesn't need to change for that swap.

## RAG data flow

1. `docker-compose/apps/ai-gateway/ingest/ingest_docs.py` walks the repo's own markdown docs (`README.md`, `kubernetes/README.md`, `docker-compose/DOCKER_README.md`, `terraform/README.md`, etc.), chunks them by paragraph up to ~800 chars, embeds each chunk via Ollama's `nomic-embed-text`, and upserts into a Qdrant collection (`lab-docs`).
2. `POST /rag/query` embeds the incoming question the same way, does a cosine-similarity search in Qdrant for the top-k chunks, and builds a system prompt grounding the LLM's answer in only that retrieved context.
3. The response includes `sources` (file + similarity score) so answers are auditable against the actual docs.

Using the repo's own documentation as the RAG corpus was a deliberate choice: it needs no external dataset, is fully reproducible from a fresh clone, and gives a concrete demo ("ask the gateway questions about this lab's own infrastructure").

## MLflow workflow

`ml/anomaly-detection/train.py` fits an `IsolationForest` on metrics shaped like this lab's own Prometheus output (`cpu_usage`, `request_latency_ms`, `error_rate`), logging params/metrics/a plot artifact/a registered model version to the `mlflow` service. The use case — anomaly detection on infra metrics — was chosen over a generic tutorial dataset (iris/titanic) specifically because it's a real, recognizable AIOps pattern that ties back to the SRE side of this lab rather than being disconnected from it. See `ml/README.md` for the full workflow, including the optional "live" data path that pulls real metrics from this stack's own running Prometheus, and the minimal local-remote DVC setup used to version the training dataset.

## Kubernetes / Terraform scope

Ollama and MLflow are **not** deployed to Kubernetes — they're heavier, stateful services that make sense on a laptop via docker-compose but not as a bare Deployment on a local cluster (no GPU scheduling, no real persistence story here). `ai-gateway` and `qdrant` **are** deployed (`kubernetes/ai-gateway.yaml`, `kubernetes/qdrant.yaml`, gated in Terraform behind `var.enable_ai_platform`) because they're stateless/lightweight enough to demonstrate the actual serving pattern — a gateway Deployment with an HPA in front of a vector store — without requiring GPU infrastructure this lab doesn't have.

Because Ollama isn't in-cluster, `kubernetes/ai-gateway.yaml`'s ConfigMap points `OLLAMA_BASE_URL` at `host.docker.internal`, reaching an Ollama started via `docker compose --profile ai up -d ollama` on the same machine. This works on Docker Desktop Kubernetes; Minikube/Kind need a different host-reachability approach (e.g. `minikube ssh` port-forwarding or `host.minikube.internal`). In a real production deployment this whole config key would instead point at a KServe/vLLM Service running in the same cluster.

## Known limitations

- No GPU support anywhere in this lab — everything above runs CPU-only by design, which caps model size and throughput.
- The RAG pipeline has no re-ranking, no chunk-overlap, and no incremental/streaming ingestion — it's a demonstration of the pattern, not a tuned retrieval system.
- No prompt-versioning or hallucination-detection tooling (the LLMOps concerns beyond classic MLOps) — flagged here as a deliberate scope boundary, not an oversight.
- `docker-compose/apps/ai-gateway`'s Qdrant/Ollama URLs and the Kubernetes ConfigMap's `host.docker.internal` value are both environment-specific; see each file's comments before reusing this outside a Docker Desktop laptop setup.
