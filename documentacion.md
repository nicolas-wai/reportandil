Todavia no sabemos:

- Las queries deberian ser genericas y filtrarse en la capa de logica o hacer diferentes queries en la capa de datos para las diferentes opciones
  Por ejemplo, el listReportes, deberia devolver todo o hacer diferentes queries segun quien vea la lista (Usuario/administrador)

- Estado no me dejo atlas que sea un dominio para limitar las opciones, ver como solucionar eso

Se prende el contenedor con
docker compose up -d
Y se abre la bas con
docker exec -it postgres-db-reportandil psql -U admin -d reportandil
Dentro de la base: con \dt se pueden ver todas las tablas. con \d <tabla> se pueden ver las columnas y constraints

Para poder usar sqlc, ademas de descargarlo
go install github.com/sqlc-dev/sqlc/cmd/sqlc@latest
se necesita que este en el PATH
export PATH=$PATH:$(go env GOPATH)/bin

Para usar atlas hay que descargarlo
curl -sSf https://atlasgo.sh | sh
