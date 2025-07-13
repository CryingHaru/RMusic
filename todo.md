# Plan de migración: Cache → Descargas

## Objetivo

Convertir el sistema de cache en memoria/interna a un sistema de descargas persistentes con control de estado, progreso y gestión de archivos.

## Tareas detalladas

### 1. Módulo `download`

- Crear paquete `com.rmusic.download`.
- Definir interfaz `DownloadProvider` con métodos:
  - `suspend fun downloadTrack(trackId: String): Flow<DownloadState>`
  - `suspend fun pauseDownload(id: String)`
  - `suspend fun resumeDownload(id: String)`
  - `suspend fun cancelDownload(id: String)`
- Implementaciones concretas por proveedor (Innertube, Piped, etc.).

### 2. Persistencia de archivos

- Directorio de destino: `context.getExternalFilesDir("downloads")`.
- Escribir stream de Ktor al disco usando `FileOutputStream` con buffer.
- Nombrado de archivos basado en `trackId` y metadatos (`<trackId>.mp3` o `<title>.mp3`).
- Manejar permisos de almacenamiento si aplica.

### 3. Estado y metadatos

- Definir entidad Room `DownloadEntity`:
  ```kotlin
  @Entity tableName = "downloads"
  data class DownloadEntity(
    @PrimaryKey val id: String,
    val trackId: String,
    val filePath: String,
    val state: DownloadState,
    val progress: Int
  )
  ```
- Crear DAO y base de datos.
- Repositorio que expone `Flow<List<DownloadEntity>>`.
- ViewModel + LiveData/Flow para la UI.

### 4. Scheduling y robustez

- Integrar WorkManager para descargas en background con:
  - Reintentos automáticos.
  - Condiciones de red (solo Wi-Fi, carga de batería, etc.).
- Opcional: usar `DownloadManager` nativo para notificaciones del sistema.

### 5. UI y ajustes

- Nueva pantalla “Descargas”:
  - Lista de descargas activas y completadas.
  - Progreso, botones de pausar/resumir/cancelar.
- Ajustes en Configuración:
  - Carpeta de descargas personalizable.
  - Límite de espacio usado.
  - Descargas solo en Wi-Fi.

### 6. Integración con proveedores

- Extender cada `Provider` (Innertube, Piped, ...) con método `downloadTrack(...)`.
- Reusar `HttpClient` global y los interceptores existentes.
- Deprecate la lógica de “pre-cache” y migrar la UI para usar descargas.

### 7. Migración de datos (opcional)

- Detectar archivos existentes en cache interno.
- Registrarlos como descargas completadas en la DB.

### 8. Verificación manual

- Probar descarga de varias pistas, pausar, reanudar, cancelar.
- Probar condiciones de red y reintentos con WorkManager.
- Validar limpieza de archivos al borrar o cancelar.
