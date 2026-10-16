-include .env
export POSTGRES_DB POSTGRES_USER POSTGRES_PASSWORD POSTGRES_PORT DB_URL

.PHONY: all generate build run docker-up docker-down db-wait migrate apply test test-api

all: test

.env:
	@echo ".env no existe, usando example"
	@cp .env.example .env

# Genera el SQL con sqlc
generate: .env
	@sqlc generate

# Compila el codigo, y el generado por sqlc
build: generate
	@go build ./...

run: generate
	@go run .

# Elimina contenedores y volumenes
docker-down: .env
	@docker compose down -v

# Levanta el contenedor con la base usando el dockercompose
docker-up: .env
	@docker compose up -d

db-wait: .env
	@echo "Esperando que postgres este listo para aceptar conexiones..."
	@until docker compose exec -T database pg_isready -U $${POSTGRES_USER:-postgres}; do \
		sleep 1; \
	done
	@echo "Base de datos lista"

# Crea la migracion
MIGRATION_NAME ?= $(if $(name),$(name),migration_$(shell date +%Y%m%d%H%M%S))
migrate:
	@echo "Creando migracion con Atlas: $(MIGRATION_NAME)..."
	@atlas migrate diff "$(MIGRATION_NAME)" \
		--dir "file://db/migrations" \
		--to "file://db/schema/schema.sql" \
		--dev-url "docker://postgres/15/dev?search_path=public"

# Aplica la migracion
apply: docker-up db-wait
	@atlas migrate apply --dir "file://db/migrations" --url "$(DB_URL)"

# Corre los tests
test: build
# El trap hace que, aunque falle un test, migracion o docker-up, se cierre el contenedor igual
	@bash -c '\
		trap "printf \"\nTests finalizados. Limpiando...\n\"; $(MAKE) docker-down" EXIT; \
		$(MAKE) docker-down || exit 1; \
		$(MAKE) docker-up || exit 1; \
		$(MAKE) migrate || exit 1; \
		$(MAKE) apply || exit 1; \
		printf "\nPreparación terminada. Corriendo tests...\n"; \
		go test -v ./... \
	'

test-api: build
	@bash -c '\
		trap "printf \"\nFin de prueba de API. Limpiando...\n\"; $(MAKE) docker-down" EXIT; \
		$(MAKE) docker-down || exit 1; \
		$(MAKE) docker-up || exit 1; \
		$(MAKE) migrate || exit 1; \
		$(MAKE) apply || exit 1; \
		printf "\nPreparación terminada. Corriendo prueba de API...\n"; \
		hurl --test requests.hurl \
	'