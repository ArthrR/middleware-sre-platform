import httpx


class OllamaClient:
    """Thin async wrapper around the Ollama REST API.

    Non-streamed responses from /api/chat and /api/generate include real
    token/timing telemetry (eval_count, eval_duration in nanoseconds), which
    we use downstream for genuine tokens/sec metrics instead of estimates.
    """

    def __init__(self, client: httpx.AsyncClient, base_url: str):
        self._client = client
        self._base_url = base_url.rstrip("/")

    async def chat(self, model: str, messages: list[dict]) -> dict:
        response = await self._client.post(
            f"{self._base_url}/api/chat",
            json={"model": model, "messages": messages, "stream": False},
            timeout=120.0,
        )
        response.raise_for_status()
        return response.json()

    async def embed(self, model: str, text: str) -> list[float]:
        response = await self._client.post(
            f"{self._base_url}/api/embed",
            json={"model": model, "input": text},
            timeout=60.0,
        )
        response.raise_for_status()
        data = response.json()
        return data["embeddings"][0]

    @staticmethod
    def tokens_per_second(ollama_response: dict) -> float:
        eval_count = ollama_response.get("eval_count", 0)
        eval_duration_ns = ollama_response.get("eval_duration", 0)
        if not eval_count or not eval_duration_ns:
            return 0.0
        return eval_count / (eval_duration_ns / 1_000_000_000)
