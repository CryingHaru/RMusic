# Plan de Implementación del Sistema de Descargas

Aquí se detallan las funcionalidades que faltan para completar el sistema de descargas en RMusic.

## 1. Servicio de Descarga en Segundo Plano (`MusicDownloadService`)

-   [x] **Crear `MusicDownloadService`**: Un `Service` de Android que se ejecute en segundo plano para gestionar el ciclo de vida de las descargas.
-   [ ] **Gestionar Cola de Descargas**: Implementar una cola para procesar las descargas una por una.
-   [ ] **Control de Acciones**: Añadir acciones (iniciar, pausar, cancelar) que se puedan invocar desde la UI.
-   [ ] **Manejo de Red**: Pausar descargas si se pierde la conexión a Internet y reanudarlas cuando vuelva.
-   [ ] **Integración con WorkManager**: (Opcional) Evaluar si WorkManager es una mejor alternativa que un Service para la gestión de tareas en segundo plano.

## 2. Gestor de Notificaciones (`DownloadNotifier`)

-   [ ] **Notificación de Progreso**: Mostrar una notificación persistente que indique el progreso de la descarga actual.
-   [ ] **Notificación de Finalización**: Notificar al usuario cuando una descarga se complete con éxito.
-   [ ] **Notificación de Error**: Informar al usuario si una descarga falla, con la opción de reintentar.
-   [ ] **Agrupación de Notificaciones**: Agrupar las notificaciones de descarga para no saturar al usuario.

## 3. Integración con la Interfaz de Usuario (UI)

-   [ ] **ViewModel (`DownloadViewModel`)**: Crear un ViewModel para exponer el estado de las descargas a la UI.
-   [ ] **Pantalla de Descargas (`DownloadsScreen`)**: Un Composable que muestre la lista de descargas en curso y completadas.
-   [ ] **Interacciones del Usuario**: Permitir que el usuario inicie descargas desde los menús de las canciones/álbumes.
-   [ ] **Estado Visual**: Mostrar indicadores de progreso, botones de pausa/reanudación y la opción de eliminar descargas.

## 4. Persistencia de Datos (Base de Datos Room)

-   [ ] **Entidad de Descarga (`DownloadItem`)**: Crear una entidad de Room para almacenar la información de cada descarga (ID de la canción, URL, estado, progreso, ruta del archivo).
-   [ ] **DAO (`DownloadDao`)**: Implementar un Data Access Object para las operaciones CRUD (Crear, Leer, Actualizar, Eliminar) de las descargas.
-   [ ] **Integrar en `AppDatabase`**: Añadir la nueva entidad y el DAO a la base de datos principal de la aplicación.
-   [ ] **Migración de la Base de Datos**: Crear una nueva migración para la base de datos.

## 5. Gestión de Almacenamiento

-   [ ] **Preferencia de Ubicación**: Añadir una opción en la configuración para que el usuario elija dónde guardar los archivos descargados (almacenamiento interno o tarjeta SD).
-   [ ] **Cálculo de Espacio**: Mostrar el espacio utilizado por las descargas y el espacio disponible en el dispositivo.
-   [ ] **Limpieza de Cache**: Implementar una función para limpiar descargas fallidas o incompletas.

## 6. Inyección de Dependencias (Hilt)

-   [ ] **Módulo de Hilt (`DownloadModule`)**: Crear un módulo de Hilt para proveer las dependencias del sistema de descargas (Service, Notifier, Dao, etc.).
-   [ ] **Anotar Clases**: Anotar las nuevas clases (`ViewModel`, `Service`) con `@HiltViewModel` y `@AndroidEntryPoint` para la inyección de dependencias.

## 7. Actualización de Dependencias

-   [ ] **Añadir WorkManager**: Si se decide usar WorkManager, añadir la dependencia en `download/build.gradle.kts`.
-   [ ] **Añadir Hilt**: Asegurarse de que las dependencias de Hilt estén disponibles en el módulo `download`.
