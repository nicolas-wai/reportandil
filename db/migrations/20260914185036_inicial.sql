-- Create "categoria" table
CREATE TABLE "categoria" (
  "id" serial NOT NULL,
  "nombre" character varying NOT NULL,
  CONSTRAINT "categoria_pk" PRIMARY KEY ("id"),
  CONSTRAINT "categoria_nombre_key" UNIQUE ("nombre")
);
-- Create "direccion" table
CREATE TABLE "direccion" (
  "id" serial NOT NULL,
  "latitud" numeric(10,8) NOT NULL,
  "longitud" numeric(11,8) NOT NULL,
  "direccion_relativa" character varying NULL,
  CONSTRAINT "direccion_pk" PRIMARY KEY ("id")
);
-- Create "usuario" table
CREATE TABLE "usuario" (
  "id" serial NOT NULL,
  "nombre" character varying(20) NOT NULL,
  CONSTRAINT "usuario_pk" PRIMARY KEY ("id"),
  CONSTRAINT "usuario_nombre_key" UNIQUE ("nombre")
);
-- Create "reporte" table
CREATE TABLE "reporte" (
  "id" serial NOT NULL,
  "titulo" character varying(50) NOT NULL,
  "descripcion" character varying(200) NULL,
  "imagen" character varying NULL,
  "estado" character varying(50) NOT NULL DEFAULT 'pendiente',
  "created_at" timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "updated_at" timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "usuario_id" integer NOT NULL,
  "categoria_id" integer NOT NULL,
  "direccion_id" integer NOT NULL,
  CONSTRAINT "reporte_pk" PRIMARY KEY ("id"),
  CONSTRAINT "reporte_categoria_fk" FOREIGN KEY ("categoria_id") REFERENCES "categoria" ("id") ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT "reporte_direccion_fk" FOREIGN KEY ("direccion_id") REFERENCES "direccion" ("id") ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT "reporte_usuario_fk" FOREIGN KEY ("usuario_id") REFERENCES "usuario" ("id") ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT "reporte_estado_check" CHECK ((estado)::text = ANY ((ARRAY['en revision'::character varying, 'en progreso'::character varying, 'resuelto'::character varying])::text[]))
);
