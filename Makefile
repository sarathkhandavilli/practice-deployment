.PHONY: up down build logs

# Detect Python
ifeq ($(OS),Windows_NT)
PYTHON := python
else
PYTHON := $(shell command -v python3 2>/dev/null || command -v python 2>/dev/null)
endif

COMPOSE_CMD := $(PYTHON) ./scripts/compose.py

# Bring up containers
up:
	@$(COMPOSE_CMD) up -d --build

# Stop containers
down:
	@$(COMPOSE_CMD) down

# Rebuild containers
build:
	@$(COMPOSE_CMD) build

# View logs
logs:
	@$(COMPOSE_CMD) logs -f
