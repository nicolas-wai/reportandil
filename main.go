package main

import (
	"database/sql"
	"log"
	"os"
)

func main() {
	dsn := os.Getenv("DB_URL")
	if dsn == "" {
		log.Fatal("DB_URL no definidia")
	}
	conn, err := sql.Open("pgx", dsn)
	if err != nil {
		log.Fatalf("No se pudo conectar a la base de datos: %v", err)
	}
	defer conn.Close()
}
