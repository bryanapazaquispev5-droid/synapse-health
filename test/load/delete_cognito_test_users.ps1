$ErrorActionPreference = 'Stop'
$region = 'us-east-2'
$stackName = 'synapse-health-backend'

function Get-StackResources {
    $raw = & aws cloudformation list-stack-resources --stack-name $stackName --region $region --output json 2>$null
    if ($LASTEXITCODE -ne 0) { throw 'No se pudo leer la pila AWS. Inicia sesion con aws login y vuelve a abrir este ejecutable.' }
    return (($raw -join "`n") | ConvertFrom-Json).StackResourceSummaries
}

function Get-RunUsers($poolId, $prefix) {
    $raw = & aws cognito-idp list-users --user-pool-id $poolId --region $region --output json 2>$null
    if ($LASTEXITCODE -ne 0) { throw 'No se pudo consultar Cognito.' }
    $all = ((($raw -join "`n") | ConvertFrom-Json).Users)
    $matches = @(
        foreach ($user in $all) {
            $email = ($user.Attributes | Where-Object Name -eq 'email' | Select-Object -First 1).Value
            if ($email -and $email.StartsWith($prefix, [StringComparison]::OrdinalIgnoreCase)) {
                [pscustomobject]@{Username = $user.Username; Email = $email}
            }
        }
    )
    return $matches
}

try {
    if (-not (Get-Command aws -ErrorAction SilentlyContinue)) { throw 'No se encontro AWS CLI.' }
    $null = & aws sts get-caller-identity --region $region --query Arn --output text 2>$null
    if ($LASTEXITCODE -ne 0) { throw 'La sesion de AWS no esta activa. Ejecuta aws login y vuelve a abrir este ejecutable.' }
    $resources = Get-StackResources
    $pool = $resources | Where-Object LogicalResourceId -eq 'UserPool' | Select-Object -First 1
    if (-not $pool.PhysicalResourceId) { throw 'No encontre el User Pool de Synapse Health.' }

    Write-Host ''
    Write-Host 'ELIMINAR CUENTAS DE UNA EJECUCION DE PRUEBA' -ForegroundColor Cyan
    $runId = Read-Host 'Run ID mostrado por la prueba de registro'
    if ($runId -notmatch '^[A-Za-z0-9-]{8,40}$') { throw 'Run ID invalido; no se hizo ningun cambio.' }
    $prefix = "synapse-load-$runId-"
    $users = Get-RunUsers $pool.PhysicalResourceId $prefix
    if ($users.Count -eq 0) { Write-Host 'No hay cuentas de esa ejecucion. No se hizo ningun cambio.'; exit 0 }
    $users = @($users | Where-Object { $_.Email -ine 'bryanapazaquispev5@gmail.com' })
    if ($users.Count -gt 10000) { throw 'Se encontraron mas de 10000 coincidencias; se detuvo la eliminacion por seguridad.' }

    Write-Host "Cuentas que coinciden exactamente con $prefix : $($users.Count)"
    Write-Host 'Solo se borraran esas cuentas de Cognito. No se borraran otros usuarios ni tablas.'
    $confirmation = Read-Host "Para confirmar, escribe ELIMINAR $runId"
    if ($confirmation -cne "ELIMINAR $runId") { Write-Host 'Cancelado; no se borro ninguna cuenta.'; exit 0 }

    $deleted = 0
    $failed = 0
    $worker = {
        param($userPoolId, $username, $awsRegion)
        for ($attempt = 1; $attempt -le 7; $attempt++) {
            $message = @(& aws cognito-idp admin-delete-user --user-pool-id $userPoolId --username $username --region $awsRegion 2>&1)
            if ($LASTEXITCODE -eq 0) { return $true }
            $joined = $message -join ' '
            if ($joined -notmatch 'TooManyRequests|Throttl|RequestLimitExceeded|InternalError|ServiceUnavailable') { return $false }
            Start-Sleep -Milliseconds ([Math]::Min(250 * $attempt, 2000))
        }
        return $false
    }
    $runspacePool = [RunspaceFactory]::CreateRunspacePool(1, 5)
    $runspacePool.Open()
    try {
        for ($offset = 0; $offset -lt $users.Count; $offset += 50) {
            $chunk = @($users | Select-Object -Skip $offset -First 50)
            $jobs = @(
                foreach ($user in $chunk) {
                    $powerShell = [PowerShell]::Create()
                    $powerShell.RunspacePool = $runspacePool
                    $null = $powerShell.AddScript($worker.ToString()).AddArgument($pool.PhysicalResourceId).AddArgument($user.Username).AddArgument($region)
                    [pscustomobject]@{PowerShell = $powerShell; Handle = $powerShell.BeginInvoke()}
                }
            )
            foreach ($job in $jobs) {
                $result = $job.PowerShell.EndInvoke($job.Handle)
                if ($result -contains $true) { $deleted++ } else { $failed++ }
                $job.PowerShell.Dispose()
            }
            Write-Host "Procesadas: $($deleted + $failed) / $($users.Count) | borradas: $deleted | fallidas: $failed"
        }
    } finally {
        $runspacePool.Close()
        $runspacePool.Dispose()
    }

    $remaining = (Get-RunUsers $pool.PhysicalResourceId $prefix).Count
    Write-Host ''
    Write-Host 'INFORME DE ELIMINACION' -ForegroundColor Cyan
    Write-Host "Cuentas encontradas: $($users.Count) | Borradas: $deleted | Fallidas: $failed | Restantes: $remaining"
    if ($remaining -gt 0) { Write-Host 'Vuelve a ejecutar este eliminador con el mismo Run ID para reintentar las restantes.' -ForegroundColor Yellow }
} catch {
    Write-Host "ERROR: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}
