package main

import (
	"database/sql"
	"fmt"
	"log"
	"net/http"
	"os"
	handler "reportandil/handlers"

	_ "github.com/jackc/pgx/v5/stdlib"
)

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
		log.Fatalf("No se estableció correctamente la conexion con la base de datos")
	}
	rh := handler.NewReportHandler(conn)

	http.HandleFunc("/reportes", rh.ReportesHandler)
	http.HandleFunc("/reportes/", rh.ReportesHandler)
	port := ":8080"
	fmt.Printf("Server running localhost%s", port)
	err = http.ListenAndServe(port, nil)
	if err != nil {
		log.Fatalf("Error %s", err)
	}

}
