package db_test

import (
	"context"
	"database/sql"
	"fmt"
	"testing"

	_ "github.com/jackc/pgx/v5/stdlib"

	db "reportandil/db/sqlc"
)

func TestReporteCRUD(t *testing.T) {
	dsn := "postgres://admin:NZN@localhost:5432/reportandil?sslmode=disable"

	conn, err := sql.Open("pgx", dsn)
	if err != nil {
		t.Fatalf("No se pudo conectar a la base de datos: %v", err)
	}
	defer conn.Close()

	queries := db.New(conn)
	ctx := context.Background()

	// Creacion de usuario, categoria y direccion para usarlo como FK para reporte
	usuarioID, err := queries.CreateUsuario(ctx, "usuario_test")
	if err != nil {
		t.Fatalf("CreateUsuario: %v", err)
	}

	categoriaID, err := queries.CreateCategoria(ctx, "categoria_test")
	if err != nil {
		t.Fatalf("CreateCategoria: %v", err)
	}

	direccionID, err := queries.CreateDireccion(ctx, db.CreateDireccionParams{
		Latitud:           "-37.3285798",
		Longitud:          "-59.1385728",
		DireccionRelativa: sql.NullString{String: "Pinto 399", Valid: true},
	})
	if err != nil {
		t.Fatalf("CreateDireccion: %v", err)
	}

	// Create de reporte
	reporteID, err := queries.CreateReporte(ctx, db.CreateReporteParams{
		Titulo:      "Bache en la calle",
		Descripcion: sql.NullString{String: "Hay un pozo grande", Valid: true},
		UsuarioID:   usuarioID,
		CategoriaID: categoriaID,
		DireccionID: direccionID,
	})
	if err != nil {
		t.Fatalf("CreateReporte: %v", err)
	}
	fmt.Printf("Reporte creado con ID: %d\n\n", reporteID)

	// Read one de reporte
	reporte, err := queries.GetReporte(ctx, reporteID)
	if err != nil {
		t.Fatalf("GetReporte: %v", err)
	}
	if reporte.Titulo != "Bache en la calle" {
		t.Errorf("titulo = %q, esperaba %q", reporte.Titulo, "Bache en la calle")
	}
	if reporte.Estado != "pendiente" {
		t.Errorf("estado = %q, esperaba %q", reporte.Estado, "pendiente")
	}
	fmt.Printf("Reporte leído: %+v\n\n", reporte)

	// Read all de reporte
	reportes, err := queries.ListReportes(ctx)
	if err != nil {
		t.Fatalf("ListReportes: %v", err)
	}
	fmt.Printf("Cantidad de reportes en la base: %d\n\n", len(reportes))

	// Update de reporte
	err = queries.UpdateEstadoReporte(ctx, db.UpdateEstadoReporteParams{
		ID:     reporteID,
		Estado: "resuelto",
	})
	if err != nil {
		t.Fatalf("UpdateEstadoReporte: %v", err)
	}

	actualizado, err := queries.GetReporte(ctx, reporteID)
	if err != nil {
		t.Fatalf("GetReporte (luego de actualizar): %v", err)
	}
	if actualizado.Estado != "resuelto" {
		t.Errorf("estado luego de actualizar = %q, esperaba %q", actualizado.Estado, "resuelto")
	}
	fmt.Printf("Reporte actualizado: %+v\n\n", actualizado)

	// Delete de reporte
	err = queries.DeleteReporte(ctx, reporteID)
	if err != nil {
		t.Fatalf("DeleteReporte: %v", err)
	}
	fmt.Print("Reporte eliminado\n\n")

	_, err = queries.GetReporte(ctx, reporteID)
	if err == nil {
		t.Errorf("se esperaba un error al buscar el reporte luego de borrarlo")
	} else {
		fmt.Print("Reporte no encontrado luego de borrarlo, como se esperaba\n\n")
	}
}
