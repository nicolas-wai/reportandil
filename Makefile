-include .env
export POSTGRES_DB POSTGRES_USER POSTGRES_PASSWORD POSTGRES_PORT DB_URL

.PHONY: all generate build run docker-up docker-down db-wait open-db inicializar-db migrate apply test env-init

SHELL := /bin/bash
.ONESHELL:

SHELL := /bin/bash
.ONESHELL:

all: test

env-init:
	@if [ ! -f .env ]; then
		echo ".env no existe, usando example"
		cp .env.example .env
	fi

# Genera el SQL con sqlc
generate: env-init
	@sqlc generate
	@templ generate

# Compila el codigo, y el generado por sqlc
build: generate
	@go build -o app .

run: docker-down
	@trap 'echo -e "\n Cierre detectado. Limpiando..."; $(MAKE) docker-down' EXIT
	$(MAKE) generate
	$(MAKE) apply
	$(MAKE) inicializar-db
	go run .


# Elimina contenedores y volumenes
docker-down: env-init
	@docker compose down -v


# Levanta el contenedor con la base usando el dockercompose
docker-up: env-init
	@docker compose up -d


db-wait: env-init
	@echo "Esperando que postgres este listo para aceptar conexiones..."
	@until docker compose exec -T database pg_isready -U $${POSTGRES_USER:-postgres}; do \
		sleep 1; \
	done
	@sleep 2;
	@echo "Base de datos lista"


# Comandos para testear la base, ver que hay dentro e inicializar usuarios y categoria para ser referenciados
open-db:
	@docker compose exec database psql -U $${POSTGRES_USER:-postgres} -d $${POSTGRES_DB}


inicializar-db:
	@docker compose exec -T database psql -U "$${POSTGRES_USER:-postgres}" -d "$${POSTGRES_DB}" -c "INSERT INTO usuario (nombre) VALUES ('Usuario Test'); INSERT INTO categoria (nombre) VALUES ('Pozo');"
	@echo "Usuario de prueba insertado con éxito."


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
	@trap 'echo -e "\nTests finalizados. Limpiando..."; $(MAKE) docker-down' EXIT
	$(MAKE) docker-down
	$(MAKE) docker-up
	$(MAKE) migrate
	$(MAKE) apply
	echo -e "\nPreparación terminada. Corriendo tests..."
	go test -v ./...