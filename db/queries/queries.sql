-- name: CreateReporte :one
INSERT INTO reporte (titulo, descripcion, imagen, usuario_id, categoria_id, direccion_id)
VALUES ($1, $2, $3, $4, $5, $6)
RETURNING id;

-- name: GetReporte :one
SELECT *
FROM reporte
WHERE id = $1;

-- name: ListReportes :many
SELECT *
FROM reporte
ORDER BY id;

-- name: UpdateEstadoReporte :exec
UPDATE reporte
SET estado = $2, updated_at = NOW()
WHERE id = $1;

-- name: DeleteReporte :exec
DELETE FROM reporte
WHERE id = $1;

-- name: CreateUsuario :one
INSERT INTO usuario (nombre)
VALUES ($1)
RETURNING id;

-- name: CreateCategoria :one
INSERT INTO categoria (nombre)
VALUES ($1)
RETURNING id;

-- name: CreateDireccion :one
INSERT INTO direccion(latitud, longitud, direccion_relativa)
VALUES ($1, $2, $3)
RETURNING id;