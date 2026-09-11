DB_URL := postgres://admin:NZN@localhost:5432/reportandil?sslmode=disable

.PHONY: generate docker migrations apply test

# Genera el SQL con sqlc
generate:
	@sqlc generate
# Levanta el contenedor con la base usando el dockercompose
docker:
	@docker compose up -d
# Crea la migracion
migrate:
	@test -n "$(name)" || (echo "Uso: make migrate name=nombre" && exit 1)
	atlas migrate diff "$(name)" --dir "file://db/migrations" --to \
	"file://db/schema/schema.sql" --dev-url "docker://postgres/15/dev?search_path=public"
# Aplica la migracion
apply:
	@atlas migrate apply --dir "file://db/migrations" --url "$(DB_URL)"
# Corre los tests
