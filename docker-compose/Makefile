# Makefile for Enterprise Middleware Stack
.PHONY: help up down restart logs ps clean setup

help:
	@echo "Available commands:"
	@echo "  make setup    - Create directory structure"
	@echo "  make up       - Start all services"
	@echo "  make down     - Stop all services"
	@echo "  make restart  - Restart all services"
	@echo "  make logs     - Show logs (all services)"
	@echo "  make ps       - Show running containers"
	@echo "  make clean    - Remove all containers and volumes"

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
