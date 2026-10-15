include .env
export
GOPATH := $(shell go env GOPATH)
REPO_SQLC := github.com/sqlc-dev/sqlc/cmd/sqlc@v$(SQLC_VERSION)
VERSION_SQLC := 1.31.1

.PHONY: all generate build docker-up docker-down migrate apply test

all: test

.env:
	@echo ".env no existe, usando example"
	@cp .env.example .env

sqlc-install:
	@if ! command -v sqlc ; then \
		echo "sqlc no esta instalado, instalando..." && \
		go install $(REPO_SQLC) && echo "sqlc instalado correctamente"; \
	fi

atlas-install:
	@if ! command -v atlas; then \
		echo "atlas no esta instalado, instalando..." && \
		curl -sSf https://atlasgo.sh | sh && echo "atlas instalado correctamente"; \
	fi

hurl-install:
	@command -v hurl || { \
	echo "hurl no esta instalado. Usar https://hurl.dev/docs/installation.html"; exit 1; }


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

# Crea la migracion
# El usuario le puede dar un nombre o se le dara un nombre en base a la fecha y hora actual
MIGRATION_NAME ?= $(if $(name),$(name),migration_$(shell date +%Y%m%d%H%M%S))
migrate:
	atlas migrate diff "$(MIGRATION_NAME)" --dir "file://db/migrations" --to \
	"file://db/schema/schema.sql" --dev-url "docker://postgres/15/dev?search_path=public"

# Aplica la migracion
apply:
	@atlas migrate apply --dir "file://db/migrations" --url "$(DB_URL)"

# Corre los tests
test: build docker-down
# El trap hace que, aunque falle un test, migracion o docker-up, se cierre el contenedor igual
	@bash -c '\
		trap "printf \"\n\n -  Tests finalizados. Limpiando...\n\n\"; $(MAKE) docker-down; rm -r db/sqlc" EXIT; \
		$(MAKE) docker-up || exit 1; \
		$(MAKE) migrate || exit 1; \
		$(MAKE) apply || exit 1; \
		printf "\n\n -  Preparación terminada. Corriendo tests...\n\n"; \
		go test -v ./... \
	'

test-api: build docker-down
# El trap hace que, aunque falle un test, migracion o docker-up, se cierre el contenedor igual
	@bash -c '\
		trap "printf \"\n\n -  Fin de prueba de API. Limpiando...\n\n\"; $(MAKE) docker-down" EXIT; \
		$(MAKE) docker-up || exit 1; \
		$(MAKE) migrate || exit 1; \
		$(MAKE) apply || exit 1; \
		printf "\n\n -  Preparación terminada. Corriendo prueba de API...\n\n"; \
		hurl --test requests.hurl \
	'