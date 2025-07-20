# Script para instalar Android SDK y configurar el proyecto RMusic
param(
    [string]$SdkPath = "C:\Android\Sdk"
)

Write-Host "=== Configurando Android SDK para RMusic ===" -ForegroundColor Green

# Crear directorio para Android SDK
if (!(Test-Path $SdkPath)) {
    Write-Host "Creando directorio SDK: $SdkPath" -ForegroundColor Yellow
    New-Item -ItemType Directory -Path $SdkPath -Force | Out-Null
}

# Descargar Command Line Tools con progreso y validación
$ToolsUrl = "https://dl.google.com/android/repository/commandlinetools-win-11076708_latest.zip"
$ToolsZip = "$env:TEMP\android-commandlinetools.zip"
$ToolsDir = "$SdkPath\cmdline-tools"

# Verificar si ya existe y es válido
$SkipDownload = $false
if (Test-Path $ToolsZip) {
    try {
        $ExistingSize = (Get-Item $ToolsZip).Length
        if ($ExistingSize -gt 100MB) {
            Write-Host "Archivo existente encontrado, verificando integridad..." -ForegroundColor Yellow
            Add-Type -AssemblyName System.IO.Compression.FileSystem
            try {
                [System.IO.Compression.ZipFile]::OpenRead($ToolsZip).Dispose()
                $SkipDownload = $true
                Write-Host "Archivo válido encontrado, saltando descarga" -ForegroundColor Green
            } catch {
                Write-Host "Archivo corrupto, redownloading..." -ForegroundColor Yellow
                Remove-Item $ToolsZip -Force
            }
        }
    } catch {
        Remove-Item $ToolsZip -Force -ErrorAction SilentlyContinue
    }
}

if (-not $SkipDownload) {
    Write-Host "Descargando Android Command Line Tools..." -ForegroundColor Yellow
    try {
        # Usar BITS para descarga más rápida y confiable
        if (Get-Command Start-BitsTransfer -ErrorAction SilentlyContinue) {
            Write-Host "Usando BITS para descarga optimizada..." -ForegroundColor Cyan
            Start-BitsTransfer -Source $ToolsUrl -Destination $ToolsZip -DisplayName "Android Command Line Tools" -Priority High
        } else {
            # Fallback con WebRequest optimizado
            $WebClient = New-Object System.Net.WebClient
            $WebClient.Headers.Add("User-Agent", "PowerShell-AndroidSDK-Setup")
            
            # Evento de progreso
            Register-ObjectEvent -InputObject $WebClient -EventName DownloadProgressChanged -Action {
                $ProgressPercentage = $Event.SourceEventArgs.ProgressPercentage
                $BytesReceived = $Event.SourceEventArgs.BytesReceived
                $TotalBytes = $Event.SourceEventArgs.TotalBytesToReceive
                
                if ($TotalBytes -gt 0) {
                    $MBReceived = [math]::Round($BytesReceived / 1MB, 2)
                    $MBTotal = [math]::Round($TotalBytes / 1MB, 2)
                    Write-Progress -Activity "Descargando Command Line Tools" -Status "$MBReceived MB de $MBTotal MB" -PercentComplete $ProgressPercentage
                }
            } | Out-Null
            
            $WebClient.DownloadFile($ToolsUrl, $ToolsZip)
            $WebClient.Dispose()
            Write-Progress -Activity "Descargando Command Line Tools" -Completed
        }
        Write-Host "Descarga completada" -ForegroundColor Green
    } catch {
        Write-Error "Error descargando Command Line Tools: $_"
        exit 1
    }
}

# Extraer Command Line Tools
Write-Host "Extrayendo Command Line Tools..." -ForegroundColor Yellow
if (!(Test-Path $ToolsDir)) {
    New-Item -ItemType Directory -Path $ToolsDir -Force | Out-Null
}

try {
    # Verificar si ya está extraído
    $LatestDir = "$ToolsDir\latest"
    if (Test-Path "$LatestDir\bin\sdkmanager.bat") {
        Write-Host "Command Line Tools ya están extraídos" -ForegroundColor Green
    } else {
        Add-Type -AssemblyName System.IO.Compression.FileSystem
        [System.IO.Compression.ZipFile]::ExtractToDirectory($ToolsZip, $ToolsDir)
        
        # Mover contenido de cmdline-tools/cmdline-tools a cmdline-tools/latest
        if (Test-Path "$ToolsDir\cmdline-tools") {
            if (Test-Path $LatestDir) {
                Remove-Item $LatestDir -Recurse -Force
            }
            Move-Item "$ToolsDir\cmdline-tools" $LatestDir -Force
        }
        Write-Host "Extracción completada" -ForegroundColor Green
    }
    
    # Limpiar archivo zip después de extracción exitosa
    Remove-Item $ToolsZip -Force -ErrorAction SilentlyContinue
} catch {
    Write-Error "Error extrayendo Command Line Tools: $_"
    exit 1
}

# Configurar variables de entorno para esta sesión
$env:ANDROID_HOME = $SdkPath
$env:ANDROID_SDK_ROOT = $SdkPath
$SdkManagerPath = "$ToolsDir\latest\bin\sdkmanager.bat"

# Verificar que sdkmanager existe
if (!(Test-Path $SdkManagerPath)) {
    Write-Error "No se encontró sdkmanager en: $SdkManagerPath"
    exit 1
}

Write-Host "Instalando componentes del SDK..." -ForegroundColor Yellow

# Instalar componentes necesarios para el proyecto en lotes para mayor eficiencia
$Components = @(
    "platform-tools",
    "platforms;android-36",
    "platforms;android-35", 
    "platforms;android-34",
    "build-tools;35.0.0",
    "build-tools;34.0.0"
)

# Verificar componentes ya instalados
Write-Host "Verificando componentes ya instalados..." -ForegroundColor Cyan
$InstalledComponents = @()
try {
    $ListOutput = & $SdkManagerPath --list_installed 2>$null
    $InstalledComponents = $ListOutput | Where-Object { $_ -match "^\s*\S+" } | ForEach-Object { ($_ -split '\s+')[0] }
} catch {
    Write-Host "No se pudo verificar componentes instalados, instalando todos..." -ForegroundColor Yellow
}

$ComponentsToInstall = $Components | Where-Object { $_ -notin $InstalledComponents }

if ($ComponentsToInstall.Count -eq 0) {
    Write-Host "Todos los componentes ya están instalados" -ForegroundColor Green
} else {
    Write-Host "Instalando $($ComponentsToInstall.Count) componentes..." -ForegroundColor Yellow
    
    # Instalar en lotes de 3 para mejor rendimiento
    $BatchSize = 3
    for ($i = 0; $i -lt $ComponentsToInstall.Count; $i += $BatchSize) {
        $Batch = $ComponentsToInstall[$i..([math]::Min($i + $BatchSize - 1, $ComponentsToInstall.Count - 1))]
        
        Write-Host "Instalando lote: $($Batch -join ', ')" -ForegroundColor Cyan
        try {
            $Arguments = $Batch + @("--verbose")
            $Process = Start-Process -FilePath $SdkManagerPath -ArgumentList $Arguments -NoNewWindow -PassThru -Wait
            
            if ($Process.ExitCode -ne 0) {
                Write-Warning "Posible error en el lote (código: $($Process.ExitCode))"
            }
        } catch {
            Write-Warning "Error instalando lote: $_"
        }
    }
}

# Crear archivo local.properties
$LocalPropertiesPath = ".\local.properties"
$LocalPropertiesContent = @"
# Configuración automática del Android SDK
sdk.dir=$($SdkPath -replace '\\', '/')
"@

Write-Host "Creando local.properties..." -ForegroundColor Yellow
Set-Content -Path $LocalPropertiesPath -Value $LocalPropertiesContent -Encoding UTF8

# Configurar variables de entorno del sistema (persistente)
Write-Host "Configurando variables de entorno del sistema..." -ForegroundColor Yellow
try {
    [Environment]::SetEnvironmentVariable("ANDROID_HOME", $SdkPath, "User")
    [Environment]::SetEnvironmentVariable("ANDROID_SDK_ROOT", $SdkPath, "User")
    
    # Agregar a PATH
    $CurrentPath = [Environment]::GetEnvironmentVariable("Path", "User")
    $NewPathItems = @(
        "$SdkPath\platform-tools",
        "$SdkPath\cmdline-tools\latest\bin"
    )
    
    foreach ($Item in $NewPathItems) {
        if ($CurrentPath -notlike "*$Item*") {
            $CurrentPath += ";$Item"
        }
    }
    [Environment]::SetEnvironmentVariable("Path", $CurrentPath, "User")
    
    Write-Host "Variables de entorno configuradas correctamente" -ForegroundColor Green
} catch {
    Write-Warning "Error configurando variables de entorno: $_"
}

Write-Host "=== Configuración completada ===" -ForegroundColor Green
Write-Host "Android SDK instalado en: $SdkPath" -ForegroundColor White
Write-Host "Archivo local.properties creado" -ForegroundColor White
Write-Host ""
Write-Host "Para aplicar las variables de entorno, cierra y abre de nuevo PowerShell" -ForegroundColor Yellow
Write-Host "Luego ejecuta: .\gradlew build" -ForegroundColor Yellow
