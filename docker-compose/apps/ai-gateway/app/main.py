import time
from contextlib import asynccontextmanager

import httpx
from fastapi import FastAPI, Request, Response
from prometheus_client import CONTENT_TYPE_LATEST, generate_latest
from pydantic import BaseModel

from app.config import settings
from app.metrics import ERRORS, HTTP_DURATION, HTTP_REQUESTS, INFERENCE_DURATION, RAG_RETRIEVED_CHUNKS, TOKENS_PER_SECOND
from app.ollama_client import OllamaClient
from app.vector_store import VectorStore


@asynccontextmanager
async def lifespan(app: FastAPI):
    app.state.http_client = httpx.AsyncClient()
    app.state.ollama = OllamaClient(app.state.http_client, settings.ollama_base_url)
    app.state.vector_store = VectorStore(settings.qdrant_url, settings.qdrant_collection)
    yield
    await app.state.http_client.aclose()


app = FastAPI(title="AI Gateway", lifespan=lifespan)


@app.middleware("http")
async def track_metrics(request: Request, call_next):
    endpoint = request.url.path
    start = time.perf_counter()
    try:
        response = await call_next(request)
    except Exception as exc:
        ERRORS.labels(endpoint=endpoint, error_type=type(exc).__name__).inc()
        raise
    duration = time.perf_counter() - start
    HTTP_DURATION.labels(endpoint=endpoint).observe(duration)
    HTTP_REQUESTS.labels(endpoint=endpoint, method=request.method, status=response.status_code).inc()
    return response


class ChatRequest(BaseModel):
    message: str


class ChatResponse(BaseModel):
    reply: str
    model: str
    tokens_per_second: float


class RagQueryRequest(BaseModel):
    question: str
    top_k: int | None = None


class RagSource(BaseModel):
    source: str
    score: float


class RagQueryResponse(BaseModel):
    answer: str
    model: str
    tokens_per_second: float
    sources: list[RagSource]


@app.get("/health")
async def health():
    return {"status": "healthy"}


@app.get("/metrics")
async def metrics():
    return Response(generate_latest(), media_type=CONTENT_TYPE_LATEST)


@app.post("/chat", response_model=ChatResponse)
async def chat(body: ChatRequest, request: Request):
    ollama: OllamaClient = request.app.state.ollama
    with INFERENCE_DURATION.labels(endpoint="/chat", model=settings.ollama_model).time():
        result = await ollama.chat(settings.ollama_model, [{"role": "user", "content": body.message}])
    tps = OllamaClient.tokens_per_second(result)
    TOKENS_PER_SECOND.labels(model=settings.ollama_model).set(tps)
    return ChatResponse(
        reply=result.get("message", {}).get("content", ""),
        model=settings.ollama_model,
        tokens_per_second=tps,
    )


@app.post("/rag/query", response_model=RagQueryResponse)
async def rag_query(body: RagQueryRequest, request: Request):
    ollama: OllamaClient = request.app.state.ollama
    vector_store: VectorStore = request.app.state.vector_store
    top_k = body.top_k or settings.rag_top_k

    query_vector = await ollama.embed(settings.ollama_embed_model, body.question)
    matches = await vector_store.search(query_vector, top_k)
    RAG_RETRIEVED_CHUNKS.observe(len(matches))

    context = "\n\n".join(f"[{m['source']}]\n{m['text']}" for m in matches)
    system_prompt = (
        "You are an assistant answering questions about the ai-platform-lab repository. "
        "Use only the context below to answer; if the context doesn't contain the answer, say so.\n\n"
        f"Context:\n{context}"
    )
    messages = [
        {"role": "system", "content": system_prompt},
        {"role": "user", "content": body.question},
    ]

    with INFERENCE_DURATION.labels(endpoint="/rag/query", model=settings.ollama_model).time():
        result = await ollama.chat(settings.ollama_model, messages)
    tps = OllamaClient.tokens_per_second(result)
    TOKENS_PER_SECOND.labels(model=settings.ollama_model).set(tps)

    return RagQueryResponse(
        answer=result.get("message", {}).get("content", ""),
        model=settings.ollama_model,
        tokens_per_second=tps,
        sources=[RagSource(source=m["source"], score=m["score"]) for m in matches],
    )
