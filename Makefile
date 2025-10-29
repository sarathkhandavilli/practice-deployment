.PHONY: up down build logs detect-env

# Use the Python wrapper to run compose commands cross-platform
PYTHON := $(shell command -v python3 2>/dev/null || command -v python 2>/dev/null || echo "")
ifeq ($(PYTHON),)
$(error Python not found. Install Python 3 (e.g. on Ubuntu: sudo apt update && sudo apt install -y python3))
endif

# Detect environment and write frontend/.env
detect-env:
	@echo "Running IP detection script..."
	@$(PYTHON) ./scripts/detect_env.py

# Bring up the application (build then up)
up: detect-env
	@echo "Running docker compose (via scripts/compose.py)"
	@$(PYTHON) ./scripts/compose.py build || exit 1
	@$(PYTHON) ./scripts/compose.py up -d || exit 1

down:
	@$(PYTHON) ./scripts/compose.py down || exit 1

build:
	@$(PYTHON) ./scripts/compose.py build || exit 1

logs:
	@$(PYTHON) ./scripts/compose.py logs -f || exit 1