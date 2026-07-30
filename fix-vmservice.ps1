[CmdletBinding()]
param(
    [string]$DeviceId,
    [ValidateSet('enable', 'reset', 'status')]
    [string]$Mode = 'enable'
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

if (-not (Get-Command adb -ErrorAction SilentlyContinue)) {
    throw 'No se encontró adb en PATH. Abre una terminal donde adb funcione o agrega platform-tools al PATH.'
}

$tags = @('flutter', 'FlutterEngine', 'FlutterActivity')

function Get-ConnectedDevices {
    return @(adb devices | Select-Object -Skip 1 | Where-Object { $_ -match '\sdevice$' } | ForEach-Object { ($_ -split '\s+')[0] })
}

function Resolve-DeviceId {
    param([string]$Preferred)

    if ($Preferred) { return $Preferred }

    $devices = @(Get-ConnectedDevices)
    if (-not $devices -or $devices.Length -eq 0) {
        throw 'No hay dispositivos ADB conectados. Conecta uno y vuelve a intentar.'
    }
    if ($devices.Count -gt 1) {
        Write-Host "Hay múltiples dispositivos conectados ($($devices -join ', ')). Seleccionando automáticamente el primero: $($devices[0])" -ForegroundColor Yellow
    }

    return $devices[0]
}

function Set-Tags {
    param(
        [string]$Serial,
        [string]$Value
    )
    $tags | ForEach-Object {
        adb -s $Serial shell setprop "log.tag.$_" $Value | Out-Null
    }
}

function Print-Status {
    param([string]$Serial)

    Write-Host "`nEstado actual de tags en ${Serial}:" -ForegroundColor Cyan
    $tags | ForEach-Object {
        $val = adb -s $Serial shell getprop "log.tag.$_"
        Write-Host "$_ : $val"
    }
    Write-Host ''
}

$serial = Resolve-DeviceId -Preferred $DeviceId

switch ($Mode) {
    'enable' {
        Set-Tags -Serial $serial -Value 'I'
        Write-Host "VM Service logs habilitados para $serial" -ForegroundColor Green
        Print-Status -Serial $serial
        Write-Host 'Ahora ya puedes correr flutter run normalmente.' -ForegroundColor Green
    }
    'reset' {
        Set-Tags -Serial $serial -Value 'W'
        Write-Host "VM Service logs ajustados a modo conservador (W) para $serial" -ForegroundColor Yellow
        Print-Status -Serial $serial
    }
    'status' {
        Print-Status -Serial $serial
    }
}

