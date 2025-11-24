# RMusic

Cliente de música para Android que reproduce contenido de YouTube Music y otras fuentes. Permite streaming, descargas offline y gestión de playlists.

## Funcionalidades

- Reproducción de canciones y vídeos de YouTube Music
- Reproducción de archivos locales
- Reproducción en segundo plano
- Caché de canciones para uso offline
- Búsqueda de canciones, álbumes, artistas y playlists
- Exploración por género/estado de ánimo
- Importación de playlists de YouTube
- Letras sincronizadas
- Gestión de playlists locales y en la nube
- Temas dinámicos (Material You)
- Normalización de audio
- Soporte para Android Auto

## Instalación

Descarga el APK desde [Releases](../../releases) e instálalo en tu dispositivo (Android 7.0+).

## Desarrollo

**Requisitos:**
- Android Studio Ladybug+
- JDK 22
- Kotlin 2.1.20

**Compilar:**
```bash
./gradlew assembleDebug
```

**Lint:**
```bash
./gradlew detekt
```

## Estructura del proyecto

| Módulo | Descripción |
|--------|-------------|
| `app/` | App principal y servicio de reproducción |
| `providers/` | Conectores a servicios externos (Intermusic, Kugou, LrcLib, etc.) |
| `core/` | Modelos de datos y componentes UI compartidos |
| `compose/` | Utilidades de navegación y persistencia |
| `download/` | Sistema de descargas |

## Créditos

- **vfsfitvnm** – Autor original de ViMusic
- **Huizengek** – Autor de ViTune (fork de ViMusic)
- **sigma67** – Creador de [ytmusicapi](https://github.com/sigma67/ytmusicapi)
- **ReVanced** – Equipo de [ReVanced](https://github.com/ReVanced)
- **CryingHaru** – Mantenimiento de RMusic

## Licencia

GPL-3.0. Ver [LICENSE](LICENSE).

