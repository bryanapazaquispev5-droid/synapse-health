# ==============================================================================
# Synapse Health: DynamoDB Ultra-Fast Burst Test Runner (k6)
# Target: 10,000 to 50,000 accounts directly to DynamoDB via AWS API Gateway
# ==============================================================================
param(
    [int]$TotalAccounts = 10000,
    [int]$RequestsPerSecond = 350,
    [string]$ApiBaseUrl = 'https://tcpq1i1oxl.execute-api.us-east-2.amazonaws.com'
)

$ErrorActionPreference = 'Stop'
$ScriptPath = Join-Path $PSScriptRoot 'dynamo_burst_signup.js'

Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host " SYNAPSE HEALTH - DYNAMODB ULTRA-FAST BURST TEST RUNNER    " -ForegroundColor Cyan
Write-Host "==========================================================" -ForegroundColor Cyan

if (-not (Get-Command k6 -ErrorAction SilentlyContinue)) {
    Write-Host "ERROR: k6 no esta instalado o no se encuentra en el PATH." -ForegroundColor Red
    exit 1
}

Write-Host "Parametros seleccionados:" -ForegroundColor Yellow
Write-Host "  - Total de cuentas:    $TotalAccounts"
Write-Host "  - Tasa objetivo:       $RequestsPerSecond req/seg"
Write-Host "  - API Gateway:         $ApiBaseUrl"

$EstimatedSeconds = [Math]::Ceiling($TotalAccounts / $RequestsPerSecond)
Write-Host "  - Tiempo estimado:     ~$EstimatedSeconds segundos"

Write-Host ""
Write-Host "Iniciando k6 con los recursos de CPU/Red de tu maquina..." -ForegroundColor Green

& k6 run `
    --env "BASE_URL=$ApiBaseUrl" `
    --env "ACCOUNTS=$TotalAccounts" `
    --env "RATE=$RequestsPerSecond" `
    $ScriptPath

if ($LASTEXITCODE -eq 0) {
    Write-Host "`nPrueba finalizada exitosamente." -ForegroundColor Green
} else {
    Write-Host "`nPrueba finalizada con codigos de retorno o advertencias." -ForegroundColor Yellow
}
