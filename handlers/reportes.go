package handlers

import (
	"database/sql"
	"errors"
	"fmt"
	"net/http"
	db "reportandil/db/sqlc"
	"reportandil/views"
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

func validarDatos(titulo string, usuarioID int, categoriaID int) error {
	// Validar 1. Titulo no vacío
	if strings.TrimSpace(titulo) == "" {
		return fmt.Errorf("El titulo no puede estar vacío")
	}
	// Validar 2. UsuarioID, CategoriaID > 0
	if usuarioID <= 0 || categoriaID <= 0 {
		return fmt.Errorf("usuario_id y categoria_id deben ser mayores a cero")
	}

	return nil
}

func (rh *ReportHandler) NewReporte(w http.ResponseWriter, r *http.Request) {
	switch r.Method {

	case http.MethodGet:
		categorias, err := rh.queries.ListCategorias(r.Context())
		if err != nil {
			http.Error(w, "Error al cargar las categorías", http.StatusInternalServerError)
			return
		}
		views.NewReportPage(categorias, "Alfredo").Render(r.Context(), w)

	case http.MethodPost:
		if err := r.ParseForm(); err != nil {
			http.Error(w, "Formulario inválido", http.StatusBadRequest)
			return
		}

		titulo := r.FormValue("titulo")
		descripcion := r.FormValue("descripcion")
		imagen := r.FormValue("imagen")
		usuarioID, errUsuarioID := strconv.Atoi(r.FormValue("usuario_id"))
		categoriaID, errCategoriaID := strconv.Atoi(r.FormValue("categoria_id"))

		if errUsuarioID != nil || errCategoriaID != nil {
			http.Error(w, "Error al parsear Usuario/Categoria ID", http.StatusBadRequest)
			return
		}

		if err := validarDatos(titulo, usuarioID, categoriaID); err != nil {
			http.Error(w, err.Error(), http.StatusUnprocessableEntity)
			return
		}

		_, err := rh.queries.CreateReporte(r.Context(), db.CreateReporteParams{
			Titulo:      titulo,
			Descripcion: sql.NullString{String: descripcion, Valid: descripcion != ""},
			Imagen:      sql.NullString{String: imagen, Valid: imagen != ""},
			UsuarioID:   int32(usuarioID),
			CategoriaID: int32(categoriaID),
		})

		if err != nil {
			http.Error(w, "Error al guardar el reporte", http.StatusInternalServerError)
			return
		}

		http.Redirect(w, r, "/", http.StatusFound)

	default:
		w.Header().Set("Allow", "GET, POST")
		http.Error(w, "Method Not Allowed", http.StatusMethodNotAllowed)
	}
}

func (rh *ReportHandler) ReporteByID(w http.ResponseWriter, r *http.Request) {
	id, err := strconv.ParseInt(r.PathValue("id_reporte"), 10, 32)
	if err != nil {
		w.WriteHeader(http.StatusBadRequest)
		views.ReportPage(db.Reporte{}, "Alfredo", http.StatusBadRequest).Render(r.Context(), w)
		return
	}

	reporte, err := rh.queries.GetReporte(r.Context(), int32(id))
	if err != nil {

		if errors.Is(err, sql.ErrNoRows) {
			w.WriteHeader(http.StatusNotFound)
			views.ReportPage(db.Reporte{}, "Alfredo", http.StatusNotFound).Render(r.Context(), w)
			return
		}

		w.WriteHeader(http.StatusInternalServerError)
		views.ReportPage(db.Reporte{}, "Alfredo", http.StatusInternalServerError).Render(r.Context(), w)
		return

	}

	views.ReportPage(reporte, "Alfredo", http.StatusOK).Render(r.Context(), w)

}

func (rh *ReportHandler) Index(w http.ResponseWriter, r *http.Request) {
	reportes, err := rh.queries.ListReportes(r.Context())
	if err != nil {
		http.Error(w, "Error al cargar los datos de la base", http.StatusInternalServerError)
		return
	}

	views.IndexPage(reportes, "Alfredo").Render(r.Context(), w)
}
