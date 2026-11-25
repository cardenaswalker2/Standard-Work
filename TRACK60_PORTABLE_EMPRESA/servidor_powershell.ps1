# Servidor HTTP nativo en PowerShell sin requerir privilegios de Administrador
# Compatible con restricciones de TI de Grupo Darnel

$port = 8080
$appDir = Join-Path $PSScriptRoot "app_web"

if (-not (Test-Path $appDir)) {
    Write-Host "[ERROR] No se encontro la carpeta app_web en $appDir" -ForegroundColor Red
    Pause
    Exit
}

# Obtener IPs locales activas
$ips = [System.Net.Dns]::GetHostAddresses([System.Net.Dns]::GetHostName()) | Where-Object { $_.AddressFamily -eq 'InterNetwork' -and $_.IPAddressToString -notlike '127.*' }
$activeIp = if ($ips) { $ips[0].IPAddressToString } else { "localhost" }

Write-Host "=========================================================================" -ForegroundColor Cyan
Write-Host "       TRACK60 - SERVIDOR DE CONTINGENCIA NATIVO (WINDOWS)               " -ForegroundColor Yellow
Write-Host "                             GRUPO DARNEL                                " -ForegroundColor White
Write-Host "=========================================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host " [VIVO] Servidor HTTP escuchando en el puerto: $port" -ForegroundColor Green
Write-Host ""
Write-Host " >> EN ESTE PORTATIL:           http://localhost:$port" -ForegroundColor White
Write-Host " >> PARA EL CELULAR DEL JEFE:   http://${activeIp}:$port" -ForegroundColor Green -BackgroundColor Black
Write-Host ""
Write-Host "  Paso 1: Conecta este computador y el celular del jefe a la misma red (Zona Wi-Fi)." -ForegroundColor Gray
Write-Host "  Paso 2: Comparte el enlace de arriba con tu jefe." -ForegroundColor Gray
Write-Host ""
Write-Host "  Presiona CTRL + C en esta ventana cuando desees detener el servidor." -ForegroundColor DarkGray
Write-Host "=========================================================================" -ForegroundColor Cyan

# Copiar enlace al portapapeles
try {
    Set-Clipboard -Value "http://${activeIp}:$port"
    Write-Host " [*] Enlace copiado automaticamente al portapapeles listo para enviar!" -ForegroundColor Cyan
} catch {}

# Abrir navegador local mostrando la pantalla interactiva con QR de conexion
Start-Process "http://localhost:$port/conectar.html?ip=$activeIp&port=$port"

# Intentar usar Python si existe silenciosamente
try {
    $pythonCmd = Get-Command python -ErrorAction SilentlyContinue
    if ($pythonCmd) {
        Set-Location $appDir
        python -m http.server $port
        Exit
    }
} catch {}

# Fallback HttpListener en PowerShell
$listener = New-Object System.Net.HttpListener
$listener.Prefixes.Add("http://*:$port/")
try {
    $listener.Start()
} catch {
    $listener = New-Object System.Net.HttpListener
    $listener.Prefixes.Add("http://localhost:$port/")
    $listener.Start()
}

while ($listener.IsListening) {
    $context = $listener.GetContext()
    $request = $context.Request
    $response = $context.Response

    $urlPath = $request.Url.LocalPath.TrimStart('/')
    if ([string]::IsNullOrEmpty($urlPath)) { $urlPath = "index.html" }
    $filePath = Join-Path $appDir $urlPath

    if (-not (Test-Path $filePath)) {
        $filePath = Join-Path $appDir "index.html"
    }

    $ext = [System.IO.Path]::GetExtension($filePath).ToLower()
    $mime = switch ($ext) {
        ".html" { "text/html; charset=utf-8" }
        ".js"   { "application/javascript" }
        ".json" { "application/json" }
        ".wasm" { "application/wasm" }
        ".css"  { "text/css" }
        ".png"  { "image/png" }
        ".jpg"  { "image/jpeg" }
        ".jpeg" { "image/jpeg" }
        ".ico"  { "image/x-icon" }
        ".svg"  { "image/svg+xml" }
        default { "application/octet-stream" }
    }

    try {
        $bytes = [System.IO.File]::ReadAllBytes($filePath)
        $response.ContentType = $mime
        $response.ContentLength64 = $bytes.Length
        $response.AddHeader("Cache-Control", "no-cache")
        $response.AddHeader("Access-Control-Allow-Origin", "*")
        $response.OutputStream.Write($bytes, 0, $bytes.Length)
        $response.Close()
    } catch {
        $response.StatusCode = 500
        $response.Close()
    }
}

