# RMusic

Una aplicación de música para Android que reúne lo mejor de varias fuentes públicas en un solo reproductor. RMusic te permite descubrir, reproducir y descargar canciones sin depender de una única plataforma, todo con una interfaz cuidada y personalizable.

## ¿Qué puedes hacer con RMusic?
- Buscar canciones, discos, artistas, listas y vídeos musicales desde diferentes catálogos (YouTube Music, Innertube, Piped, Kugou, entre otros).
- Escuchar en streaming o guardar música para disfrutar sin conexión cuando quieras.
- Mantener tus playlists sincronizadas y organizadas, tanto si las creas en RMusic como si las importas desde otras plataformas.
- Ver y editar letras, incluidas versiones sincronizadas para cantar al ritmo.
- Personalizar la experiencia con temas dinámicos, ajustes de audio finos y compatibilidad con Android Auto.

## Cómo funciona a grandes rasgos
- **Agregador de proveedores:** RMusic consulta varias fuentes públicas para que encuentres versiones, directos y rarezas que no aparecen en otros servicios. Tú solo ves un resultado unificado.
- **Reproductor versátil:** Utiliza ExoPlayer junto con MediaSession para integrarse en el sistema Android, mostrar controles multimedia y respetar tus preferencias de audio (normalización, saltos de silencio, etc.).
- **Modo sin conexión:** Puedes cachear canciones y álbumes completos. El gestor de descargas permite pausar, reanudar y priorizar elementos según tus necesidades.
- **Interfaz con Jetpack Compose:** La navegación está pensada para ser clara y rápida, con animaciones fluidas y compatibilidad con pantallas plegables o en el coche.

## Instalación rápida
1. Ve a la sección de _Releases_ del repositorio y descarga el último APK.
2. Copia el archivo a tu dispositivo Android y, si es necesario, permite la instalación desde orígenes desconocidos.
3. Abre la app, inicia sesión en tu cuenta preferida (si procede) y empieza a explorar.

## Guía para desarrolladores
- **Requisitos:** Android Studio Ladybug o superior, JDK 22, Kotlin 2.1.20.
- **Compilación:**
	```powershell
	./gradlew assembleDebug
	```
- **Calidad de código:** Ejecuta `./gradlew detekt` antes de abrir un pull request para validar las reglas de estilo y de Jetpack Compose.
- **Arquitectura modular:**
	- `app/` contiene la app principal y el servicio de reproducción.
	- `providers/` incluye los conectores individuales a cada servicio externo.
	- `core/` alberga los modelos de datos compartidos, componentes de UI y utilidades de Material.
	- `compose/` ofrece módulos auxiliares para navegación y persistencia de estado.
	- `download/` gestiona el sistema de descargas con soporte de pausa y reanudación.

## Créditos y agradecimientos
- **CryingHaru** – Soporte de RMusic
- **Huizengek** – Autor de Vitune basado en vimusic
- **vfsfitvnm** – Autor de vimusic  en la cual esta basada el proyecto Vitune
RMusic se construye sobre los cimientos de ViTune y evoluciona gracias a la comunidad. Si quieres colaborar, revisa los issues abiertos, consulta las instrucciones de contribución y comparte tus ideas.

## Licencia
Este repositorio se distribuye bajo la licencia incluida en `LICENSE`. Revisa el archivo para conocer los detalles de uso y redistribución.

