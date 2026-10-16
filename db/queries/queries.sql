-- name: CreateReporte :one
INSERT INTO reporte (titulo, descripcion, imagen, usuario_id, categoria_id)
VALUES ($1, $2, $3, $4, $5)
RETURNING id;

-- name: GetReporte :one
SELECT *
FROM reporte
WHERE id = $1;

-- name: ListReportes :many
SELECT *
FROM reporte
ORDER BY id;

-- name: UpdateEstadoReporte :one
UPDATE reporte
SET estado = $2, updated_at = NOW()
WHERE id = $1
RETURNING id, estado;

-- name: DeleteReporte :one
DELETE FROM reporte
WHERE id = $1
RETURNING id;

-- name: CreateUsuario :one
INSERT INTO usuario (nombre)
VALUES ($1)
RETURNING id;

-- name: CreateCategoria :one
INSERT INTO categoria (nombre)
VALUES ($1)
RETURNING id;