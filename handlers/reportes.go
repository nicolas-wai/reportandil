package handlers

import (
	"database/sql"
	"errors"
	"fmt"
	"log"
	"net/http"
	db "reportandil/db/sqlc"
	"reportandil/views"
	"strconv"
	"strings"
	"unicode/utf8"
)

// Dejar esto hasta que se ponga el login, id = 1 porque es el que crea inicializar-db
const usuarioActualID = 1

// Deben coincidir con el largo de las columnas en db/schema/schema.sql
const (
	maxLargoTitulo      = 50
	maxLargoDescripcion = 1000
)

type ReportHandler struct {
	queries *db.Queries
}

func NewReportHandler(conn *sql.DB) *ReportHandler {
	return &ReportHandler{
		queries: db.New(conn),
	}
}

func renderError(w http.ResponseWriter, r *http.Request, status int, titulo string, mensaje string) {
	w.WriteHeader(status)
	if err := views.ReporteErrorPage(titulo, mensaje).Render(r.Context(), w); err != nil {
		log.Printf("Error renderizando error page: %v", err)
	}
}

func validarDatos(titulo string, descripcion string, imagen string, categoriaID int) error {
	if titulo == "" {
		return errors.New("El título no puede estar vacío")
	}
	if utf8.RuneCountInString(titulo) > maxLargoTitulo {
		return fmt.Errorf("El título no puede superar los %d caracteres", maxLargoTitulo)
	}
	if utf8.RuneCountInString(descripcion) > maxLargoDescripcion {
		return fmt.Errorf("La descripción no puede superar los %d caracteres", maxLargoDescripcion)
	}
	if imagen != "" && !strings.HasPrefix(imagen, "http://") && !strings.HasPrefix(imagen, "https://") {
		return errors.New("La imagen debe ser una URL que empiece con http:// o https://")
	}
	if categoriaID <= 0 {
		return errors.New("Debe seleccionar una categoría")
	}
	return nil
}

func (rh *ReportHandler) NewReporte(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodPost {
		w.Header().Set("Allow", "POST")
		renderError(w, r, http.StatusMethodNotAllowed, "Método no permitido", "Esta dirección solo se usa para el envío del formulario")
		return
	}
	if err := r.ParseForm(); err != nil {
		renderError(w, r, http.StatusBadRequest, "Formulario inválido", "No se pudo leer el formulario enviado")
		return
	}

	titulo := strings.TrimSpace(r.FormValue("titulo"))
	descripcion := r.FormValue("descripcion")
	imagen := r.FormValue("imagen")
	categoriaID, err := strconv.Atoi(r.FormValue("categoria_id"))

	if err != nil {
		renderError(w, r, http.StatusBadRequest, "Categoría inválida", "Debe seleccionar una categoría")
		return
	}

	if err := validarDatos(titulo, descripcion, imagen, categoriaID); err != nil {
		renderError(w, r, http.StatusUnprocessableEntity, "Datos inválidos", err.Error())
		return
	}

	_, err = rh.queries.CreateReporte(r.Context(), db.CreateReporteParams{
		Titulo:      titulo,
		Descripcion: sql.NullString{String: descripcion, Valid: descripcion != ""},
		Imagen:      sql.NullString{String: imagen, Valid: imagen != ""},
		UsuarioID:   usuarioActualID,
		CategoriaID: int32(categoriaID),
	})

	if err != nil {
		log.Printf("Error guardando el reporte: %v", err)
		renderError(w, r, http.StatusInternalServerError, "Error al guardar", "No se pudo guardar el reporte")
		return
	}

	reportes, err := rh.queries.ListReportes(r.Context())
	if err != nil {
		log.Printf("Error al cargar los reportes: %v", err)
		renderError(w, r, http.StatusInternalServerError, "Error al cargar los datos", "No se pudieron obtener los reportes")
		return
	}

	categorias, err := rh.queries.ListCategorias(r.Context())
	if err != nil {
		log.Printf("Error al obtener las categorias: %v", err)
		renderError(w, r, http.StatusInternalServerError, "Error al cargar los datos", "No se pudieron obtener las categorías")
		return
	}
	if err := views.ReporteList(reportes).Render(r.Context(), w); err != nil {
		log.Printf("Error renderizando la lista de reportes: %v", err)
		return
	}

	// Esta es por el swap-oob
	if err := views.ReporteForm(categorias).Render(r.Context(), w); err != nil {
		log.Printf("Error renderizando el formulario: %v", err)
	}
}

func (rh *ReportHandler) DeleteReporte(w http.ResponseWriter, r *http.Request) {
	id, err := strconv.ParseInt(r.PathValue("id_reporte"), 10, 32)
	if err != nil {
		renderError(w, r, http.StatusBadRequest, "ID inválido", "El ID de reporte de la URL no es válido")
		return
	}

	_, err = rh.queries.DeleteReporte(r.Context(), int32(id))

	if errors.Is(err, sql.ErrNoRows) {
		renderError(w, r, http.StatusNotFound, "Reporte no encontrado", "El reporte no existe")
		return
	}

	if err != nil {
		log.Printf("Error al eliminar el reporte %d: %v", id, err)
		renderError(w, r, http.StatusInternalServerError, "Error al eliminar el reporte", "No se pudo eliminar el reporte")
		return
	}

	w.WriteHeader(http.StatusOK)
}

func (rh *ReportHandler) ReporteByID(w http.ResponseWriter, r *http.Request) {
	if r.Method == http.MethodDelete {
		rh.DeleteReporte(w, r)
		return
	}

	id, err := strconv.ParseInt(r.PathValue("id_reporte"), 10, 32)
	if err != nil {
		renderError(w, r, http.StatusBadRequest, "ID inválido", "El ID de reporte de la URL no es válido")
		return
	}

	reporte, err := rh.queries.GetReporte(r.Context(), int32(id))
	if errors.Is(err, sql.ErrNoRows) {
		renderError(w, r, http.StatusNotFound, "Reporte no encontrado", "El reporte no existe")
		return
	}
	if err != nil {
		log.Printf("Error al obtener el reporte %d: %v", id, err)
		renderError(w, r, http.StatusInternalServerError, "Error al obtener el reporte", "No se pudo cargar el reporte")
		return
	}

	if err := views.ReporteDetail(reporte).Render(r.Context(), w); err != nil {
		log.Printf("Error renderizando detalle de reporte: %v", err)
	}
}

func (rh *ReportHandler) Index(w http.ResponseWriter, r *http.Request) {
	if r.URL.Path != "/" {
		renderError(w, r, http.StatusNotFound, "Página no encontrada", "La dirección no existe")
		return
	}

	reportes, err := rh.queries.ListReportes(r.Context())
	if err != nil {
		log.Printf("Error al cargar los reportes: %v", err)
		renderError(w, r, http.StatusInternalServerError, "Error al cargar los datos", "No se pudieron obtener los reportes")
		return
	}
	categorias, err := rh.queries.ListCategorias(r.Context())
	if err != nil {
		log.Printf("Error al obtener las categorias: %v", err)
		renderError(w, r, http.StatusInternalServerError, "Error al cargar los datos", "No se pudieron obtener las categorías")
		return
	}

	if err := views.IndexPage(reportes, categorias).Render(r.Context(), w); err != nil {
		log.Printf("Error renderizando el index: %v", err)
	}
}
