$ErrorActionPreference = 'Stop'
$region = 'us-east-2'
$userPoolId = 'us-east-2_E0h8t6hhE'
$baseUrl = 'https://tcpq1i1oxl.execute-api.us-east-2.amazonaws.com'
$clientId = '5jl0g7fb5hhec0qgjo03fnsv12'
$workers = 25
$sessionsPerSecond = 3
$k6Script = Join-Path $PSScriptRoot 'aws_cognito_user_load.js'
$manifestPath = $null

function Get-CognitoTestAccounts {
    $accounts = [System.Collections.Generic.List[object]]::new()
    $paginationToken = $null
    do {
        $arguments = @(
            'cognito-idp', 'list-users', '--no-paginate', '--user-pool-id', $userPoolId,
            '--region', $region, '--limit', '60', '--output', 'json'
        )
        if ($paginationToken) { $arguments += @('--pagination-token', $paginationToken) }
        $page = (& aws @arguments | ConvertFrom-Json)
        if ($LASTEXITCODE -ne 0) { throw 'AWS CLI could not list Cognito users. Check the AWS session and cognito-idp:ListUsers permission.' }
        foreach ($user in $page.Users) {
            $email = ($user.Attributes | Where-Object Name -eq 'email' | Select-Object -First 1 -ExpandProperty Value)
            if ($email -match '^synapse-load-(?<runId>[A-Za-z0-9-]+)-(?<sequence>\d{5})@example\.invalid$') {
                $accounts.Add([pscustomobject]@{
                    username = $user.Username
                    runId = $Matches.runId
                    sequence = $Matches.sequence
                })
            }
        }
        $paginationToken = $page.PaginationToken
    } while ($paginationToken)
    return @($accounts | Sort-Object runId, sequence -Unique)
}

function Show-Header {
    Write-Host ''
    Write-Host 'SYNAPSE HEALTH · PRUEBA DE CARGA DE CUENTAS REALES' -ForegroundColor Cyan
    Write-Host 'Cada cuenta inicia sesión y consulta una ruta real de AWS.' -ForegroundColor Gray
    Write-Host 'La carga se reparte entre catálogo, progreso, historial y ranking.' -ForegroundColor Gray
    Write-Host "Ritmo automático: hasta $sessionsPerSecond cuentas/segundo; se usarán todas las cuentas de prueba detectadas." -ForegroundColor Yellow
    Write-Host 'No se guardan contraseñas ni tokens y no se modifican cuentas o contenido.' -ForegroundColor Gray
    Write-Host 'El contador temporal de límites del backend sí se actualiza.' -ForegroundColor Gray
}

try {
    Show-Header
    if (-not (Get-Command aws -ErrorAction SilentlyContinue)) { throw 'AWS CLI no está instalado o no está en PATH.' }
    & aws sts get-caller-identity --region $region --query Arn --output text *> $null
    if ($LASTEXITCODE -ne 0) { throw 'La sesión de AWS no está activa. Inicia sesión con AWS CLI y vuelve a ejecutar.' }
    $accounts = @(Get-CognitoTestAccounts)
    if ($accounts.Count -eq 0) { throw 'No se encontraron cuentas de prueba. Crea primero cuentas con el ejecutable de registro; las cuentas personales se excluyen.' }
    if (-not (Get-Command k6 -ErrorAction SilentlyContinue)) { throw 'k6 no está instalado o no está en PATH.' }
    if (-not (Test-Path -LiteralPath $k6Script)) { throw 'No se encontró el script de carga.' }
    & k6 version | Out-Null
    if ($LASTEXITCODE -ne 0) { throw 'k6 no pudo iniciar.' }

    $userCount = $accounts.Count
    $workerCount = [Math]::Min($workers, $userCount)
    $manifestPath = Join-Path $env:TEMP "synapse-cognito-load-$([guid]::NewGuid().ToString('N')).json"
    $manifestJson = ConvertTo-Json -InputObject @($accounts) -Depth 4 -Compress
    [System.IO.File]::WriteAllText($manifestPath, $manifestJson, [System.Text.UTF8Encoding]::new($false))
    Write-Host "Cuentas de prueba encontradas: $userCount; máximo de workers: $workerCount." -ForegroundColor Green
    Write-Host 'Se excluyen las cuentas personales; no se crean ni eliminan cuentas.' -ForegroundColor Gray

    $k6Args = @(
        'run',
        '--env', "BASE_URL=$baseUrl",
        '--env', "AWS_REGION=$region",
        '--env', "COGNITO_CLIENT_ID=$clientId",
        '--env', "ACCOUNTS_FILE=$manifestPath",
        '--env', "WORKERS=$workerCount",
        '--env', "SESSIONS_PER_SECOND=$sessionsPerSecond",
        $k6Script
    )
    & k6 @k6Args
    $k6Exit = $LASTEXITCODE
    if ($k6Exit -ne 0) { Write-Host 'La ejecución terminó con errores o umbrales no aprobados; revisa el informe.' -ForegroundColor Red }
} catch {
    Write-Host "No se pudo ejecutar: $($_.Exception.Message)" -ForegroundColor Red
} finally {
    if ($manifestPath -and (Test-Path -LiteralPath $manifestPath)) {
        Remove-Item -LiteralPath $manifestPath -Force
    }
}
Write-Host ''
Read-Host 'Presiona Enter para cerrar'
