## Makefile - cross-platform helpers for local and EC2
.PHONY: up down detect-env

# Set working directory to the Makefile's location
MAKEFILE_DIR := $(dir $(abspath $(lastword $(MAKEFILE_LIST))))

# Discover a Python executable (works on Windows and Ubuntu)
PYTHON := $(shell command -v python3 2>/dev/null || command -v python 2>/dev/null || echo python)

# Detect environment and set appropriate IP (cross-platform via Python script)
detect-env:
	@cd "$(MAKEFILE_DIR)" && $(PYTHON) ./scripts/detect_env.py

# Bring up containers
up: detect-env
	@cd "$(MAKEFILE_DIR)" && docker compose up --build -d

# Bring down containers
down:
	@cd "$(MAKEFILE_DIR)" && docker compose down
