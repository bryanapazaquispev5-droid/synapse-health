$ErrorActionPreference = 'Stop'
$apiBaseUrl = 'https://tcpq1i1oxl.execute-api.us-east-2.amazonaws.com'
$scriptPath = Join-Path $PSScriptRoot 'aws_preflight_readiness.js'

try {
    $k6 = Get-Command k6 -ErrorAction SilentlyContinue
    if (-not $k6) { throw 'No se encontró k6 en PATH. Instálalo para ejecutar la prueba.' }
    & k6 version | Out-Null
    if ($LASTEXITCODE -ne 0) { throw 'k6 no pudo iniciar.' }

    Write-Host ''
    Write-Host 'SYNAPSE HEALTH · PRUEBA PREVIA AUTOMÁTICA EN AWS' -ForegroundColor Cyan
    Write-Host 'Comprueba /health y /api/v1/health y sube gradualmente hasta 4 solicitudes/s.'
    Write-Host 'Es de solo lectura; no pide credenciales ni modifica usuarios o datos.' -ForegroundColor Gray
    Write-Host 'Se detiene en cuanto detecta HTTP 429, 5xx o una respuesta de salud inválida.' -ForegroundColor Yellow

    $env:BASE_URL = $apiBaseUrl
    try {
        & k6 run $scriptPath
        $k6Exit = $LASTEXITCODE
    } finally {
        Remove-Item Env:BASE_URL -ErrorAction SilentlyContinue
    }

    if ($k6Exit -ne 0) {
        Write-Host 'Resultado: revisar el informe de k6; la prueba falló o se detuvo por seguridad.' -ForegroundColor Red
    } else {
        Write-Host 'Resultado: prueba completada; revisa el informe para confirmar los umbrales.' -ForegroundColor Green
    }
} catch {
    Write-Host "ERROR: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

Write-Host ''
Read-Host 'Presiona Enter para cerrar'
