# ReporTandil
ReporTandil es un servicio web donde los vecinos de la ciudad pueden publicar y dar seguimiento a eventos desafortunados de su vida cotidiana. Sirve como plataforma de iniciativa para mejorar entre todos el lugar donde vivimos. Ayuda como puesta en común vecinal/municipal de diversos temas que conciernen a la calidad de vida de los ciudadanos.  
  
  
## Funcionalidad (Extendida en [Documentación](./documentacion.md#funcionalidad)):
- Log-in con cuenta de usuario o administrador. (Planeado para próximas entregas)
- Como Usuario:
  - Publicar y leer "reportes"
- Como administrador:
  - Aprobar/Rechazar reportes
  - Seguimiento de los reportes en curso
  
  
## Instrucciones para Ejecutar

1. Clonar o descargar este repositorio.
2. Abrir la terminal en la carpeta del proyecto.
3. Ejecutar:

```bash
go run .
```

4. Abrir el navegador y acceder a:\
    http://localhost:8080

### Make:

```bash
make generate
make docker
make migrate
make apply
docker exec -it postgres-db-reportandil psql -U admin -d reportandil
```
