.PHONY: up down detect-env logs docker-check

# Set working directory to the Makefile's location
MAKEFILE_DIR := $(dir $(abspath $(lastword $(MAKEFILE_LIST))))

# Cross-platform OS detection (no shell needed)
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

# Discover Python executable (cross-platform)
ifeq ($(OSFLAG),Windows)
    PYTHON := python
    ifeq ($(shell $(CMD_EXISTS) $(PYTHON) $(SHELL_REDIRECT) | findstr . >nul && echo ok || echo fail),fail)
        $(error Python not found. Install Python 3 and ensure it's in PATH.)
    endif
else
    PYTHON := $(shell $(CMD_EXISTS) python3 $(SHELL_REDIRECT) && echo python3 || $(CMD_EXISTS) python $(SHELL_REDIRECT) && echo python || echo fail)
    ifeq ($(PYTHON),fail)
        $(error Python not found. Install Python 3.)
    endif
endif

# Detect Docker Compose command (cross-platform)
ifeq ($(OSFLAG),Windows)
    # On Windows (Docker Desktop), use integrated v2
    DOCKER_CMD := docker compose
    # Check Docker with Windows-compatible syntax
    DOCKER_CHECK := $(shell docker --version $(SHELL_REDIRECT) | findstr . >nul && echo ok || echo fail)
    ifeq ($(DOCKER_CHECK),fail)
        $(warning Docker not detected on Windows. Install Docker Desktop: https://www.docker.com/products/docker-desktop/)
    else
        $(info Docker detected on Windows.)
    endif
else
    # On Unix, detect v2 vs v1 with proper redirection
    DOCKER_CHECK := $(shell docker --version $(SHELL_REDIRECT) && echo ok || echo fail)
    ifeq ($(DOCKER_CHECK),fail)
        $(warning Docker not detected. Install Docker first.)
    endif
    DOCKER_COMPOSE := $(shell docker compose version $(SHELL_REDIRECT) && echo "docker compose" || $(CMD_EXISTS) docker-compose $(SHELL_REDIRECT) && echo "docker-compose" || echo fail)
    ifeq ($(DOCKER_COMPOSE),fail)
        $(warning Docker Compose not found. Install it (v2 plugin or standalone).)
    endif
    DOCKER_CMD := $(DOCKER_COMPOSE)
endif

# Manual Docker check target
docker-check:
	@echo "Checking Docker setup..."
	@docker --version
	@echo "Docker Compose command: $(DOCKER_CMD)"
	@$(DOCKER_CMD) version

# Detect environment and set appropriate IP (cross-platform via Python script)
detect-env:
	@$(call DIR_CHECK,$(MAKEFILE_DIR)scripts)
	@$(CD_CMD) "$(MAKEFILE_DIR)" && $(PYTHON) ./scripts/detect_env.py

# Bring up containers (detect env, build, and start)
up: detect-env
	@$(CD_CMD) "$(MAKEFILE_DIR)" && $(DOCKER_CMD) build && $(DOCKER_CMD) up -d
	@echo "Containers started successfully! Access at http://localhost:5173 (frontend) and http://localhost:5000 (backend)."
	@echo "Check logs with 'make logs' if needed."

# Bring down containers
down:
	@$(CD_CMD) "$(MAKEFILE_DIR)" && $(DOCKER_CMD) down
	@echo "Containers stopped."

# View logs
logs:
	@$(CD_CMD) "$(MAKEFILE_DIR)" && $(DOCKER_CMD) logs -f