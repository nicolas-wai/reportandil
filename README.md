# reportandil

Aplicación web en Go para registrar y gestionar reportes de problemas urbanos.

Stack: Go (`net/http`), PostgreSQL 15 en Docker, [sqlc](https://sqlc.dev) para generar el código de acceso a datos, [Atlas](https://atlasgo.io) para las migraciones y [templ](https://templ.guide/) para renderizar las vistas en el servidor. Para los estilos se utiliza [pico.css](https://picocss.com/).

Más detalles de diseño y trabajo pendiente en [`documentacion.md`](documentacion.md).

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
make run-app
```

Luego abrir `http://localhost:8080`.

Para borrar manualmente el contenedor y su volumen:
```bash
make docker-down
```

`inicializar-db` (proceso interno en `run-app`) es necesario porque todavía no se implementó la lógica para crear usuarios ni categorías, y un reporte necesita ambos (ver [`documentacion.md`](documentacion.md)).


## Endpoints

URL base: `http://localhost:8080`

- GET / : sirve la página principal con el listado de reportes y el formulario de creación.
- GET /reportes/{id_reporte} : vista en detalle de un reporte específico.
- POST /reportes : procesamiento del formulario para crear un nuevo reporte.
