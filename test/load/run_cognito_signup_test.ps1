$ErrorActionPreference = 'Stop'
$region = 'us-east-2'
$stackName = 'synapse-health-backend'
$scriptPath = Join-Path $PSScriptRoot 'cognito_signup_batch.js'

function Read-Integer($label, $defaultValue, $minimum, $maximum) {
    while ($true) {
        $raw = Read-Host "$label [$defaultValue]"
        if ([string]::IsNullOrWhiteSpace($raw)) { return [int]$defaultValue }
        $number = 0
        if ([int]::TryParse($raw, [ref]$number) -and $number -ge $minimum -and $number -le $maximum) {
            return $number
        }
        Write-Host "Ingresa un numero entre $minimum y $maximum." -ForegroundColor Yellow
    }
}

function Get-StackResources {
    $raw = & aws cloudformation list-stack-resources --stack-name $stackName --region $region --output json 2>$null
    if ($LASTEXITCODE -ne 0) { throw 'No se pudo leer la pila AWS. Inicia sesion con aws login y vuelve a abrir este ejecutable.' }
    return (($raw -join "`n") | ConvertFrom-Json).StackResourceSummaries
}

try {
    if (-not (Get-Command aws -ErrorAction SilentlyContinue)) { throw 'No se encontro AWS CLI.' }
    if (-not (Get-Command k6 -ErrorAction SilentlyContinue)) { throw 'No se encontro k6. Instala k6 antes de ejecutar esta prueba.' }
    $null = & aws sts get-caller-identity --region $region --query Arn --output text 2>$null
    if ($LASTEXITCODE -ne 0) { throw 'La sesion de AWS no esta activa. Ejecuta aws login y vuelve a abrir este ejecutable.' }

    $resources = Get-StackResources
    $pool = $resources | Where-Object LogicalResourceId -eq 'UserPool' | Select-Object -First 1
    $client = $resources | Where-Object LogicalResourceId -eq 'MobileClient' | Select-Object -First 1
    if (-not $pool.PhysicalResourceId -or -not $client.PhysicalResourceId) {
        throw 'No encontre el User Pool y el cliente movil de la pila Synapse Health.'
    }

    Write-Host ''
    Write-Host 'PRUEBA DE REGISTRO REAL EN COGNITO' -ForegroundColor Cyan
    Write-Host 'Las cuentas apareceran en Cognito. Usan correos sinteticos @example.invalid.'
    Write-Host 'No se guardan contrasenas y no se modifica el catalogo ni el progreso.'
    Write-Host 'Lotes grandes o pausas cortas pueden alcanzar los limites de Cognito.' -ForegroundColor Yellow
    $count = Read-Integer 'Numero de cuentas Cognito' 200 1 10000
    $batch = Read-Integer "Cuentas por grupo (1-$count)" 2 1 $count
    if ($batch -gt 50) {
        Write-Host "ADVERTENCIA: se enviaran hasta $batch registros en paralelo; Cognito puede limitar o rechazar el lote y tu PC puede tardar mas." -ForegroundColor Yellow
    }
    $delay = Read-Integer 'Segundos entre grupos' 150 0 86400
    $runId = (Get-Date -Format 'yyyyMMdd-HHmmss') + '-' + (Get-Random -Minimum 1000 -Maximum 9999)
    $groups = [Math]::Ceiling($count / $batch)
    $estimated = [TimeSpan]::FromSeconds([Math]::Max(0, ($groups - 1) * $delay))

    Write-Host ''
    Write-Host "Cuentas: $count | Grupo: $batch | Pausa: $delay s | Ejecucion: $runId"
    Write-Host "Duracion minima estimada: $($estimated.ToString('d\.hh\:mm\:ss'))"
    Write-Host 'El ejecutable solo registra las cuentas de esta ejecucion y se detiene ante errores inesperados.'
    $confirmation = Read-Host 'Escribe CREAR para comenzar'
    if ($confirmation -cne 'CREAR') { Write-Host 'Cancelado; no se enviaron solicitudes.'; exit 0 }

    & k6 run --env "AWS_REGION=$region" --env "COGNITO_CLIENT_ID=$($client.PhysicalResourceId)" `
        --env "VUS=$count" --env "BATCH_SIZE=$batch" --env "INTERVAL_SECONDS=$delay" `
        --env "RUN_ID=$runId" $scriptPath
    if ($LASTEXITCODE -ne 0) {
        Write-Host 'k6 termino con errores. Usa el Run ID del informe para borrar las cuentas parciales.' -ForegroundColor Yellow
    } else {
        $loadRunIdPath = Join-Path $PSScriptRoot 'cognito_load_run_id.txt'
        Set-Content -LiteralPath $loadRunIdPath -Value $runId -Encoding ascii
        Write-Host 'Lote guardado automáticamente para la próxima prueba de carga.' -ForegroundColor Green
    }
} catch {
    Write-Host "ERROR: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}
