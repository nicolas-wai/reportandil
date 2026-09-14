DB_URL := postgres://admin:NZN@localhost:5432/reportandil?sslmode=disable
GOPATH := $(shell go env GOPATH)
REPO_SQLC := github.com/sqlc-dev/sqlc/cmd/sqlc@latest
VERSION_SQLC := 1.31.1

.PHONY: generate docker-up docker-down migrate apply test

# Genera el SQL con sqlc
generate:
#Instala sqlc de ser necesario
	@if ( ! command -v sqlc ); \
		then echo "sqlc no esta instalado, instalando..." && \
		go install $(REPO_SQLC) && \
		echo "sqlc instalado correctamente"; \
	fi;
	@export PATH=$$PATH:$(GOPATH)/bin;
	@sqlc generate

# Elimina contenedores y volumenes
docker-down:
	@docker compose down -v

# Levanta el contenedor con la base usando el dockercompose
docker-up:
	@docker compose up -d

# Crea la migracion
migrate:
	@test -n "$(name)" || name="migration_$(shell date +%Y%m%d%H%M%S)"
	@if ! command -v atlas; \
		then echo "atlas no esta instalado, instalando..." && \
		curl -sSf https://atlasgo.sh | sh && \
		echo "atlas instalado correctamente"; \
	fi;
	atlas migrate diff "$(name)" --dir "file://db/migrations" --to \
	"file://db/schema/schema.sql" --dev-url "docker://postgres/15/dev?search_path=public"

# Aplica la migracion
apply:
	@atlas migrate apply --dir "file://db/migrations" --url "$(DB_URL)"

# Corre los tests
test: generate docker-down docker-up migrate apply

	@printf "\n\n -  Preparación terminada. Corriendo tests...\n\n"
	@go test -v ./...
	@printf "\n\n -  Tests finalizados. Limpiando...\n\n"
	@$(MAKE) docker-down