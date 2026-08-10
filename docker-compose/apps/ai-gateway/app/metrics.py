from prometheus_client import Counter, Gauge, Histogram

HTTP_REQUESTS = Counter(
    "ai_gateway_http_requests_total",
    "Total HTTP requests handled by the AI gateway",
    ["endpoint", "method", "status"],
)

HTTP_DURATION = Histogram(
    "ai_gateway_http_request_duration_seconds",
    "HTTP request duration in seconds",
    ["endpoint"],
)

INFERENCE_DURATION = Histogram(
    "ai_gateway_inference_duration_seconds",
    "Time spent waiting on the Ollama inference call",
    ["endpoint", "model"],
)

TOKENS_PER_SECOND = Gauge(
    "ai_gateway_tokens_per_second",
    "Tokens/sec of the most recent generation, from Ollama's own eval telemetry",
    ["model"],
)

RAG_RETRIEVED_CHUNKS = Histogram(
    "ai_gateway_rag_retrieved_chunks",
    "Number of chunks retrieved per RAG query",
    buckets=(0, 1, 2, 3, 4, 5, 8, 10),
)

ERRORS = Counter(
    "ai_gateway_errors_total",
    "Total errors raised by the AI gateway",
    ["endpoint", "error_type"],
)
