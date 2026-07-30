#!/usr/bin/env bash
# Script de ejecución de Flutter con filtro de ruido, colores y preservación de logs del navegador web

exec python3 - "$@" << 'EOF'
import sys, re, subprocess

LOG_FILE = 'errors.log'

with open(LOG_FILE, 'w', encoding='utf-8') as f:
    f.write("=== LOG DE ERRORES (R2ve) ===\n\n")

error_log = open(LOG_FILE, 'a', encoding='utf-8')

RED = '\033[1;31m'
YELLOW = '\033[1;33m'
GREEN = '\033[1;32m'
CYAN = '\033[1;36m'
MAGENTA = '\033[1;35m'
GRAY = '\033[90m'
RESET = '\033[0m'

# Detección prioritaria de logs del extractor de streams del navegador
STREAM_RE = re.compile(
    r'(\[StreamExtractor\]|StreamDetectorChannel|\[INFO:CONSOLE\]|console\.log|StreamExtractor)',
    re.IGNORECASE
)

# Filtro de ruido nativo de Android (excluyendo logs del navegador StreamExtractor)
NOISE_RE = re.compile(
    r'(aw_browser_terminator|ImeBackDispatcher|libOpenSLES|chromium|BLASTBufferQueue|OpenGLRenderer|FBI|MediaCodec|CCodec|AudioStreamTrack|PlayerBase|androidtc|ReflectedParamUpdater|ColorUtils|PipelineWatcher|RefBase|GPUAUX|Surface|nativeloader|CompatibilityChangeReporter|CameraManagerGlobal|TranClassInfo|libc|libMEOW|libEGL|PlatformViews|BufferQueueConsumer|config_debug|FlutterJNI|AudioCapabilities|VideoCapabilities|mali|ApkAssets|concurrent mark compact|GraphicBuffer|AHardwareBuffer|gralloc|TranChoreographer|Monitor::Inflate|variations_seed_loader|Permissions-Policy|CCodecConfig|AudioStreamBuilder|avc:\s*denied|RenderThread|dmabuf|untrusted_app|Codec2Client|CCodecBuffer|AudioTrack|BufferPoolAccessor|AAudioStream|AAudio|SensorManager|ScrollIdentify|GED\s|cr_media|cr_Platform|TranStreamConfiguration|Dawn|Codec2-OutputBufferQueue|Bloqueo ventana/popup emergente|Bitmap|cr_JniAndroid|WindowOnBackDispatcher)',
    re.IGNORECASE
)

ERR_RE = re.compile(r'\b(error|exception|failed|syntaxerror|fatal|uncaught)\b|^E/', re.IGNORECASE)
BENIGN_WEB_ERR_RE = re.compile(r'Web Resource Error:\s*net::(ERR_FAILED|ERR_BLOCKED_BY_CLIENT|ERR_BLOCKED_BY_RESPONSE|ERR_BLOCKED_BY_ORB|ERR_NAME_NOT_RESOLVED|ERR_CONNECTION_REFUSED|ERR_CONNECTION_RESET)', re.IGNORECASE)

extra_args = sys.argv[1:]
if not any('target-platform' in arg for arg in extra_args):
    extra_args += ['-Ptarget-platform=android-arm']

cmd = ['flutter', 'run'] + extra_args
proc = subprocess.Popen(cmd, stdout=subprocess.PIPE, stderr=subprocess.STDOUT, text=True, bufsize=1)

in_exception_block = False

try:
    for line in proc.stdout:
        line_str = line.rstrip('\n')
        lower = line_str.lower()

        # Multi-line Flutter exception capturing
        if '══╡ EXCEPTION CAUGHT BY' in line_str or 'FlutterError' in line_str:
            in_exception_block = True

        if in_exception_block:
            print(f'{RED}{line_str}{RESET}')
            error_log.write(line_str + '\n')
            error_log.flush()
            if line_str.startswith('════════════════════════════════'):
                in_exception_block = False
            sys.stdout.flush()
            continue

        # Prioridad 1: Si es un log del extractor de streams del navegador
        if STREAM_RE.search(line_str):
            if ERR_RE.search(line_str) and not BENIGN_WEB_ERR_RE.search(line_str):
                print(f'{RED}{line_str}{RESET}')
                error_log.write(line_str + '\n')
                error_log.flush()
            else:
                print(f'{CYAN}{line_str}{RESET}')
            sys.stdout.flush()
            continue

        # Prioridad 2: Filtrar ruido nativo del sistema
        if NOISE_RE.search(line_str):
            continue

        # Prioridad 3: Coloreado general de la consola
        if BENIGN_WEB_ERR_RE.search(line_str):
            print(f'{GRAY}{line_str}{RESET}')
        elif ERR_RE.search(line_str):
            print(f'{RED}{line_str}{RESET}')
            error_log.write(line_str + '\n')
            error_log.flush()
        elif any(k in lower for k in ['warning', 'w/', 'warn', 'deprecated']):
            print(f'{YELLOW}{line_str}{RESET}')
        elif any(k in lower for k in ['flutter:', 'detected', 'adguard', 'stream', 'p2p', 'playstream']):
            print(f'{CYAN}{line_str}{RESET}')
        elif any(k in lower for k in ['reloading', 'reloaded', 'restarting', 'restarted', 'syncing', 'success', 'ready', 'performing']):
            print(f'{GREEN}{line_str}{RESET}')
        elif 'd/' in lower or 'i/' in lower:
            print(f'{GRAY}{line_str}{RESET}')
        else:
            print(line_str)

        sys.stdout.flush()
except KeyboardInterrupt:
    pass
finally:
    error_log.close()
    try:
        proc.wait(timeout=1)
    except Exception:
        proc.terminate()
EOF
