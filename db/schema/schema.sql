CREATE TABLE reporte (
    id serial,
    titulo varchar(50) NOT NULL,
    descripcion varchar(200),
    imagen varchar,
    estado varchar(50) NOT NULL DEFAULT 'pendiente' CHECK (estado IN ('en revision', 'en progreso', 'resuelto')),
    created_at timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
    usuario_id integer NOT NULL,
    categoria_id integer NOT NULL,
    direccion_id integer NOT NULL
);

CREATE TABLE usuario(
    id serial,
    nombre varchar(20) UNIQUE NOT NULL
);

CREATE TABLE categoria(
    id serial,
    nombre varchar UNIQUE NOT NULL
);

CREATE TABLE direccion(
    id serial,
    latitud DECIMAL(10, 8) NOT NULL,
    longitud DECIMAL(11, 8) NOT NULL,
    direccion_relativa varchar
);

ALTER TABLE reporte ADD CONSTRAINT reporte_pk PRIMARY KEY(id);
ALTER TABLE usuario ADD CONSTRAINT usuario_pk PRIMARY KEY(id);
ALTER TABLE categoria ADD CONSTRAINT categoria_pk PRIMARY KEY(id);
ALTER TABLE direccion ADD CONSTRAINT direccion_pk PRIMARY KEY(id);

ALTER TABLE reporte ADD CONSTRAINT reporte_usuario_fk
FOREIGN KEY(usuario_id) REFERENCES usuario(id);

ALTER TABLE reporte ADD CONSTRAINT reporte_categoria_fk
FOREIGN KEY(categoria_id) REFERENCES categoria(id);

ALTER TABLE reporte ADD CONSTRAINT reporte_direccion_fk
FOREIGN KEY(direccion_id) REFERENCES direccion(id);
