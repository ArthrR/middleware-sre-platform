"""Chunks and embeds the repo's own markdown docs into Qdrant for the /rag/query endpoint.

Run from the container with the repo mounted read-only at /repo:
    docker compose --profile ai run --rm ai-gateway python -m ingest.ingest_docs
"""

import asyncio
import pathlib
import uuid

import httpx
from qdrant_client.http import models as qmodels

from app.config import settings
from app.ollama_client import OllamaClient
from app.vector_store import VectorStore

DOCS_ROOT = pathlib.Path("/repo")
EXCLUDE_DIRS = {".git", "node_modules", "dist", "build", "__pycache__", ".terraform"}
CHUNK_SIZE = 800


def find_markdown_files() -> list[pathlib.Path]:
    files = [
        path
        for path in DOCS_ROOT.rglob("*.md")
        if not any(part in EXCLUDE_DIRS for part in path.parts)
    ]
    return sorted(files)


def chunk_text(text: str, size: int = CHUNK_SIZE) -> list[str]:
    """Greedily packs paragraphs into chunks up to `size` chars. No overlap —
    good enough for a repo-docs RAG demo of this size."""
    paragraphs = [p.strip() for p in text.split("\n\n") if p.strip()]
    chunks: list[str] = []
    current = ""
    for paragraph in paragraphs:
        candidate = f"{current}\n\n{paragraph}" if current else paragraph
        if len(candidate) <= size:
            current = candidate
        else:
            if current:
                chunks.append(current)
            current = paragraph
    if current:
        chunks.append(current)
    return chunks


async def main() -> None:
    files = find_markdown_files()
    if not files:
        print(f"No markdown files found under {DOCS_ROOT}")
        return

    async with httpx.AsyncClient() as client:
        ollama = OllamaClient(client, settings.ollama_base_url)
        vector_store = VectorStore(settings.qdrant_url, settings.qdrant_collection)

        points: list[qmodels.PointStruct] = []
        vector_size: int | None = None
        for path in files:
            text = path.read_text(encoding="utf-8")
            source = str(path.relative_to(DOCS_ROOT))
            chunks = chunk_text(text)
            for chunk in chunks:
                embedding = await ollama.embed(settings.ollama_embed_model, chunk)
                if vector_size is None:
                    vector_size = len(embedding)
                    await vector_store.ensure_collection(vector_size)
                points.append(
                    qmodels.PointStruct(
                        id=str(uuid.uuid4()),
                        vector=embedding,
                        payload={"text": chunk, "source": source},
                    )
                )
            print(f"  chunked {source} -> {len(chunks)} chunk(s)")

        if points:
            await vector_store.upsert_chunks(points)

        print(
            f"Ingested {len(points)} chunks from {len(files)} files "
            f"into Qdrant collection '{settings.qdrant_collection}'."
        )


if __name__ == "__main__":
    asyncio.run(main())
