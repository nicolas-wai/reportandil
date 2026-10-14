package handlers

import (
	"context"
	"database/sql"
	"encoding/json"
	"fmt"
	"net/http"
	db "reportandil/db/sqlc"
	"strconv"
	"strings"
)

type ReportHandler struct {
	queries *db.Queries
	ctx      context.Context
}

func NewReportHandler(conn *sql.DB) *ReportHandler{
	return &ReportHandler{
			queries: db.New(conn),
			ctx: context.Background(),
	}
}

func (rh *ReportHandler) getReportes(w http.ResponseWriter, r *http.Request) {
	arr, err := rh.queries.ListReportes(rh.ctx)
	if err != nil {
		return
	}
	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(arr)
	/*GET /<entidades>: Debe usar el método List... de sqlc para obtener todos los registros y devolverlos
	como un array JSON.*/
	fmt.Print("TODOS LOS REPORTES\n")

}
func getReporte(w http.ResponseWriter, r *http.Request, id int) {
	/*GET /<entidades>/{id}: Debe obtener el ID de la URL, buscar el registro con Get... y devolverlo. Si no
	existe, debe devolver un 404.*/
	fmt.Printf("REPORTE ID %v\n", id)

}
func createReporte(w http.ResponseWriter, r *http.Request) {
	/*POST /<entidades>: Debe recibir datos en formato JSON, validarlos (ej. que el título no esté vacío), usar el
	método Create... de sqlc para guardarlos en la base de datos y devolver el nuevo objeto como JSON con
	estado 201.*/
	fmt.Print("CREATE\n")

}
func deleteReporte(w http.ResponseWriter, r *http.Request, id int) {
	/*DELETE /<entidades>/{id}: Debe eliminar el registro usando Delete... y devolver un estado 204 (No
	Content).*/
	fmt.Printf("DELETE ID %v\n", id)

}
func updateReporte(w http.ResponseWriter, r *http.Request, id int) {
	/*PUT /<entidades>/{id}: Debe recibir datos JSON, validarlos, y actualizar el registro correspondiente usando
	Update....*/
	fmt.Printf("UPDATE ID %v\n", id)

}

func (rh *ReportHandler) ReportesHandler(w http.ResponseWriter, r *http.Request) {
	segments := strings.Split(strings.Trim(r.URL.Path, "/"), "/")

	if len(segments) == 1 {
		switch r.Method {
		case http.MethodGet:
			rh.getReportes(w, r)
		case http.MethodPost:
			createReporte(w, r)
		default:
			w.Header().Set("Allow", "GET, POST")
			http.Error(w, "Method Not Allowed", http.StatusMethodNotAllowed)
		}
		return
	}

	if len(segments) == 2 {
		id, err := strconv.Atoi(segments[1])
		if err != nil {
			http.Error(w, "Invalid ID", http.StatusBadRequest)
			return
		}

		switch r.Method {
		case http.MethodGet:
			getReporte(w, r, id)
		case http.MethodPut:
			updateReporte(w, r, id)
		case http.MethodDelete:
			deleteReporte(w, r, id)
		default:
			w.Header().Set("Allow", "GET, PUT, DELETE")
			http.Error(w, "Method Not Allowed", http.StatusMethodNotAllowed)
		}
		return
	}
	http.NotFound(w, r)
}