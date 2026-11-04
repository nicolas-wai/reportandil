const API_URL = "/reportes";
const form = document.getElementById("form-reporte");
const lista = document.getElementById("lista-reportes");

// Maneja el problema de nulls de sqlc
function valor(campo) {
  if (campo && campo.valid){
    return campo.String;
  }
  return "";
}

function cargarReportes(){
  fetch(API_URL)
  .then((response) => {
    if(!response.ok){
      throw new Error("Network error");
    }
    return response.json();
  })
  .then((reportes) => {
    lista.innerHTML = "" // Vacia la lista
    reportes.forEach((r) => {
      const linea = document.createElement("li");
      linea.dataset.id = r.id; // Le asigna el id del li, lo mismo que el id del reporte
      linea.className = "reporte-item"

      const info = document.createElement("div");
      info.textContent = `${r.titulo} [${r.estado}] ${valor(r.descripcion)}`;

      const boton = document.createElement("button");
      boton.textContent = "Eliminar";
      boton.className = "boton-eliminar"

      linea.appendChild(boton)
      linea.appendChild(info)
      lista.appendChild(linea)
    });
  })
  .catch((error) => console.error("Error al cargar reportes", error));
}

form.addEventListener("submit", (e) => {
  e.preventDefault();

  const reporte = {
    titulo: document.querySelector("#titulo").value,
    descripcion: document.querySelector("#descripcion").value,
    usuario_id: Number(document.querySelector("#usuario_id").value),
    categoria_id: Number(document.querySelector("#categoria_id").value),
  };

  console.log(JSON.stringify(reporte))

  fetch(API_URL, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify(reporte),
  })
  .then((response) => {
    if (!response.ok){
      throw new Error("Error al crear el reporte");
    }
    form.reset();
    cargarReportes();
  })
  .catch((error) => alert("Error al crear reportes", error));

})

lista.addEventListener("click", (e) => {
    const botonEliminar = e.target.closest(".boton-eliminar");
    if (!botonEliminar) return;

    const li = botonEliminar.closest("li");
    const reporteID = li.dataset.id;
    if (!reporteID) return;

    fetch(API_URL + "/" + reporteID ,{
      method: "DELETE"
    })
    .then((response) => {
      if (!response.ok) {
        throw new Error("Error al eliminar el reporte");
      }
      cargarReportes();
    })
    .catch((error) => alert("Error al eliminar el reporte", error));
})

  cargarReportes();