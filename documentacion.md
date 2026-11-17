# Documentación


## Flujo de la aplicación

- **Pagina principal:** `GET /` muestra el formulario para crear reportes y la lista de reportes en la misma página.
- **Al crear un reporte:** el formulario hace `POST /reportes`. Si los datos son válidos se guarda el reporte y se redirige a `/`, que vuelve a listar con el reporte nuevo.
- **Detalle de un reporte:** `GET /reportes/{id_reporte}` muestra un reporte completo.
- **Errores:** Ante un error, ya sea por datos invalidos, reporte inexistente, ruta no definida o fallas internas. Se muestran en una pagina con el error y un boton para volver a la pagina principal.

## Capa de Datos (persistencia)

### Modelo principal

Esquema principal de la base de datos:
<img width="60%" height="823" alt="RelacionalMain" src="https://github.com/user-attachments/assets/7355e8f9-5b86-48f4-82d2-55e7838b9e27" />

### Entidad REPORTE
El _estado_ de un reporte se describe de la siguiente manera:
<img width="60%" alt="estadosReporte" src="https://github.com/user-attachments/assets/6498af81-653c-4581-b57f-a6fb4ab7964e" />

## Aclaraciones y limitaciones actuales

- **Errores de la base de datos.** No se interpretan los códigos de error de PostgreSQL. Ante un insert o update que incumple una restricción de la base (Por ejemplo, una `categoria_id` que no existe porque se manipuló el formulario), se muestra la pagina de error interno (`500`) en lugar de un error `4xx`.

- **El usuario está fijo.** Los reportes se guardan con el usuario de id 1, el que crea `make inicializar-db`. Temporal hasta que haya cuentas.

## Trabajo futuro
- Crear pantallas para **crear y consultar** usuarios y categorías.

- El usuario debe **autenticarse con cookies o tokens** y los reportes se asociarán al usuario autenticado.

- Crear la ruta y vista para **Cambio de estado de un reporte**.

- Definir **roles** (usuario / administrador): el cambio de estado debería quedar restringido a administradores, y cada usuario solo debería poder modificar o eliminar sus propios reportes.
- Las columnas `latitud` y `longitud` de `reporte` tienen `DEFAULT 0` y el formulario todavía no las recibe, por lo que todos los reportes quedan en la coordenada (0, 0). Más adelante deberían tratarse correctamente, idealmente obteniéndolas desde un mapa interactivo.