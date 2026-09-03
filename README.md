# reportandil

## Instrucciones para Ejecutar

Clonar o descargar este repositorio.\
Abrir la terminal en la carpeta del proyecto.\
Ejecutar:

```bash
go run .
```

Abrir el navegador y acceder a:
http://localhost:8080

---

## Instrucciones para Inicializar la base
Instalar el driver de Postgres:
```bash
go get github.com/jackc/pgx/v5/stdlib
```

Iniciar el contenedor:

```bash
docker run --name test-postgres -e POSTGRES_PASSWORD=<PASS> -p 5432:5432 -d docker.io/postgres
```

Entrar a la base:

```bash
docker exec -it test-postgres psql -h localhost -U postgres
```

Crear la base de datos:

```bash
CREATE DATABASE test;
CREATE USER <youruser> WITH PASSWORD '<yourpassword>';
GRANT ALL PRIVILEGES ON DATABASE test TO <youruser>;
```

Entrar a la base y dar privilegios al usuario creado:

```bash
test
GRANT ALL ON SCHEMA public TO <youruser>
```

Asegurarse que la cadena connStr o dns en main.go tengan las mismas credenciales que las creadas

Entrar a la base:

```bash
docker exec -it test-postgres psql -h localhost -U <youruser> -d test
```
---
### SQL Directo
Utiliza los directorios ./models y ./repository\
Para utilizar los metodos se debe crear una instancia de UserRepository con conexion a la base
```go
    userRepo := repository.NewUserRepository(db)
```

### Query Mappers (sqlc)
Utiliza los directorios ./db y el archivo sqlc.yaml\
En el directorio ./db/queries se encuntran las consultas\
En el directorio ./db/schema la creacion de las tablas\
Requiere instalacion:
```bash
go install github.com/sqlc-dev/sqlc/cmd/sqlc@latest
```
Al ejecutar se crearan archivos en ./db/sqlc:
```bash
sqlc generate
```
Para utilizar los metodos se requiere una instancia de Queries con conexion a la base y un context. Los metodos reciben como primer parametro el context
```go
queries := sqlc.New(db)
	ctx := context.Background()
	user, err := queries.GetUser(ctx, 1)
```

### ORM (gorm)
Utiliza los directorios ./modelsGORM y ./crudGORM
Requiere instalacion
```bash
go get gorm.io/gorm
go get gorm.io/driver/postgres
```
Para usar los metodos se llaman a los que estan en el package crudgorm, pasandole como primer parametro a las funciones la base de datos