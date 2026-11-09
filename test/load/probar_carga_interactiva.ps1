# ==============================================================================
# SYNAPSE HEALTH - PRUEBA DE CARGA INTERACTIVA
# ==============================================================================
$ErrorActionPreference = 'Stop'
$repoRoot = [System.IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..\..'))
Set-Location $repoRoot

Write-Host ""
Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host "   SYNAPSE HEALTH - PRUEBA DE CARGA INTERACTIVA DYNAMODB   " -ForegroundColor Yellow
Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host ""

$accountsInput = Read-Host "1. Ingrese la cantidad de cuentas a crear (ej. 100, 1000, 5000)"
if (-not $accountsInput -or -not ($accountsInput -match '^\d+$')) {
    $accountsInput = "500"
}
$totalAccounts = [int]$accountsInput

$secondsInput = Read-Host "2. Ingrese el tiempo deseado en segundos (ej. 5, 10, 30)"
if (-not $secondsInput -or -not ($secondsInput -match '^\d+$') -or [int]$secondsInput -le 0) {
    $secondsInput = "10"
}
$targetSeconds = [int]$secondsInput

$targetRps = [Math]::Ceiling($totalAccounts / $targetSeconds)
$vus = [Math]::Min($totalAccounts, [Math]::Min(350, [Math]::Max(1, [int]($targetRps * 1.5))))
$runId = "prueba-" + (Get-Date -Format "HHmmss")

Write-Host ""
Write-Host "[CONFIGURACION]" -ForegroundColor Green
Write-Host "  - Total cuentas:  $totalAccounts"
Write-Host "  - Tiempo meta:    $targetSeconds s (aprox. $targetRps req/s)"
Write-Host "  - Hilos (VUs):    $vus"
Write-Host "  - ID de prueba:   $runId"
Write-Host ""
Write-Host "Iniciando rafaga k6 contra AWS..." -ForegroundColor Cyan

$k6Script = Join-Path $repoRoot 'test\load\dynamo_burst_signup.js'
& k6 run -e ACCOUNTS=$totalAccounts -e EXECUTOR=shared-iterations -e VUS=$vus -e RUN_ID=$runId $k6Script

Write-Host ""
Write-Host "Consultando registros reales en AWS DynamoDB..." -ForegroundColor Yellow
& aws dynamodb scan --table-name synapse-health-backend-user-profiles --select COUNT --region us-east-2

Write-Host ""
$deleteChoice = Read-Host "Deseas eliminar estas $totalAccounts cuentas de AWS ahora? (S/N) [por defecto: S]"
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
Write-Host "Prueba finalizada con exito." -ForegroundColor Green
