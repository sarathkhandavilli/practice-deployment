.PHONY: up down build logs

# Basic Makefile: bring up/down the full application using Docker Compose

up:
	docker compose up --build -d

down:
	docker compose down

build:
	docker compose build

logs:
	docker compose logs -f