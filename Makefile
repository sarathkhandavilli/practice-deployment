.PHONY: up down build logs

# Detect which compose command is available: prefer 'docker compose' (v2), fall back to 'docker-compose' (v1)
COMPOSE_CMD := $(shell (docker compose version >/dev/null 2>&1 && echo "docker compose") || (command -v docker-compose >/dev/null 2>&1 && echo "docker-compose") || echo "")
ifeq ($(COMPOSE_CMD),)
$(error Neither 'docker compose' nor 'docker-compose' found. Install Docker Compose.)
endif

# Basic Makefile: bring up/down the full application using Docker Compose

up:
	@echo "Using: $(COMPOSE_CMD)"
	@$(COMPOSE_CMD) build && $(COMPOSE_CMD) up -d

down:
	@$(COMPOSE_CMD) down

build:
	@$(COMPOSE_CMD) build

logs:
	@$(COMPOSE_CMD) logs -f