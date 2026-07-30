# RMusic

Cliente de música multiplataforma (Android, iOS, Linux) desarrollado en **Flutter**, que reproduce contenido de Innertube y otras fuentes con soporte para letras sincronizadas, descargas offline y personalización de interfaz.

## Funcionalidades

- **Reproducción de Streaming:** Canciones, álbumes, artistas y playlists de YouTube Music.
- **Reproducción en Segundo Plano:** Control multimedia nativo con `audio_service` y `media_kit`.
- **Modo Offline & Descargas:** Gestión de biblioteca y persistencia local mediante base de datos SQLite (`drift`).
- **Letras Sincronizadas:** Integración con LrcLib y traducción de letras.
- **SponsorBlock:** Omisión automática de segmentos no musicales.
- **Temas Dinámicos:** Soporte para Material You (`dynamic_color`) y personalización visual.
- **Búsqueda Avanzada:** Sugerencias en tiempo real y filtrado de contenidos.

## Requisitos y Configuración

- **Flutter SDK:** 3.10+ (Dart SDK `^3.10.8`)
- **Plataformas:** Android, iOS, Linux

### Comandos principales

Instalar dependencias:
```bash
flutter pub get
```

Generar código (`drift`, `freezed`, `riverpod`):
```bash
dart run build_runner build --delete-conflicting-outputs
```

Ejecutar en desarrollo:
```bash
flutter run
```

Compilar versión Release para Android:
```bash
flutter build apk --release
```

## Estructura del Proyecto

```
lib/
├── core/          # Servicios de audio, tema y utilidades compartidas
├── data/          # Base de datos local (Drift) y repositorios
├── domain/        # Modelos de dominio y lógica de negocio
├── providers/     # Conectores a APIs externas (Intermusic, LrcLib, SponsorBlock, etc.)
└── presentation/  # UI (Pantallas, Widgets y gestores de estado Riverpod)
```

## Créditos

- **CryingHaru** – Mantenimiento de RMusic
- **ViMusic / ViTune** – Inspiración inicial de la interfaz de música

## Licencia

GPL-3.0. Ver [LICENSE](LICENSE).
