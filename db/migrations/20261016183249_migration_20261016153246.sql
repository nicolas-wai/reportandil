-- Create "categoria" table
CREATE TABLE "categoria" (
  "id" serial NOT NULL,
  "nombre" character varying NOT NULL,
  PRIMARY KEY ("id"),
  CONSTRAINT "categoria_nombre_key" UNIQUE ("nombre")
);
-- Create "usuario" table
CREATE TABLE "usuario" (
  "id" serial NOT NULL,
  "nombre" character varying(20) NOT NULL,
  PRIMARY KEY ("id"),
  CONSTRAINT "usuario_nombre_key" UNIQUE ("nombre")
);
-- Create "reporte" table
CREATE TABLE "reporte" (
  "id" serial NOT NULL,
  "titulo" character varying(50) NOT NULL,
  "descripcion" character varying(200) NULL,
  "imagen" character varying NULL,
  "estado" character varying NOT NULL DEFAULT 'en_revision',
  "latitud" numeric(10,8) NOT NULL DEFAULT 0,
  "longitud" numeric(11,8) NOT NULL DEFAULT 0,
  "direccion_relativa" character varying NULL,
  "created_at" timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "updated_at" timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "usuario_id" integer NOT NULL,
  "categoria_id" integer NOT NULL,
  PRIMARY KEY ("id"),
  CONSTRAINT "reporte_categoria_fk" FOREIGN KEY ("categoria_id") REFERENCES "categoria" ("id") ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT "reporte_usuario_fk" FOREIGN KEY ("usuario_id") REFERENCES "usuario" ("id") ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT "chk_reporte_estado" CHECK ((estado)::text = ANY ((ARRAY['en_revision'::character varying, 'aceptado'::character varying, 'en_progreso'::character varying, 'resuelto'::character varying, 'rechazado'::character varying])::text[]))
);
