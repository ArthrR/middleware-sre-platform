from qdrant_client import AsyncQdrantClient
from qdrant_client.http import models as qmodels


class VectorStore:
    def __init__(self, url: str, collection: str):
        self._client = AsyncQdrantClient(url=url)
        self._collection = collection

    async def ensure_collection(self, vector_size: int) -> None:
        exists = await self._client.collection_exists(self._collection)
        if not exists:
            await self._client.create_collection(
                collection_name=self._collection,
                vectors_config=qmodels.VectorParams(
                    size=vector_size, distance=qmodels.Distance.COSINE
                ),
            )

    async def upsert_chunks(self, points: list[qmodels.PointStruct]) -> None:
        await self._client.upsert(collection_name=self._collection, points=points)

    async def search(self, vector: list[float], top_k: int) -> list[dict]:
        try:
            results = await self._client.query_points(
                collection_name=self._collection, query=vector, limit=top_k
            )
        except Exception:
            return []
        return [
            {"text": point.payload.get("text", ""), "source": point.payload.get("source", ""), "score": point.score}
            for point in results.points
        ]

    async def count(self) -> int:
        try:
            info = await self._client.count(self._collection)
        except Exception:
            return 0
        return info.count
