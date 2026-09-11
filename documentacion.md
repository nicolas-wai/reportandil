Todavia no sabemos:
- Las queries deberian ser genericas y filtrarse en la capa de logica o hacer diferentes queries en la capa de datos para las diferentes opciones
Por ejemplo, el listReportes, deberia devolver todo o hacer diferentes queries segun quien vea la lista (Usuario/administrador)

Se prende el contenedor con
docker compose up -d
Y se abre la bas con
docker exec -it postgres-db-reportandil psql -U admin -d reportandil