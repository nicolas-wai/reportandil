package main

import (
	"database/sql"
	"log"
	"net/http"
	"os"
	handler "reportandil/handlers"

	_ "github.com/jackc/pgx/v5/stdlib"
)

const portDefault = "8080"

func main() {
	dsn := os.Getenv("DB_URL")
	if dsn == "" {
		log.Fatal("DB_URL no definida")
	}
	conn, err := sql.Open("pgx", dsn)
	if err != nil {
		log.Fatalf("No se pudo abrir la conexion a la base de datos: %v", err)
	}
	defer conn.Close()
	conn.SetMaxOpenConns(25)
	if err := conn.Ping(); err != nil {
		log.Fatalf("No se estableció correctamente la conexion con la base de datos: %v", err)
	}
	rh := handler.NewReportHandler(conn)

	http.Handle("/static/", http.StripPrefix("/static/", http.FileServer(http.Dir("static"))))

	http.HandleFunc("/", rh.Index)
	http.HandleFunc("/reportes", rh.NewReporte)
	http.HandleFunc("/reportes/{id_reporte}", rh.ReporteByID)

	port := os.Getenv("PORT")
	if port == "" {
		port = portDefault
	}
	log.Printf("Server running http://localhost:%s", port)
	err = http.ListenAndServe(":"+port, nil)
	if err != nil {
		log.Fatalf("Error %s", err)
	}

}
