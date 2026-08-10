# Makefile for ai-platform-lab
.PHONY: help up down restart logs ps clean setup ai-up ai-down ai-pull-model ai-ingest

help:
	@echo "Available commands:"
	@echo "  make setup        - Create directory structure"
	@echo "  make up           - Start core services"
	@echo "  make down         - Stop all services"
	@echo "  make restart      - Restart all services"
	@echo "  make logs         - Show logs (all services)"
	@echo "  make ps           - Show running containers"
	@echo "  make clean        - Remove all containers and volumes"
	@echo "  make ai-up        - Start core + AI services (Ollama, Qdrant, AI gateway)"
	@echo "  make ai-down      - Stop AI services"
	@echo "  make ai-pull-model - Pull the chat + embedding models into Ollama"
	@echo "  make ai-ingest    - Index the repo's docs into Qdrant for RAG"

setup:
	@bash setup.sh

up:
	@docker compose up -d
	@echo "✅ Services started!"
	@docker compose ps

down:
	@docker compose down
	@echo "✅ Services stopped!"

restart:
	@docker compose restart
	@echo "✅ Services restarted!"

logs:
	@docker compose logs -f

ps:
	@docker compose ps

clean:
	@echo "⚠️  This will remove all data. Press Ctrl+C to cancel."
	@sleep 5
	@docker compose down -v
	@echo "✅ Cleanup complete!"

ai-up:
	@docker compose --profile ai up -d
	@echo "✅ Core + AI services started!"
	@docker compose ps

ai-down:
	@docker compose --profile ai down

ai-pull-model:
	@docker compose exec ollama ollama pull $${OLLAMA_MODEL:-llama3.2:1b}
	@docker compose exec ollama ollama pull $${OLLAMA_EMBED_MODEL:-nomic-embed-text}

ai-ingest:
	@docker compose --profile ai run --rm ai-gateway python -m ingest.ingest_docs
