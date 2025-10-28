.PHONY: up down detect-env

# Set working directory to the Makefile's location
MAKEFILE_DIR := $(dir $(abspath $(lastword $(MAKEFILE_LIST))))

# Detect environment and set appropriate IP
detect-env:
	@cd "$(MAKEFILE_DIR)" && powershell -Command "\
	Write-Host '=== Detecting Environment ==='; \
	$$ip = if ($$(try { \
		Invoke-RestMethod -Uri 'http://169.254.169.254/latest/meta-data/public-ipv4' -TimeoutSec 1 -ErrorAction Stop; \
		$$true \
	} catch { $$false })) { \
		Write-Host 'Detected EC2 environment'; \
		$$(Invoke-RestMethod -Uri 'http://169.254.169.254/latest/meta-data/public-ipv4') \
	} else { \
		Write-Host 'Detected local environment'; \
		'localhost' \
	}; \
	Write-Host ('Using IP: ' + $$ip); \
	Set-Content -Path './frontend/.env' -Value ('VITE_API_URL=http://' + $$ip + ':5000') -Force; \
	Write-Host ('Frontend URL: http://' + $$ip + ':5173'); \
	Write-Host ('Backend URL: http://' + $$ip + ':5000'); \
	Write-Host '=== Environment Setup Complete ==='"

# Bring up containers
up: detect-env
	@cd "$(MAKEFILE_DIR)" && docker compose up --build -d

# Bring down containers
down:
	@cd "$(MAKEFILE_DIR)" && docker compose down
