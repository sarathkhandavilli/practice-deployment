.PHONY: up down detect-env logs docker-check

# Set working directory to the Makefile's location
MAKEFILE_DIR := $(dir $(abspath $(lastword $(MAKEFILE_LIST))))

# Cross-platform OS detection
ifdef OS
    OSFLAG = Windows
    SHELL_REDIRECT = 2>nul
    CMD_EXISTS = where
    DIR_CHECK = if not exist "$(1)" mkdir "$(1)"
    CD_CMD = cd /d
else
    OSFLAG = Unix
    SHELL_REDIRECT = 2>/dev/null
    CMD_EXISTS = command -v
    DIR_CHECK = [ ! -d "$(1)" ] && mkdir -p "$(1)"
    CD_CMD = cd
endif

# Python detection (simplified)
ifeq ($(OSFLAG),Windows)
    PYTHON := python
else
    PYTHON := $(shell command -v python3 2>/dev/null || command -v python 2>/dev/null || echo "python-not-found")
endif
ifeq ($(PYTHON),python-not-found)
    $(error Python not found. Install with 'sudo apt install python3'.)
endif

# Docker Compose detection
ifeq ($(OSFLAG),Windows)
    DOCKER_CMD := docker compose
else
    DOCKER_CMD := $(shell docker compose version >/dev/null 2>&1 && echo "docker compose" || echo "docker-compose")
endif
ifeq ($(DOCKER_CMD),)
    $(error Docker Compose not found. Install with 'sudo apt install docker-compose'.)
endif

# Docker check target
docker-check:
	@echo "Docker: $$(docker --version)"
	@echo "Compose: $$($(DOCKER_CMD) version)"

# Detect environment (fixed for Unix/Windows)
detect-env:
	$(call DIR_CHECK,$(MAKEFILE_DIR)scripts)
	$(CD_CMD) "$(MAKEFILE_DIR)" && $(PYTHON) ./scripts/detect_env.py

# Up target
up: detect-env
	$(CD_CMD) "$(MAKEFILE_DIR)" && $(DOCKER_CMD) build && $(DOCKER_CMD) up -d
	@echo "Up! Frontend: http://localhost:5173 | Backend: http://localhost:5000"
	@echo "On EC2: Use public IP. Logs: make logs"

# Down and logs
down:
	$(CD_CMD) "$(MAKEFILE_DIR)" && $(DOCKER_CMD) down

logs:
	$(CD_CMD) "$(MAKEFILE_DIR)" && $(DOCKER_CMD) logs -f