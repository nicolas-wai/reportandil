-- name: CreateReporte :one
INSERT INTO reporte (titulo, descripcion, imagen, estado, usuario_id, categoria_id, direccion_id)
VALUES ($1, $2, $3, $4, $5, $6, $7)
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
SET estado = $2 WHERE id = $1;

-- name: DeleteReporte :exec
DELETE FROM reporte
WHERE id = $1;