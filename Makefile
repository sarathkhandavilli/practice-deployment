.PHONY: up down build logs detect-env

# Use the Python wrapper to run compose commands cross-platform
PYTHON := python

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