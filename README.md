# ReporTandil
ReporTandil es un servicio web donde los vecinos de la ciudad pueden publicar y dar seguimiento situaciones de situaciones de la ciudad. Sirve como plataforma de iniciativa para mejorar entre todos el lugar donde vivimos.


## Funcionalidad (Extendida en [Documentación](./documentacion.md#funcionalidad)):
- Log-in con cuenta de usuario o administrador. (Planeado para próximas entregas)
- Como Usuario:
  - Publicar y leer "reportes"
- Como administrador:
  - Aprobar/Rechazar reportes
  - Seguimiento de los reportes en curso

## Requisitos

- Go
- Docker + Docker Compose
- make

`sqlc` y `atlas` **no** hace falta instalarlos a mano, el Makefile instala sqlc con `go install` y lo agrega al PATH, e instala atlas con `curl -sSf https://atlasgo.sh`.

## Instrucciones para correr tests
```bash
make test
```

### Tareas *Make* definidas:

```bash
make generate
make docker-down
make docker-up
make migrate
make apply
make test
```
