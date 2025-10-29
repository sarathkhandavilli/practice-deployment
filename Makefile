.PHONY: up down build logs

# Detect Python
ifeq ($(OS),Windows_NT)
PYTHON := python
else
PYTHON := $(shell command -v python3 2>/dev/null || command -v python 2>/dev/null)
endif

COMPOSE_CMD := $(PYTHON) ./scripts/compose.py

# Detect Host IP (EC2 or Local)
BACKEND_HOST := $(shell curl -s --connect-timeout 1 http://169.254.169.254/latest/meta-data/public-ipv4 || curl -s https://ifconfig.me || echo localhost)
VITE_BACKEND_URL := http://$(BACKEND_HOST):5000

# Cross-platform environment variable setting
ifeq ($(OS),Windows_NT)
SET_ENV := set VITE_BACKEND_URL=$(VITE_BACKEND_URL) &&
else
SET_ENV := VITE_BACKEND_URL=$(VITE_BACKEND_URL)
endif

# Bring up containers
up:
	@echo "🌍 Detected backend host: $(BACKEND_HOST)"
	@echo "🔗 Using VITE_BACKEND_URL=$(VITE_BACKEND_URL)"
	@$(SET_ENV) $(COMPOSE_CMD) up -d --build

# Stop containers
down:
	@$(COMPOSE_CMD) down

# Rebuild containers
build:
	@echo "🔨 Building with VITE_BACKEND_URL=$(VITE_BACKEND_URL)"
	@$(SET_ENV) $(COMPOSE_CMD) build

# View logs
logs:
	@$(COMPOSE_CMD) logs -f
