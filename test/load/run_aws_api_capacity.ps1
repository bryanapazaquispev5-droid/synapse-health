$ErrorActionPreference = 'Stop'
$k6Command = Get-Command k6 -ErrorAction SilentlyContinue
if (-not $k6Command) { throw 'k6 no está instalado o no está en PATH. Instálalo antes de iniciar la prueba.' }
$null = & k6 version
if ($LASTEXITCODE -ne 0) { throw 'No se pudo iniciar k6.' }
$vuText = Read-Host 'Usuarios virtuales (1000-5000) [1000]'
if ([string]::IsNullOrWhiteSpace($vuText)) { $vuText = '1000' }
$vus = 0
if (-not [int]::TryParse($vuText, [ref]$vus) -or $vus -lt 1000 -or $vus -gt 5000) {
    throw 'El número debe ser un entero entre 1000 y 5000.'
}
$baseUrl = Read-Host 'URL base HTTPS de API Gateway'
if ($baseUrl -notmatch '^https://[^/]+') { throw 'Se requiere una URL HTTPS válida.' }
$tokenSecure = Read-Host 'Access token de una cuenta de prueba existente' -AsSecureString
$tokenPtr = [Runtime.InteropServices.Marshal]::SecureStringToBSTR($tokenSecure)
try { $token = [Runtime.InteropServices.Marshal]::PtrToStringBSTR($tokenPtr) }
finally { [Runtime.InteropServices.Marshal]::ZeroFreeBSTR($tokenPtr) }
if ([string]::IsNullOrWhiteSpace($token)) { throw 'El access token no puede estar vacío.' }
Write-Host "Se iniciará una solicitud por cada uno de los $vus usuarios virtuales, con la misma cuenta Cognito existente."
Write-Host 'API Gateway mantiene 5 solicitudes/segundo (ráfaga 10); por ello, los HTTP 429 se reportan como limitación esperada.'
Write-Host 'Se valida primero el token con una sola solicitud. No se crean cuentas, no se escriben datos y el informe solo aparece en CMD.'
if ((Read-Host '¿Continuar? (S/N)') -notin @('S', 's', 'Y', 'y')) { Write-Host 'Prueba cancelada.'; exit 0 }
$env:VUS = [string]$vus
$env:BASE_URL = $baseUrl.TrimEnd('/')
$env:ACCESS_TOKEN = $token
try { & k6 run (Join-Path $PSScriptRoot 'aws_api_capacity.js') }
finally { Remove-Item Env:ACCESS_TOKEN -ErrorAction SilentlyContinue; Remove-Item Env:BASE_URL -ErrorAction SilentlyContinue; Remove-Item Env:VUS -ErrorAction SilentlyContinue; $token = $null }
if ($LASTEXITCODE -ne 0) { throw "k6 terminó con código $LASTEXITCODE. Revisa el resumen de métricas mostrado arriba." }
