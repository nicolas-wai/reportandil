package main

import (
	//"context"
	"database/sql"
	"fmt"
	"log"
	"net/http"
	crudgorm "reportandil/crudGORM"
	modelsgorm "reportandil/modelsGORM"

	//"reportandil/models"
	//"reportandil/repository"
	//sqlc "reportandil/db/sqlc"

	"gorm.io/driver/postgres"
	"gorm.io/gorm"

	_ "github.com/jackc/pgx/v5/stdlib"
)

func serveOpinion(w http.ResponseWriter, r *http.Request) {
	if r.URL.Path != "/opinion" || r.Method != http.MethodPost {
		http.NotFound(w, r)
		return
	}
	if err := r.ParseForm(); err != nil {
		http.Error(w, "Error al parsear", http.StatusBadRequest)
		return
	}
	name := r.FormValue("name")
	w.Header().Set("Content-Type", "text/html; charset=utf-8")
	fmt.Fprintf(w, `<!DOCTYPE html>
						<html lang="es">
						<head>
							<meta charset="UTF-8">
							<meta name="viewport" content="width=device-width, initial-scale=1.0">
							<link rel="stylesheet" href="/css/styles.css">
							<title>Gracias por tu Opinion!</title>
						</head>
						<body>
							<h1>Gracias por tu opinion, %s!</h1>
							<a href="/">Volver</a>
						</body>
						</html>`,
		name)
}

func serveHome(w http.ResponseWriter, r *http.Request) {
	if r.URL.Path != "/" || r.Method != http.MethodGet {
		http.NotFound(w, r)
		return
	}
	w.Header().Set("Content-Type", "text/html; charset=utf-8")
	http.ServeFile(w, r, "./index.html")
}

func main() {
	/*connStr := "host=localhost port=5432 user=admin password=NZN dbname=test"
	db, err := abrirDB(connStr)
	if err != nil {
		log.Fatalf("Error al conectarse: %v", err)
	}
	defer db.Close()
	log.Println("Conexion establecida con la bd")*/

	/*userRepo := repository.NewUserRepository(db)
	*u := models.User{Name: "Nico RM", Email: "nicorm@gmail.com"}
	userRepo.CreateUser(&u)
	u := models.User{ID: 1, Name: "Nico W", Email: "nicow@gmail.com"}
	userRepo.UpdateUser(&u)*/

	/*queries := sqlc.New(db)
	ctx := context.Background()
	user, err := queries.GetUser(ctx, 1)
	if err != nil {
		log.Print("Usuario no encontrado")
	}
	fmt.Println(user)*/

	dns := "host=localhost port=5432 user=admin password=NZN dbname=test sslmode=disable"
	db, err := gorm.Open(postgres.Open(dns), &gorm.Config{})
	if err != nil {
		log.Fatalf("Error al conectarse: %v", err)
	}
	db.AutoMigrate(&modelsgorm.User{})

	//crudgorm.CreateUser(db, &modelsgorm.User{Name: "Pepe2", Email: "nicow@gmail.com"})
	//u := crudgorm.ReadUser(db, 5)
	crudgorm.ListUsers(db)
	//crudgorm.UpdateUser(db, u, "Pepe 2")
	// crudgorm.DeleteUser(db, 5)

	staticDir := "./static"
	fileServer := http.FileServer(http.Dir(staticDir))
	http.Handle("/", fileServer)

	http.HandleFunc("/opinion", serveOpinion)

	port := ":8080"
	fmt.Printf("Server running localhost%s", port)
	err = http.ListenAndServe(port, nil)
	if err != nil {
		fmt.Printf("Error %s", err)
	}
}

func abrirDB(connStr string) (*sql.DB, error) {
	db, err := sql.Open("pgx", connStr)
	if err != nil {
		return nil, err
	}
	if err := db.Ping(); err != nil {
		db.Close()
		return nil, err
	}
	db.SetMaxOpenConns(25)
	return db, nil
}
