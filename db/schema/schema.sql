CREATE TABLE reporte (
    id serial PRIMARY KEY,
    titulo varchar(50) NOT NULL,
    descripcion varchar(200),
    imagen varchar,
    estado varchar NOT NULL DEFAULT 'en_revision',
    latitud DECIMAL(10, 8) NOT NULL DEFAULT 0,
    longitud DECIMAL(11, 8) NOT NULL DEFAULT 0,
    direccion_relativa VARCHAR,
    created_at timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
    usuario_id integer NOT NULL,
    categoria_id integer NOT NULL
);

CREATE TABLE usuario(
    id serial PRIMARY KEY,
    nombre varchar(20) UNIQUE NOT NULL
);

CREATE TABLE categoria(
    id serial PRIMARY KEY,
    nombre varchar UNIQUE NOT NULL
);

ALTER TABLE reporte ADD CONSTRAINT reporte_usuario_fk
FOREIGN KEY(usuario_id) REFERENCES usuario(id);

ALTER TABLE reporte ADD CONSTRAINT reporte_categoria_fk
FOREIGN KEY(categoria_id) REFERENCES categoria(id);

ALTER TABLE reporte ADD CONSTRAINT chk_reporte_estado
CHECK(estado IN ('en_revision', 'aceptado', 'en_progreso', 'resuelto', 'rechazado'));