package handlers

import (
	"database/sql"
	"encoding/json"
	"errors"
	"fmt"
	"net/http"
	db "reportandil/db/sqlc"
	"strconv"
	"strings"
)

type ReportHandler struct {
	queries *db.Queries
}

func NewReportHandler(conn *sql.DB) *ReportHandler {
	return &ReportHandler{
		queries: db.New(conn),
	}
}

// Usado para poder hacer PUT y POST
type reportTemp struct {
	Titulo      string `json:"titulo"`
	Descripcion string `json:"descripcion"`
	Imagen      string `json:"imagen"`
	Estado      string `json:"estado"`
	UsuarioID   int32  `json:"usuario_id"`
	CategoriaID int32  `json:"categoria_id"`
}

var validStates = map[string]bool{
	"en_revision": true,
	"aceptado":    true,
	"en_progreso": true,
	"resuelto":    true,
	"rechazado":   true,
}

func (reporte reportTemp) validarDatos() error {
	// Validar 1. Titulo no vacío
	if strings.TrimSpace(reporte.Titulo) == "" {
		return fmt.Errorf("El titulo no puede estar vacío")
	}
	// Validar 2. UsuarioID, CategoriaID > 0
	if reporte.UsuarioID <= 0 || reporte.CategoriaID <= 0 {
		return fmt.Errorf("usuario_id y categoria_id deben ser mayores a cero")
	}

	return nil
}

// GET /<reportes>: Debe usar el método List... de sqlc para obtener todos los registros y devolverlos como un array JSON.
func (rh *ReportHandler) getReportes(w http.ResponseWriter, r *http.Request) {
	reportes, err := rh.queries.ListReportes(r.Context())
	if err != nil {
		http.Error(w, "Error al obtener datos de la base", http.StatusInternalServerError)
		return
	}
	if reportes == nil {
		reportes = []db.Reporte{}
	}
	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(reportes)
}

// GET /<reportes>/{id}: Debe obtener el ID de la URL, buscar el registro con Get... y devolverlo. Si no existe, debe devolver un 404.*/
func (rh *ReportHandler) getReporte(w http.ResponseWriter, r *http.Request, id int32) {
	reporte, err := rh.queries.GetReporte(r.Context(), id)
	if err != nil {
		if errors.Is(err, sql.ErrNoRows) {
			http.Error(w, "Reporte no encontrado", http.StatusNotFound)
			return
		}
		http.Error(w, "Error al obtener datos de la base", http.StatusInternalServerError)
		return
	}
	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(reporte)

}

// POST /<entidades>: Debe recibir datos en formato JSON, validarlos, usar el método Create para guardarlos en la base de datos y devolver el nuevo objeto como JSON con estado 201.
func (rh *ReportHandler) createReporte(w http.ResponseWriter, r *http.Request) {
	var temp reportTemp
	if err := json.NewDecoder(r.Body).Decode(&temp); err != nil {
		http.Error(w, "No se envió un JSON correcto", http.StatusBadRequest)
		return
	}

	if err := temp.validarDatos(); err != nil {
		http.Error(w, err.Error(), http.StatusUnprocessableEntity)
		return
	}

	newId, err := rh.queries.CreateReporte(r.Context(), db.CreateReporteParams{
		Titulo:      temp.Titulo,
		Descripcion: sql.NullString{String: temp.Descripcion, Valid: temp.Descripcion != ""},
		Imagen:      sql.NullString{String: temp.Imagen, Valid: temp.Imagen != ""},
		UsuarioID:   temp.UsuarioID,
		CategoriaID: temp.CategoriaID,
	})

	if err != nil {
		http.Error(w, "Error al guardar el reporte", http.StatusInternalServerError)
		return
	}
	// Lee para leer el reporte como quedó en la base
	newReporte, err := rh.queries.GetReporte(r.Context(), newId)
	if err != nil {
		http.Error(w, "Error al buscar el reporte", http.StatusInternalServerError)
		return
	}
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(http.StatusCreated)
	json.NewEncoder(w).Encode(newReporte)
}

// DELETE /<entidades>/{id}: Debe eliminar el registro usando Delete... y devolver un estado 204 (NoContent).
func (rh *ReportHandler) deleteReporte(w http.ResponseWriter, r *http.Request, id int32) {
	_, err := rh.queries.DeleteReporte(r.Context(), id)
	if err != nil {
		if errors.Is(err, sql.ErrNoRows) {
			http.Error(w, "Reporte no encontrado", http.StatusNotFound)
			return
		}
		http.Error(w, "Error al intentar eliminar", http.StatusInternalServerError)
		return
	}
	w.WriteHeader(http.StatusNoContent)
}

// PUT /<entidades>/{id}: Debe recibir datos JSON, validarlos, y actualizar el registro correspondiente usando Update....
func (rh *ReportHandler) updateReporte(w http.ResponseWriter, r *http.Request, id int32) {
	var temp reportTemp
	if err := json.NewDecoder(r.Body).Decode(&temp); err != nil {
		http.Error(w, "No se envió un JSON correcto", http.StatusBadRequest)
		return
	}

	if !validStates[temp.Estado] {
		http.Error(w, "Estado invalido", http.StatusBadRequest)
		return
	}

	_, err := rh.queries.UpdateEstadoReporte(r.Context(), db.UpdateEstadoReporteParams{
		ID:     id,
		Estado: temp.Estado,
	})
	if err != nil {
		if errors.Is(err, sql.ErrNoRows) {
			http.Error(w, "Reporte no encontrado", http.StatusNotFound)
			return
		}
		http.Error(w, "Error al actualizar el reporte", http.StatusInternalServerError)
		return
	}

	w.WriteHeader(http.StatusNoContent)
}

func (rh *ReportHandler) ReportesHandler(w http.ResponseWriter, r *http.Request) {
	segments := strings.Split(strings.Trim(r.URL.Path, "/"), "/")

	if len(segments) == 1 {
		switch r.Method {
		case http.MethodGet:
			rh.getReportes(w, r)
		case http.MethodPost:
			rh.createReporte(w, r)
		default:
			w.Header().Set("Allow", "GET, POST")
			http.Error(w, "Method Not Allowed", http.StatusMethodNotAllowed)
		}
		return
	}

	if len(segments) == 2 {
		idInt, err := strconv.Atoi(segments[1])
		if err != nil || idInt <= 0{
			http.Error(w, "Invalid ID", http.StatusBadRequest)
			return
		}
		id := int32(idInt)


		switch r.Method {
		case http.MethodGet:
			rh.getReporte(w, r, id)
		case http.MethodPut:
			rh.updateReporte(w, r, id)
		case http.MethodDelete:
			rh.deleteReporte(w, r, id)
		default:
			w.Header().Set("Allow", "GET, PUT, DELETE")
			http.Error(w, "Method Not Allowed", http.StatusMethodNotAllowed)
		}
		return
	}
	http.NotFound(w, r)
}
