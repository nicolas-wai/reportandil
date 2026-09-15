package db

import (
	"context"
	"database/sql"
	"testing"

	_ "github.com/lib/pq"
)

func TestOperacionesSQL(t *testing.T) {
	db, err := sql.Open("postgres", "postgres://admin:NZN@localhost:5432/reportandil?sslmode=disable")
	if err != nil {
		t.Fatal(err)
	}
	defer db.Close()

	// borra el contenido de las tablas una vez que finaliza el test
	defer func() {
		_, err := db.Exec("TRUNCATE TABLE reporte, usuario, categoria, direccion CASCADE")
		if err != nil {
			t.Log("Error al limpiar las tablas:", err)
		}
	}()

	q := New(db)
	ctx := context.Background()

	usuarioID, err := q.CreateUsuario(ctx, "Enzo")
	if err != nil {
		t.Fatal(err)
	}

	categoria, err := q.CreateCategoria(ctx, "Infraestructura")
	if err != nil {
		t.Fatal(err)
	}

	direccion, err := q.CreateDireccion(ctx, CreateDireccionParams{
		Latitud:           "-34.6037",
		Longitud:          "-58.3816",
		DireccionRelativa: sql.NullString{String: "Avenida Avellaneda 1236", Valid: true},
	})
	if err != nil {
		t.Fatal(err)
	}

	reporteID, err := q.CreateReporte(ctx, CreateReporteParams{
		Titulo:      "Bache peligroso",
		Descripcion: sql.NullString{String: "Hundimiento en el asfalto", Valid: true},
		Imagen:      sql.NullString{String: "foto.png", Valid: true},
		UsuarioID:   usuarioID.Int32,
		CategoriaID: categoria.ID.Int32, 
		DireccionID: direccion.ID.Int32, 
	})
	if err != nil {
		t.Fatal(err)
	}

	reporte, err := q.GetReporte(ctx, reporteID)
	if err != nil {
		t.Fatal(err)
	}

	if reporte.Titulo != "Bache peligroso" {
		t.Errorf("Titulo erroneo: %s", reporte.Titulo)
	}

	err = q.UpdateEstadoReporte(ctx, UpdateEstadoReporteParams{
		ID:     reporteID,
		Estado: "en progreso",
	})
	if err != nil {
		t.Fatal(err)
	}

	lista, err := q.ListReportes(ctx)
	if err != nil {
		t.Fatal(err)
	}

	if len(lista) == 0 {
		t.Error("La lista de reportes esta vacia")
	}

	err = q.DeleteReporte(ctx, reporteID)
	if err != nil {
		t.Fatal(err)
	}
}