# reportandil

Applicacion web en Go para registrar y gestionar reportes de problemas urbanos.

Stack: Go (`net/http`), PostgreSQL 15 en Docker, [sqlc](https://sqlc.dev) para generar el código de acceso a datos, [Atlas](https://atlasgo.io) para las migraciones y [templ](https://templ.guide/). En la construcción de la capa de presentación se utiliza el framework [pico.css](https://picocss.com/) para dar estilos.

Mas detalles de diseño y trabajo pendiente en [`documentacion.md`](documentacion.md).

---

## Requisitos
- [Go](https://go.dev/dl/) (la versión indicada en `go.mod`)
- [Docker](https://docs.docker.com/get-docker/) con Docker Compose
- [sqlc](https://docs.sqlc.dev/en/latest/overview/install.html)
- [Atlas](https://atlasgo.io/getting-started)
- make
- [templ](https://templ.guide/)

---

## Instrucciones para Ejecutar

Clonar o descargar este repositorio y abrir la terminal en la carpeta del proyecto.

Ejecutar:

```bash
make migrate # (opcional - En caso de modificar el esquema de BD)
make run-app
```

Para borrar manualmente el contenedor y su volumen:
```bash
make docker-down
```

Si no existe el archivo `.env`, el Makefile lo crea automáticamente a partir de `.env.example`.

`inicializar-db` (proceso interno en `run`) es necesario porque todavía no se implemenó la lógica para crear usuarios ni categorías, y un reporte necesita ambos (ver [`documentacion.md`](documentacion.md)).


---

## Endpoints

URL base: `http://localhost:8080`

- GET / : sirve la pagina principal con el listado de reportes y el formulario de creación.
- GET /reportes/{id_reporte} : vista en detalle de un reporte específico.
- POST /reportes : procesamiento del formulario para crear un nuevo reporte.
