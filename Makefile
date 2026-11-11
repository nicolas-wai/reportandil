-include .env
export POSTGRES_DB POSTGRES_USER POSTGRES_PASSWORD POSTGRES_PORT DB_URL

.PHONY: all generate build run docker-up docker-down db-wait open-db inicializar-db migrate apply test


SHELL := /bin/bash
.ONESHELL:

all: test

.env:
	@echo ".env no existe, usando example"
	@cp .env.example .env

# Genera el SQL con sqlc y los templ.go
generate: .env
	@sqlc generate
	@templ generate

# Compila el codigo, generando sqlc y templ
build: generate
	@go build -o app .

# Ejecuta la app
run:
	@trap 'echo -e "\n Cierre detectado. Limpiando..."; $(MAKE) docker-down' EXIT
	$(MAKE) docker-down
	$(MAKE) build
	$(MAKE) apply
	$(MAKE) inicializar-db
	./app

# Levanta el contenedor con la base usando el dockercompose
docker-up: .env
	@docker compose up -d

# Elimina contenedores y volumenes
docker-down: .env
	@docker compose down -v


db-wait: docker-up
	@echo "Esperando que postgres este listo para aceptar conexiones..."
	@until docker compose exec -T database pg_isready -U $${POSTGRES_USER}; do \
		sleep 1; \
	done
	@sleep 2;
	@echo "Base de datos lista"


# Abre la terminal de postres, para testear o ver que hay
open-db:
	@docker compose exec database psql -U $${POSTGRES_USER} -d $${POSTGRES_DB}

# Crea datos iniciales para poder probar
inicializar-db:
	@docker compose exec -T database psql -U "$${POSTGRES_USER}" -d "$${POSTGRES_DB}" -c "INSERT INTO usuario (nombre) VALUES ('Usuario Test'); INSERT INTO categoria (nombre) VALUES ('Pozo'), ('Luminaria'), ('Basura'), ('Seguridad');"
	@echo "Usuario y categorias de prueba insertados con éxito."

# Crea la migracion
MIGRATION_NAME ?= $(if $(name),$(name),migration_$(shell date +%Y%m%d%H%M%S))
migrate:
	@echo "Creando migracion con Atlas: $(MIGRATION_NAME)..."
	@atlas migrate diff "$(MIGRATION_NAME)" \
		--dir "file://db/migrations" \
		--to "file://db/schema/schema.sql" \
		--dev-url "docker://postgres/15/dev?search_path=public"


# Aplica la migracion
apply: db-wait
	@atlas migrate apply --dir "file://db/migrations" --url "$(DB_URL)"


# Corre los tests
test: generate
# El trap hace que, aunque falle un test, migracion o docker-up, se cierre el contenedor igual
	@trap 'echo -e "\nTests finalizados. Limpiando..."; $(MAKE) docker-down' EXIT
	$(MAKE) docker-down
	$(MAKE) migrate
	$(MAKE) apply
	echo -e "\nPreparación terminada. Corriendo tests..."
	go test -v ./...