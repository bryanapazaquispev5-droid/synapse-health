# ==============================================================================
# SYNAPSE HEALTH - PRUEBA DE CARGA INTERACTIVA DE MÁXIMA VELOCIDAD
# ==============================================================================
$ErrorActionPreference = 'Stop'
$repoRoot = [System.IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..\..'))
Set-Location $repoRoot

Write-Host ""
Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host "   SYNAPSE HEALTH - PRUEBA DE CARGA ULTRARRÁPIDA DYNAMODB " -ForegroundColor Yellow
Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host ""

$accountsInput = Read-Host "1. Ingrese la cantidad meta de cuentas (ej. 1000, 5000, 500000)"
if (-not $accountsInput -or -not ($accountsInput -match '^\d+$')) {
    $accountsInput = "1000"
}
$totalAccounts = [int64]$accountsInput

$secondsInput = Read-Host "2. Ingrese el tiempo límite en segundos (ej. 5, 10, 20)"
if (-not $secondsInput -or -not ($secondsInput -match '^\d+$') -or [int]$secondsInput -le 0) {
    $secondsInput = "10"
}
$targetSeconds = [int]$secondsInput

# Optimización automática de hilos (VUs) para máxima velocidad
if ($totalAccounts -le 50) {
    $vus = [int]$totalAccounts
} elseif ($totalAccounts -le 500) {
    $vus = [Math]::Min([int]$totalAccounts, 250)
} elseif ($totalAccounts -le 2000) {
    $vus = 350
} else {
    $vus = 450
}

$runId = "prueba-" + (Get-Date -Format "HHmmss")

Write-Host ""
Write-Host "[MODO MÁXIMA VELOCIDAD]" -ForegroundColor Green
Write-Host "  - Cuentas meta:      $totalAccounts"
Write-Host "  - Tiempo límite:     $targetSeconds s (se frena en exactamente $targetSeconds s si no acaba antes)"
Write-Host "  - Hilos paralelos:   $vus VUs simultáneos a máxima potencia"
Write-Host "  - ID de prueba:      $runId"
Write-Host ""
Write-Host "Iniciando ráfaga k6 ultrarrápida contra AWS..." -ForegroundColor Cyan

$k6Script = Join-Path $repoRoot 'test\load\dynamo_burst_signup.js'
& k6 run -e ACCOUNTS=$totalAccounts -e DURATION=$targetSeconds -e VUS=$vus -e RUN_ID=$runId $k6Script

Write-Host ""
Write-Host "Consultando registros totales reales en AWS DynamoDB..." -ForegroundColor Yellow
& aws dynamodb scan --table-name synapse-health-backend-user-profiles --select COUNT --region us-east-2

Write-Host ""
$deleteChoice = Read-Host "Deseas eliminar las cuentas creadas en esta prueba ($runId) de AWS? (S/N) [por defecto: S]"
if ($deleteChoice -eq '' -or $deleteChoice -match '^[sSyY]') {
    Write-Host "Eliminando cuentas creadas ($runId)..." -ForegroundColor Yellow
    Push-Location (Join-Path $repoRoot 'backend')
    try {
        & node scripts/delete-load-users.mjs $runId
    } finally {
        Pop-Location
    }
    Write-Host ""
    Write-Host "Verificando conteo final en AWS..." -ForegroundColor Cyan
    & aws dynamodb scan --table-name synapse-health-backend-user-profiles --select COUNT --region us-east-2
} else {
    Write-Host "Las cuentas se conservaron en DynamoDB. Para eliminarlas luego ejecuta:" -ForegroundColor Gray
    Write-Host "node backend/scripts/delete-load-users.mjs $runId" -ForegroundColor Cyan
}

Write-Host ""
Write-Host "Prueba finalizada con éxito." -ForegroundColor Green
