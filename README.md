# reportandil

---

## Instrucciones para Ejecutar

Clonar o descargar este repositorio.\
Abrir la terminal en la carpeta del proyecto.\
Ejecutar:

```bash
go run .
```

Abrir el navegador y acceder a:
http://localhost:8080

Make:

```bash
make generate
make docker
make migrate
make apply
docker exec -it postgres-db-reportandil psql -U admin -d reportandil
```
