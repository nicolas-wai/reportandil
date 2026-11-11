package handlers

import (
	"database/sql"
	"errors"
	"net/http"
	db "reportandil/db/sqlc"
	"reportandil/views"
	"strconv"
	"strings"
)

// Dejar esto hasta que se ponga el login, id = 1 porque es el que crea inicializar-db
const usuarioActualID = 1
const username = "Alfredo"

type ReportHandler struct {
	queries *db.Queries
}

func NewReportHandler(conn *sql.DB) *ReportHandler {
	return &ReportHandler{
		queries: db.New(conn),
	}
}

func validarDatos(titulo string, imagen string, categoriaID int) error {
	if strings.TrimSpace(titulo) == "" {
		return errors.New("El título no puede estar vacío")
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
	if r.Method != http.MethodPost{
		w.Header().Set("Allow", "POST")
		http.Error(w, "Method Not Allowed", http.StatusMethodNotAllowed)
	}
	if err := r.ParseForm(); err != nil {
		http.Error(w, "Formulario inválido", http.StatusBadRequest)
		return
	}

	titulo := r.FormValue("titulo")
	descripcion := r.FormValue("descripcion")
	imagen := r.FormValue("imagen")
	categoriaID, err := strconv.Atoi(r.FormValue("categoria_id"))

	if err != nil {
		http.Error(w, "Categoria invalida", http.StatusBadRequest)
		return
	}

	if err := validarDatos(titulo, imagen, categoriaID); err != nil {
		http.Error(w, err.Error(), http.StatusUnprocessableEntity)
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
		http.Error(w, "Error al guardar el reporte", http.StatusInternalServerError)
		return
	}

	http.Redirect(w, r, "/", http.StatusFound)
}

func (rh *ReportHandler) ReporteByID(w http.ResponseWriter, r *http.Request) {
	id, err := strconv.ParseInt(r.PathValue("id_reporte"), 10, 32)
	if err != nil {
		w.WriteHeader(http.StatusBadRequest)
		views.ReporteErrorPage("ID Invalido", "El ID de reporte de la URL no es valido").Render(r.Context(), w)
		return
	}

	reporte, err := rh.queries.GetReporte(r.Context(), int32(id))
	if errors.Is(err, sql.ErrNoRows) {
		w.WriteHeader(http.StatusNotFound)
		views.ReporteErrorPage("Reporte no encontrado", "El reporte no existe").Render(r.Context(), w)
		return
	}
	if err != nil {
		http.Error(w, "Error al obtener el reporte", http.StatusInternalServerError)
		return
	}

	views.ReportePage(reporte).Render(r.Context(), w)

}

func (rh *ReportHandler) Index(w http.ResponseWriter, r *http.Request) {

	if r.URL.Path != "/" {
		w.WriteHeader(http.StatusNotFound)
		views.ReporteErrorPage("Pagina no encontrada", "La dirección no existe").Render(r.Context(), w)
		return
	}

	reportes, err := rh.queries.ListReportes(r.Context())
	if err != nil {
		http.Error(w, "Error al cargar los datos de la base", http.StatusInternalServerError)
		return
	}
	categorias, err := rh.queries.ListCategorias(r.Context())
	if err != nil {
		http.Error(w, "Error al obtener las categorias", http.StatusInternalServerError)
		return
	}

	views.IndexPage(reportes, categorias, username).Render(r.Context(), w)
}
