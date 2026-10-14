# 1. Obtener todos los reportes
GET http://localhost:8080/reportes
HTTP 200
[Asserts]
jsonpath "$.length()" == 3
jsonpath "$[0].name" == "Laptop"

# 2. Obtener el reporte con id 2
GET http://localhost:8080/reportes/2
HTTP 200
[Asserts]
jsonpath "$.name" == "Smartphone"

# 3. Eliminar el reporte con id 2
DELETE http://localhost:8080/reportes/2
HTTP 204

# 4. Crear un nuevo reporte
POST http://localhost:8080/reportes
Content-Type: application/json
{
"name": "GPS Watch",
"price": 199.05
}
HTTP 201
[Asserts]
jsonpath "$.id" isInteger
jsonpath "$.name" == "GPS Watch"
