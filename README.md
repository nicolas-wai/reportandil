# reportandil

Applicacion web en Go para registrar y gestionar reportes de problemas urbanos.

Stack: Go (`net/http`), PostgreSQL 15 en Docker, [sqlc](https://sqlc.dev) para generar el código de acceso a datos, [Atlas](https://atlasgo.io) para las migraciones y [hurl](https://hurl.dev/) para testing de la API.

Mas detalles de diseño y trabajo pendiente en [`documentacion.md`](documentacion.md).

---

## Requisitos
- [Go](https://go.dev/dl/) (la versión indicada en `go.mod`)
- [Docker](https://docs.docker.com/get-docker/) con Docker Compose
- [sqlc](https://docs.sqlc.dev/en/latest/overview/install.html)
- [Atlas](https://atlasgo.io/getting-started)
- make
- [Hurl](https://hurl.dev) (solo para `make test-api`, ver más abajo)


---

## Instrucciones para Ejecutar

Clonar o descargar este repositorio y abrir la terminal en la carpeta del proyecto.
Ejecutar:

```bash
make apply
make inicializar-db
make run
```

Para detener, borrar el contenedor y su volumen:
```bash
make docker-down
```

Si no existe el archivo `.env`, el Makefile lo crea automáticamente a partir de `.env.example`.

`inicializar-db` es necesario porque todavía no hay endpoints para crear usuarios ni categorías, y un reporte necesita ambos (ver `documentacion.md`).

## Endpoints

Base URL: `http://localhost:8080`

| Método   | Ruta             | Descripción                         |
| -------- | ---------------- | ----------------------------------- |
| `POST`   | `/reportes`      | Crea un reporte                     |
| `GET`    | `/reportes`      | Lista todos los reportes            |
| `GET`    | `/reportes/{id}` | Obtiene un reporte                  |
| `PUT`    | `/reportes/{id}` | Actualiza el **estado** del reporte |
| `DELETE` | `/reportes/{id}` | Elimina un reporte                  |
