## Funcionalidad
  
[...]
  
  
## Capa de Datos (persistencia)

### Modelo principal
Esquema principal de la base de datos:
<img width="1408" height="768" alt="entidadRelacionMain" src="https://github.com/user-attachments/assets/2101d2cc-2fae-4109-b32e-eede40373398" />
  
**Entidad REPORTE**  
El *estado* de un reporte se describe de la siguiente manera:  
<img width="60%" alt="estadosReporte" src="https://github.com/user-attachments/assets/6498af81-653c-4581-b57f-a6fb4ab7964e" />



## Todavia no sabemos:

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
