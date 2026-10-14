## Funcionalidad

[...]

## Capa de Datos (persistencia)

### Modelo principal

Esquema principal de la base de datos:
<img width="1408" height="768" alt="entidadRelacionMain" src="https://github.com/user-attachments/assets/2101d2cc-2fae-4109-b32e-eede40373398" />

**Entidad REPORTE**
El _estado_ de un reporte se describe de la siguiente manera:
<img width="60%" alt="estadosReporte" src="https://github.com/user-attachments/assets/6498af81-653c-4581-b57f-a6fb4ab7964e" />

Faltan restricciones para limitar los valores posibles de la columna estado

## Todavia no sabemos:

- Las queries deberian ser genericas y filtrarse en la capa de logica o hacer diferentes queries en la capa de datos para las diferentes opciones?
  Por ejemplo, el listReportes, deberia devolver todo o hacer diferentes queries segun quien vea la lista (Usuario/administrador)

- Estado no me dejo atlas que sea un dominio para limitar las opciones, ver como solucionar eso
