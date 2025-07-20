# Plan de Implementación: Sistema de Descargas Completo

## Objetivo

Finalizar la implementación del sistema de descargas persistentes con control de estado, progreso y gestión de archivos, reemplazando completamente el sistema de pre-cache actual.

## Estado Actual (Julio 2025)

### ✅ Completado
- Módulo `download/` con infraestructura básica
- `HttpDownloadProvider` implementado
- `MusicDownloadService` funcional
- Interfaz `DownloadProvider` definida
- Estados de descarga (`DownloadState`) implementados
- **ARREGLADO**: Problema de descargas que se quedaban en estado "Queued"

### ⚠️ Parcialmente Implementado
- UI básica de descargas en `HomeDownloads.kt`
- Configuraciones básicas en `DownloadSettings.kt`
- Integración con base de datos (`DownloadedSong`)

### ❌ Pendiente de Implementar
- Integración completa con Innertube
- UI completa de gestión de descargas
- WorkManager para robustez
- Migración de datos del cache
- Configuraciones avanzadas

---

## FASE 1: Integración con Innertube (Prioridad ALTA)


### 1.1 Extender Innertube Provider
- [x] **Archivo a modificar**: `providers/innertube/src/main/kotlin/com/rmusic/providers/innertube/Innertube.kt`
- [x] **Tarea**: Agregar método `downloadTrack()` que use el `HttpClient` global existente
- [x] **Implementación**: 
  ```kotlin
  suspend fun downloadTrack(trackId: String): Flow<DownloadState> {
      // Reusar lógica de resolución de URLs del PlayerService
      // Usar InnertubeDownloadProvider que extienda HttpDownloadProvider
  }
  ```

### 1.2 Crear InnertubeDownloadProvider
- [x] **Archivo nuevo**: `providers/innertube/src/main/kotlin/com/rmusic/providers/innertube/InnertubeDownloadProvider.kt`
- [x] **Herencia**: Extender `HttpDownloadProvider`
- [x] **Funcionalidad**: Resolver URLs de YouTube Music antes de descargar
- [x] **Integración**: Usar interceptores existentes y manejo de errores

### 1.3 Integrar con MusicDownloadService
- [x] **Archivo a modificar**: `app/src/main/kotlin/com/rmusic/android/service/MusicDownloadService.kt`
- [x] **Tarea**: Reemplazar HttpDownloadProvider genérico por InnertubeDownloadProvider
- [x] **Configuración**: Actualizar mapeo de providers en `onCreate()`

---

## FASE 2: UI Completa de Gestión (Prioridad ALTA)


### 2.1 Completar HomeDownloads.kt
- [ ] **Archivo a modificar**: `app/src/main/kotlin/com/rmusic/android/ui/screens/home/HomeDownloads.kt`
- [ ] **Funcionalidades pendientes**:
  - [ ] Mostrar progreso de descargas activas
  - [ ] Botones pausar/resumir/cancelar por descarga
  - [ ] Filtros por estado (activas, completadas, fallidas)
  - [ ] Búsqueda en descargas
  - [ ] Organización por artista/álbum

### 2.2 Nueva Pantalla de Gestión Avanzada
- [ ] **Archivo nuevo**: `app/src/main/kotlin/com/rmusic/android/ui/screens/downloads/DownloadManagementScreen.kt`
- [ ] **Navegación**: Agregar ruta en routing
- [ ] **Funcionalidades**:
  - [ ] Vista detallada de cada descarga
  - [ ] Gestión masiva (pausar todas, cancelar todas)
  - [ ] Estadísticas de uso de espacio
  - [ ] Limpieza de descargas fallidas

### 2.3 Mejorar DownloadSettings.kt
- [ ] **Archivo a modificar**: `app/src/main/kotlin/com/rmusic/android/ui/screens/settings/DownloadSettings.kt`
- [ ] **Implementar funciones comentadas**:
  - [ ] Implementar "Clear all downloads" funcional
  - [ ] Selector de carpeta de almacenamiento
  - [ ] Configuración de calidad de descarga
  - [ ] Límite de espacio de almacenamiento
  - [ ] Configuración solo Wi-Fi

---

## FASE 3: WorkManager y Robustez (Prioridad MEDIA)


### 3.1 Implementar WorkManager
- [x] **Archivo nuevo**: `app/src/main/kotlin/com/rmusic/android/workers/DownloadWorker.kt`
- [x] **Funcionalidad**: 
  - [x] Reintentos automáticos en fallos de red
  - [x] Condiciones de red (Wi-Fi only)
  - [x] Condiciones de batería
  - [x] Persistencia entre reinicios del dispositivo

### 3.2 Integrar con Sistema Existente
- [x] **Archivo a modificar**: `app/src/main/kotlin/com/rmusic/android/service/MusicDownloadService.kt`
- [x] **Tarea**: Coordinar entre Service y WorkManager

### 3.3 Mejorar Manejo de Errores
- [x] **Archivos a modificar**: 
  - `download/src/main/kotlin/com/rmusic/download/HttpDownloadProvider.kt`
  - `download/src/main/kotlin/com/rmusic/download/DownloadManager.kt`
- [x] **Mejoras**:
  - [x] Reintentos inteligentes según tipo de error
  - [x] Logging detallado para debugging
  - [x] Fallback a diferentes servidores/calidades

---

## FASE 4: Base de Datos y Persistencia (Prioridad MEDIA)

### 4.1 Entidad DownloadEntity
- [ ] **Archivo a modificar**: `app/src/main/kotlin/com/rmusic/android/Database.kt`
- [ ] **Implementar entidad**:
  ```kotlin
  @Entity(tableName = "downloads")
  data class DownloadEntity(
      @PrimaryKey val id: String,
      val trackId: String,
      val title: String,
      val artist: String?,
      val album: String?,
      val filePath: String,
      val state: DownloadState,
      val progress: Int,
      val totalBytes: Long,
      val downloadedBytes: Long,
      val createdAt: Long,
      val updatedAt: Long,
      val errorMessage: String?
  )
  ```

### 4.2 DAO y Repositorio
- [ ] **Archivo a modificar**: `app/src/main/kotlin/com/rmusic/android/Database.kt`
- [ ] **Implementar DAO**:
  - [ ] CRUD básico
  - [ ] Queries por estado
  - [ ] Estadísticas de almacenamiento
  - [ ] Limpieza de entradas obsoletas

### 4.3 Migración de Base de Datos
- [ ] **Archivo a modificar**: `app/src/main/kotlin/com/rmusic/android/Database.kt`
- [ ] **Incrementar versión de DB**
- [ ] **Crear migración**: Tabla downloads + migrar datos existentes

---

## FASE 5: Migración y Deprecación (Prioridad BAJA)


### 5.1 Migrar Cache Existente
- [ ] **Archivo nuevo**: `app/src/main/kotlin/com/rmusic/android/migration/CacheToDownloadMigration.kt`
- [ ] **Funcionalidad**:
  - [ ] Detectar archivos en cache interno
  - [ ] Mover a directorio de descargas
  - [ ] Registrar como completadas en DB
  - [ ] Limpiar cache interno

### 5.2 Deprecar PrecacheService
- [ ] **Archivo a modificar**: `app/src/main/kotlin/com/rmusic/android/service/PrecacheService.kt`
- [ ] **Estrategia**:
  - [ ] Marcar como @Deprecated
  - [ ] Migrar UI existente a sistema de descargas
  - [ ] Mantener compatibilidad temporal

### 5.3 Actualizar UI Referencias
- [ ] **Buscar y reemplazar**: Referencias a pre-cache por descargas
- [ ] **Archivos afectados**: Todos los componentes UI que usen cache
- [ ] **Pruebas**: Verificar que no se rompa funcionalidad existente

---

## Checklist de Verificación Final

### Funcionalidad Básica
- [ ] Descargar una canción desde cualquier pantalla
- [ ] Ver progreso en tiempo real
- [ ] Pausar descarga activa
- [ ] Resumir descarga pausada
- [ ] Cancelar descarga y limpiar archivo
- [ ] Reproducir canción descargada offline

### Robustez
- [ ] Descargas continúan tras reinicio de app
- [ ] Manejo correcto de errores de red
- [ ] Límites de espacio respetados
- [ ] Solo Wi-Fi funciona correctamente
- [ ] Reintentos automáticos funcionan

### UI/UX
- [ ] Navegación intuitiva entre pantallas
- [ ] Indicadores de progreso claros
- [ ] Mensajes de error informativos
- [ ] Gestión masiva funcional
- [ ] Búsqueda y filtros operativos

### Performance
- [ ] Descargas no bloquean UI
- [ ] Memoria utilizada eficientemente
- [ ] Base de datos responde rápido
- [ ] Notificaciones no son intrusivas

---

## Recursos y Referencias

### Archivos Clave Existentes
- `download/src/main/kotlin/com/rmusic/download/DownloadManager.kt`
- `download/src/main/kotlin/com/rmusic/download/HttpDownloadProvider.kt`
- `app/src/main/kotlin/com/rmusic/android/service/MusicDownloadService.kt`
- `app/src/main/kotlin/com/rmusic/android/ui/screens/settings/DownloadSettings.kt`

### Patrones a Seguir
- Usar `GlobalPreferencesHolder` para configuraciones
- Seguir patrones de UI existentes en `compose/`
- Usar `Room` para persistencia
- Seguir arquitectura modular del proyecto

### Testing
- Probar en diferentes condiciones de red
- Validar con canciones de diferentes duraciones
- Verificar en dispositivos con poco espacio
- Probar gestión de permisos en Android 11+

---

## Próximos Pasos Inmediatos

1. **Comenzar con FASE 1.1**: Extender Innertube Provider
2. **Crear branch**: `feature/download-system-completion`
3. **Setup**: Configurar entorno de desarrollo
4. **Revisar**: Código existente en módulo `download/`
5. **Documentar**: Progreso en este archivo
