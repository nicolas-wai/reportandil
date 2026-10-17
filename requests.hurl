#Primera aproximación. CHEQUEAR y personalizar los Status Codes a cada caso

# 1. CAMINO FELIZ: creación ----------------------------------------

# Crear reporte A (usuario 0). El estado no se envía: debe quedar "en_revision"
POST {{host}}/reportes
Content-Type: application/json
{
  "titulo": "Reporte A",
  "descripcion": "Descripcion del reporte A",
  "imagen": "https://example.com/a.png",
  "usuario_id": 0,
  "categoria_id": 1
}
HTTP 201
[Captures]
id_a: jsonpath "$.id"
titulo_a: jsonpath "$.titulo"
[Asserts]
jsonpath "$.id" isInteger
jsonpath "$.estado" == "en_revision"
jsonpath "$.descripcion" == "Descripcion del reporte A"
jsonpath "$.imagen" == "https://example.com/a.png"
jsonpath "$.usuario_id" == 0
jsonpath "$.categoria_id" == 1


# Crear reporte B (usuario 1)
POST {{host}}/reportes
Content-Type: application/json
{
  "titulo": "Reporte B",
  "descripcion": "Descripcion del reporte B",
  "imagen": "https://example.com/b.png",
  "usuario_id": 1,
  "categoria_id": 1
}
HTTP 201
[Captures]
id_b: jsonpath "$.id"
[Asserts]
jsonpath "$.id" != {{id_a}}
jsonpath "$.estado" == "en_revision"
jsonpath "$.usuario_id" == 1


# 2. CAMINO FELIZ: lectura  --------------------------------------------
# Obtener A por id
GET {{host}}/reportes/{{id_a}}
HTTP 200
[Asserts]
jsonpath "$.id" == {{id_a}}
jsonpath "$.titulo" == "{{titulo_a}}"
jsonpath "$.descripcion" == "Descripcion del reporte A"
jsonpath "$.imagen" == "https://example.com/a.png"
jsonpath "$.estado" == "en_revision"
jsonpath "$.usuario_id" == 0
jsonpath "$.categoria_id" == 1


# Listar: A y B aparecen exactamente una vez, ambos en revisión
GET {{host}}/reportes
HTTP 200
[Asserts]
jsonpath "$" isCollection
jsonpath "$[?(@.id=={{id_a}})]" count == 1
jsonpath "$[?(@.id=={{id_b}})]" count == 1
jsonpath "$[?(@.id=={{id_a}})].estado" nth 0 == "en_revision"
jsonpath "$[?(@.id=={{id_b}})].estado" nth 0 == "en_revision"


# 3. CAMINO FELIZ: actualización de estado  ------------------------

# A -> aceptado
PUT {{host}}/reportes/{{id_a}}
Content-Type: application/json
{
  "estado": "aceptado"
}
HTTP 200


# Verificar el cambio en A: solo cambió el estado
GET {{host}}/reportes/{{id_a}}
HTTP 200
[Asserts]
jsonpath "$.estado" == "aceptado"
jsonpath "$.titulo" == "{{titulo_a}}"
jsonpath "$.descripcion" == "Descripcion del reporte A"
jsonpath "$.imagen" == "https://example.com/a.png"
jsonpath "$.usuario_id" == 0
jsonpath "$.categoria_id" == 1


# B no se vio afectado por la modificación de A
GET {{host}}/reportes/{{id_b}}
HTTP 200
[Asserts]
jsonpath "$.estado" == "en_revision"


# El estado es el ÚNICO campo modificable: mandar otros campos no los cambia.
# A -> rechazado, intentando cambiar también titulo, descripcion, etc.
PUT {{host}}/reportes/{{id_a}}
Content-Type: application/json
{
  "titulo": "TITULO HACKEADO",
  "descripcion": "DESCRIPCION HACKEADA",
  "imagen": "https://example.com/hack.png",
  "estado": "rechazado",
  "usuario_id": 1,
  "categoria_id": 99
}
HTTP 200


GET {{host}}/reportes/{{id_a}}
HTTP 200
[Asserts]
jsonpath "$.estado" == "rechazado"
jsonpath "$.titulo" == "{{titulo_a}}"
jsonpath "$.descripcion" == "Descripcion del reporte A"
jsonpath "$.imagen" == "https://example.com/a.png"
jsonpath "$.usuario_id" == 0
jsonpath "$.categoria_id" == 1


# El listado refleja los estados actuales de A y B
GET {{host}}/reportes
HTTP 200
[Asserts]
jsonpath "$[?(@.id=={{id_a}})]" count == 1
jsonpath "$[?(@.id=={{id_a}})].estado" nth 0 == "rechazado"
jsonpath "$[?(@.id=={{id_b}})].estado" nth 0 == "en_revision"


# 4. NUEVA INSERCIÓN EN EL MEDIO: nada de lo anterior debe romperse -----------

POST {{host}}/reportes
Content-Type: application/json
{
  "titulo": "Reporte C {{newUuid}}",
  "descripcion": "Descripcion del reporte C",
  "imagen": "https://example.com/c.png",
  "usuario_id": 1,
  "categoria_id": 1
}
HTTP 201
[Captures]
id_c: jsonpath "$.id"
[Asserts]
jsonpath "$.id" != {{id_a}}
jsonpath "$.id" != {{id_b}}
jsonpath "$.estado" == "en_revision"


# A y B conservan su estado tras la nueva inserción; C aparece una sola vez
GET {{host}}/reportes
HTTP 200
[Asserts]
jsonpath "$[?(@.id=={{id_a}})].estado" nth 0 == "rechazado"
jsonpath "$[?(@.id=={{id_b}})].estado" nth 0 == "en_revision"
jsonpath "$[?(@.id=={{id_c}})]" count == 1
jsonpath "$[?(@.id=={{id_c}})].estado" nth 0 == "en_revision"


# B -> aceptado (modificación después de una inserción)
PUT {{host}}/reportes/{{id_b}}
Content-Type: application/json
{
  "estado": "aceptado"
}
HTTP 200


# A y C no cambian al modificar B
GET {{host}}/reportes/{{id_a}}
HTTP 200
[Asserts]
jsonpath "$.estado" == "rechazado"


GET {{host}}/reportes/{{id_c}}
HTTP 200
[Asserts]
jsonpath "$.estado" == "en_revision"


GET {{host}}/reportes/{{id_b}}
HTTP 200
[Asserts]
jsonpath "$.estado" == "aceptado"


# 5. FALLOS: creación (POST) ----------------------------------

# Sin titulo
POST {{host}}/reportes
Content-Type: application/json
{
  "descripcion": "sin titulo",
  "imagen": "https://example.com/x.png",
  "usuario_id": 0,
  "categoria_id": 1
}
HTTP 400


# usuario_id inexistente
POST {{host}}/reportes
Content-Type: application/json
{
  "titulo": "titulo-invalido-no-debe-persistir",
  "descripcion": "usuario inexistente",
  "imagen": "https://example.com/x.png",
  "usuario_id": 99999,
  "categoria_id": 1
}
HTTP 400


# categoria_id inexistente
POST {{host}}/reportes
Content-Type: application/json
{
  "titulo": "titulo-invalido-no-debe-persistir",
  "descripcion": "categoria inexistente",
  "imagen": "https://example.com/x.png",
  "usuario_id": 0,
  "categoria_id": 99999
}
HTTP 400


# Tipo de dato incorrecto (usuario_id como string)
POST {{host}}/reportes
Content-Type: application/json
{
  "titulo": "titulo-invalido-no-debe-persistir",
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


# Ninguno de los POST inválidos dejó datos persistidos
GET {{host}}/reportes
HTTP 200
[Asserts]
jsonpath "$[?(@.titulo=='titulo-invalido-no-debe-persistir')]" count == 0


# 6. FALLOS: lectura (GET)  -------------------------------------------------

# Id inexistente
GET {{host}}/reportes/999999999
HTTP 404


# Id con formato inválido
GET {{host}}/reportes/abc
HTTP 400


# 7. FALLOS: actualización (PUT)    -----------------

# Estado inválido
PUT {{host}}/reportes/{{id_b}}
Content-Type: application/json
{
  "estado": "cualquier_cosa"
}
HTTP 400


# Estado vacío
PUT {{host}}/reportes/{{id_b}}
Content-Type: application/json
{
  "estado": ""
}
HTTP 400


# Body sin estado
PUT {{host}}/reportes/{{id_b}}
Content-Type: application/json
{}
HTTP 400


# JSON malformado
PUT {{host}}/reportes/{{id_b}}
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


# Id con formato inválido
PUT {{host}}/reportes/abc
Content-Type: application/json
{
  "estado": "aceptado"
}
HTTP 400


# Los PUT inválidos no modificaron B (sigue en "aceptado")
GET {{host}}/reportes/{{id_b}}
HTTP 200
[Asserts]
jsonpath "$.estado" == "aceptado"


# 8. FALLOS: borrado (DELETE) con id inexistente / inválido -----------------

DELETE {{host}}/reportes/999999999
HTTP 404


DELETE {{host}}/reportes/abc
HTTP 400


# 9. CAMINO FELIZ: borrado y consistencia posterior ----------------------------------

# Borrar A
DELETE {{host}}/reportes/{{id_a}}
HTTP 204


# A ya no existe por id
GET {{host}}/reportes/{{id_a}}
HTTP 404


# A ya no está en el listado; B y C siguen intactos
GET {{host}}/reportes
HTTP 200
[Asserts]
jsonpath "$[?(@.id=={{id_a}})]" count == 0
jsonpath "$[?(@.id=={{id_b}})]" count == 1
jsonpath "$[?(@.id=={{id_c}})]" count == 1
jsonpath "$[?(@.id=={{id_b}})].estado" nth 0 == "aceptado"
jsonpath "$[?(@.id=={{id_c}})].estado" nth 0 == "en_revision"


# Operar sobre un reporte borrado falla
PUT {{host}}/reportes/{{id_a}}
Content-Type: application/json
{
  "estado": "aceptado"
}
HTTP 404


# Borrar dos veces el mismo reporte: la segunda da 404
DELETE {{host}}/reportes/{{id_a}}
HTTP 404


# B y C siguen accesibles y con su estado después del borrado
GET {{host}}/reportes/{{id_b}}
HTTP 200
[Asserts]
jsonpath "$.estado" == "aceptado"
jsonpath "$.titulo" startsWith "Reporte B"


GET {{host}}/reportes/{{id_c}}
HTTP 200
[Asserts]
jsonpath "$.estado" == "en_revision"
jsonpath "$.titulo" startsWith "Reporte C"


# 10. LIMPIEZA: borrar lo creado por esta corrida   ----------------------------------

DELETE {{host}}/reportes/{{id_b}}
HTTP 204


DELETE {{host}}/reportes/{{id_c}}
HTTP 204


GET {{host}}/reportes
HTTP 200
[Asserts]
jsonpath "$[?(@.id=={{id_a}})]" count == 0
jsonpath "$[?(@.id=={{id_b}})]" count == 0
jsonpath "$[?(@.id=={{id_c}})]" count == 0

