#Primera aproximación. CHEQUEAR y personalizar los Status Codes a cada caso

# 0. LISTAR (Con base vacia)
GET {{host}}/reportes
HTTP 200
[Asserts]
jsonpath "$" count == 0

# 1. CREAR

# Crear reporte A (Con varios campos)
POST {{host}}/reportes
Content-Type: application/json
{
  "titulo": "Reporte A",
  "descripcion": "Descripcion del reporte A",
  "imagen": "https://example.com/a.png",
  "usuario_id": 1,
  "categoria_id": 1
}
HTTP 201
[Asserts]
jsonpath "$.id" == 1
jsonpath "$.titulo" == "Reporte A"
jsonpath "$.descripcion.String" == "Descripcion del reporte A"
jsonpath "$.estado" == "en_revision"
jsonpath "$.imagen.String" == "https://example.com/a.png"
jsonpath "$.usuario_id" == 1
jsonpath "$.categoria_id" == 1

# Crear reporte B (Solo obligatorios)
POST {{host}}/reportes
Content-Type: application/json
{
  "titulo": "Reporte B",
  "usuario_id": 1,
  "categoria_id": 1
}
HTTP 201
[Asserts]
jsonpath "$.id" isInteger
jsonpath "$.id" == 2
jsonpath "$.titulo" == "Reporte B"
jsonpath "$.estado" == "en_revision"
jsonpath "$.usuario_id" == 1
jsonpath "$.categoria_id" == 1

# 2. LEER

# Listar todos los reportes
GET {{host}}/reportes
HTTP 200
[Asserts]
jsonpath "$.length()" == 2
jsonpath "$[0].titulo" == "Reporte A"
jsonpath "$[1].titulo" == "Reporte B"

# Obtener B por id
GET {{host}}/reportes/2
HTTP 200
[Asserts]
status == 200
header "content-type" == "application/json"
jsonpath "$.id" == 2
jsonpath "$.titulo" == "Reporte B"
jsonpath "$.estado" == "en_revision"
jsonpath "$.usuario_id" == 1
jsonpath "$.categoria_id" == 1

# 3. ACTUALIZAR

# A -> aceptado
PUT {{host}}/reportes/1
Content-Type: application/json
{
  "estado": "aceptado"
}
HTTP 204

# Verificar el cambio en A: solo cambió el estado
GET {{host}}/reportes/1
HTTP 200
[Asserts]
jsonpath "$.estado" == "aceptado"
jsonpath "$.titulo" == "Reporte A"
jsonpath "$.descripcion.String" == "Descripcion del reporte A"
jsonpath "$.imagen.String" == "https://example.com/a.png"
jsonpath "$.usuario_id" == 1
jsonpath "$.categoria_id" == 1


# B no se vio afectado por la modificación de A
GET {{host}}/reportes/2
HTTP 200
[Asserts]
jsonpath "$.estado" == "en_revision"


# 4. NUEVA INSERCIÓN EN EL MEDIO

POST {{host}}/reportes
Content-Type: application/json
{
  "titulo": "Reporte C",
  "descripcion": "Descripcion del reporte C",
  "imagen": "https://example.com/c.png",
  "usuario_id": 1,
  "categoria_id": 1
}
HTTP 201
[Asserts]
jsonpath "$.id" == 3
jsonpath "$.estado" == "en_revision"


# A y B conservan su estado tras la nueva inserción
GET {{host}}/reportes
HTTP 200
[Asserts]
jsonpath "$[0].estado" == "aceptado"
jsonpath "$[1].estado" == "en_revision"
jsonpath "$[2].estado" == "en_revision"

# Listar todos los reportes
GET {{host}}/reportes
HTTP 200
[Asserts]
jsonpath "$.length()" == 3


# 5. FALLO: CREAR

# Sin titulo
POST {{host}}/reportes
Content-Type: application/json
{
  "descripcion": "sin titulo",
  "imagen": "https://example.com/x.png",
  "usuario_id": 1,
  "categoria_id": 1
}
HTTP 422

# Titulo blanco
POST http://localhost:8080/reportes
Content-Type: application/json
{
  "titulo": "   ",
  "usuario_id": 1,
  "categoria_id": 1
}
HTTP 422

# usuario_id inexistente
POST {{host}}/reportes
Content-Type: application/json
{
  "titulo": "Usuario inexistente",
  "descripcion": "usuario inexistente",
  "imagen": "https://example.com/x.png",
  "usuario_id": 99999,
  "categoria_id": 1
}
HTTP 500


# categoria_id inexistente
POST {{host}}/reportes
Content-Type: application/json
{
  "titulo": "Categoria inexistente",
  "descripcion": "categoria inexistente",
  "imagen": "https://example.com/x.png",
  "usuario_id": 1,
  "categoria_id": 99999
}
HTTP 500

# usuario_id menor que 1
POST {{host}}/reportes
Content-Type: application/json
{
  "titulo": "Reporte sin usuario",
  "usuario_id": 0,
  "categoria_id": 1
}
HTTP 422


# Tipo de dato incorrecto (usuario_id como string)
POST {{host}}/reportes
Content-Type: application/json
{
  "titulo": "TIpo incorrecto",
  "descripcion": "tipo incorrecto",
  "imagen": "https://example.com/x.png",
  "usuario_id": "cero",
  "categoria_id": 1
}
HTTP 400


# JSON malformado
POST {{host}}/reportes
Content-Type: application/json
`{ "titulo": "roto", `
HTTP 400


# Body vacío
POST {{host}}/reportes
Content-Type: application/json
HTTP 400

# Listar todos los reportes (Siguen siendo 3, ningun POST creó nada)
GET {{host}}/reportes
HTTP 200
[Asserts]
jsonpath "$.length()" == 3


# 6. FALLO: LEER

# Id inexistente
GET {{host}}/reportes/999999999
HTTP 404

# Id con formato inválido
GET {{host}}/reportes/abc
HTTP 400


# 7. FALLO: ACTUALIZAR

# Estado inválido
PUT {{host}}/reportes/2
Content-Type: application/json
{
  "estado": "cualquier_cosa"
}
HTTP 400

# Estado vacío
PUT {{host}}/reportes/2
Content-Type: application/json
{
  "estado": ""
}
HTTP 400


# Body sin estado
PUT {{host}}/reportes/2
Content-Type: application/json
{}
HTTP 400


# JSON malformado
PUT {{host}}/reportes/2
Content-Type: application/json
`{ "estado": `
HTTP 400


# Id inexistente
PUT {{host}}/reportes/999999999
Content-Type: application/json
{
  "estado": "aceptado"
}
HTTP 404

# Los PUT inválidos no modificaron B
GET {{host}}/reportes/2
HTTP 200
[Asserts]
jsonpath "$.estado" == "en_revision"


# 8. FALLO: ELIMINAR

DELETE {{host}}/reportes/999999999
HTTP 404


DELETE {{host}}/reportes/abc
HTTP 400


# 9. ELIMINAR

# Borrar A
DELETE {{host}}/reportes/1
HTTP 204


# A ya no existe por id
GET {{host}}/reportes/1
HTTP 404


# A ya no está en el listado; B y C siguen intactos
# Listar todos los reportes
GET {{host}}/reportes
HTTP 200
[Asserts]
jsonpath "$.length()" == 2
jsonpath "$[0].titulo" == "Reporte B"
jsonpath "$[1].titulo" == "Reporte C"

# Volver a eliminar A
DELETE http://localhost:8080/reportes/1
HTTP 404


# Operar sobre un reporte borrado falla
PUT {{host}}/reportes/1
Content-Type: application/json
{
  "estado": "aceptado"
}
HTTP 404

# METODOS NO PERMITIDOS
POST http://localhost:8080/reportes/1
HTTP 405

PUT http://localhost:8080/reportes
HTTP 405

DELETE http://localhost:8080/reportes
HTTP 405

PATCH http://localhost:8080/reportes/2
HTTP 405

PATCH http://localhost:8080/reportes
HTTP 405
