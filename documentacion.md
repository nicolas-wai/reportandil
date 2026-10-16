# Documentación

**Campos del POST**
- `titulo`: Obligatorio (`varchar(50) NOT NULL`)
- `descripcion`: Opcional (`varchar(200)`)
- `imagen`: Opcional, link (`varchar`)
- `usuario_id`: Obligatorio, id > 0, (FK a `usuario`)
- `categoria_id`: Obligatorio, id > 0, (FK a `categoria`)

El estado inicial siempre es `en_revision` (valor por defecto de la base); si el POST envía `estado`, se ignora.

### Decisión: el PUT solo actualiza el estado

`PUT /reportes/{id}` modifica únicamente el `estado`, por eso solo valida ese campo. La idea es que más adelante esta operación la ejecuten solo los administradores. La edición de otros datos (título, descripción, imagen) se resolverá con otro método mas adelante.

## Capa de Datos (persistencia)

### Modelo principal

Esquema principal de la base de datos:
<img width="1408" height="768" alt="entidadRelacionMain" src="https://github.com/user-attachments/assets/2101d2cc-2fae-4109-b32e-eede40373398" />

**Entidad REPORTE**
El _estado_ de un reporte se describe de la siguiente manera:
<img width="60%" alt="estadosReporte" src="https://github.com/user-attachments/assets/6498af81-653c-4581-b57f-a6fb4ab7964e" />

## Aclaraciones y limitaciones actuales

- **Errores de la base de datos.** No se interpretan los códigos de error de PostgreSQL. Ante un insert o update que incumple una restricción de la base (clave foránea inexistente, texto que supera el largo de la columna, etc.) se está retornando un error interno (`500`). Por ejemplo, un `POST` con un `usuario_id` que no existe o un título de más de 50 caracteres devuelve `500` en lugar de un error `4xx`.

## Trabajo futuro
- Crear endpoints para **crear y consultar** usuarios y categorías.
- El usuario debe **autenticarse con cookies o tokens** y usar la creacion del mismo para agregarse a la base.
- Definir **roles** (usuario / administrador): el cambio de estado (`PUT`) debería quedar restringido a administradores, y cada usuario solo debería poder modificar o eliminar sus propios reportes.
- Las columnas `latitud` y `longitud` de `reporte` ahotra tienen `DEFAULT 0`, y el POST todavía no las recibe, por lo que todos los reportes quedan en la coordenada (0, 0). Más adelante deberían tratarse correctamente, idealmente, que se obtengan desde un mapa
- Definir si las validaciones se harán en las 3 capas (Frontend, Backend, Base) o algunas en ciertas capas especificas
