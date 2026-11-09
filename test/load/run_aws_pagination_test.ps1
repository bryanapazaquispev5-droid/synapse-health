$ErrorActionPreference = 'Stop'
$region = 'us-east-2'
$clientId = '5jl0g7fb5hhec0qgjo03fnsv12'
$defaultApi = 'https://tcpq1i1oxl.execute-api.us-east-2.amazonaws.com'
. (Join-Path $PSScriptRoot 'aws_catalog_selection.ps1')

function Show-Header {
    Clear-Host
    $Host.UI.RawUI.WindowTitle = 'Synapse Health | Prueba de paginación AWS'
    Write-Host ''
    Write-Host '+==============================================================+' -ForegroundColor Cyan
    Write-Host '|       SYNAPSE HEALTH - PRUEBA DE PAGINACIÓN EN AWS          |' -ForegroundColor Cyan
    Write-Host '+==============================================================+' -ForegroundColor Cyan
    Write-Host 'Solo lectura de la API. No crea ni elimina cuentas ni contenido.' -ForegroundColor Gray
}

function Read-Int {
    param([string]$Prompt, [int]$Default, [int]$Minimum, [int]$Maximum)
    while ($true) {
        $raw = Read-Host "$Prompt [$Default]"
        if ([string]::IsNullOrWhiteSpace($raw)) { return $Default }
        $number = 0
        if ([int]::TryParse($raw, [ref]$number) -and $number -ge $Minimum -and $number -le $Maximum) {
            return $number
        }
        Write-Host "Ingresa un número entre $Minimum y $Maximum." -ForegroundColor Yellow
    }
}

function Get-CognitoAccessToken {
    $credentialFile = Join-Path $env:USERPROFILE 'OneDrive\Escritorio\user.txt'
    $hasFile = Test-Path -LiteralPath $credentialFile
    $defaultEmail = $null
    if ($hasFile) {
        $lines = @(Get-Content -LiteralPath $credentialFile)
        if ($lines.Count -ge 2) { $defaultEmail = $lines[0].Trim() }
    }

    Write-Host ''
    Write-Host 'Autenticacion para la prueba de paginacion' -ForegroundColor Cyan
    $email = $null
    $securePassword = $null

    if ($defaultEmail) {
        Write-Host "Cuenta detectada en user.txt: $defaultEmail" -ForegroundColor Gray
        $manual = Read-Host 'Ingresar cuenta manualmente? (S/N) [N]'
        if ($manual -notin @('S', 's', 'Y', 'y')) {
            $lines = @(Get-Content -LiteralPath $credentialFile)
            $email = $lines[0].Trim()
            $securePassword = ConvertTo-SecureString $lines[1] -AsPlainText -Force
        }
    }

    if (-not $email) {
        $email = Read-Host 'Correo de Cognito'
        if ($email -notmatch '^[^@\s]+@[^@\s]+\.[^@\s]+$') {
            throw 'Debes ingresar un correo electronico valido.'
        }
        $securePassword = Read-Host 'Contrasena' -AsSecureString
    }
    $pointer = [Runtime.InteropServices.Marshal]::SecureStringToBSTR($securePassword)
    try {
        $password = [Runtime.InteropServices.Marshal]::PtrToStringBSTR($pointer)
        $payload = @{
            AuthFlow = 'USER_PASSWORD_AUTH'
            ClientId = $clientId
            AuthParameters = @{ USERNAME = $email; PASSWORD = $password }
        } | ConvertTo-Json -Compress
        $response = Invoke-RestMethod -Method Post -Uri "https://cognito-idp.$region.amazonaws.com/" `
            -ContentType 'application/x-amz-json-1.1' `
            -Headers @{ 'X-Amz-Target' = 'AWSCognitoIdentityProviderService.InitiateAuth' } `
            -Body $payload
        if ($response.ChallengeName) { throw 'Cognito solicita un paso adicional; esta prueba solo admite inicio de sesion directo.' }
        if (-not $response.AuthenticationResult.AccessToken) { throw 'Cognito no devolvio un access token.' }
        return [string]$response.AuthenticationResult.AccessToken
    } catch {
        if ($_.Exception.Message -like 'Cognito solicita*' -or $_.Exception.Message -like 'Cognito no devolvio*') { throw }
        throw "No se pudo iniciar sesion en Cognito para '$email'. Revisa las credenciales o el estado de la cuenta."
    } finally {
        [Runtime.InteropServices.Marshal]::ZeroFreeBSTR($pointer)
        $password = $null
        $payload = $null
        $response = $null
        if ($securePassword) { $securePassword.Dispose() }
    }
}
function Get-MetricPoint {
    param([string]$Namespace, [string]$Metric, [string[]]$Dimensions, [string]$Statistic,
        [string]$StartTime, [string]$EndTime)
    $awsArgs = @('cloudwatch', 'get-metric-statistics', '--namespace', $Namespace,
        '--metric-name', $Metric, '--dimensions') + $Dimensions + @(
        '--start-time', $StartTime, '--end-time', $EndTime, '--period', '60',
        '--statistics', $Statistic, '--region', $region, '--output', 'json')
    try {
        $raw = & aws @awsArgs 2>$null
        $cliExit = $LASTEXITCODE
    } catch {
        return "$Namespace/$Metric : AWS CLI no pudo consultar esta métrica"
    }
    if ($cliExit -ne 0 -or -not $raw) { return "$Namespace/$Metric : no disponible; revisa permisos o sesión de AWS CLI" }
    try {
        $points = @(($raw | ConvertFrom-Json).Datapoints | Sort-Object Timestamp)
        if ($points.Count -eq 0) { return "$Namespace/$Metric : aún sin datos" }
        $value = $points[-1].PSObject.Properties[$Statistic].Value
        return "$Namespace/$Metric ($Statistic): $([math]::Round([double]$value, 2))"
    } catch {
        return "$Namespace/$Metric : respuesta no legible"
    }
}

function Show-CloudWatchSummary {
    param([string]$ApiId, [DateTime]$StartUtc, [DateTime]$EndUtc)
    if (-not (Get-Command aws -ErrorAction SilentlyContinue)) {
        Write-Host 'No se encontró AWS CLI; consulta CloudWatch manualmente.' -ForegroundColor Yellow
        return
    }
    try { $identity = & aws sts get-caller-identity --region $region --output json 2>$null } catch { $identity = $null }
    if ($LASTEXITCODE -ne 0 -or -not $identity) {
        Write-Host 'CloudWatch no se consultó: falta una sesión válida de AWS CLI. La sesión de Cognito de la app no da permisos de AWS.' -ForegroundColor Yellow
        Write-Host 'Inicia AWS CLI con aws login y usa un perfil con cloudwatch:GetMetricStatistics, o responde N para omitir esta consulta.' -ForegroundColor Gray
        return
    }
    $start = $StartUtc.AddMinutes(-1).ToString('yyyy-MM-ddTHH:mm:ssZ')
    $end = $EndUtc.AddMinutes(1).ToString('yyyy-MM-ddTHH:mm:ssZ')
    $apiDims = @("Name=ApiId,Value=$ApiId", 'Name=Stage,Value=$default')
    $lambdaDims = @('Name=FunctionName,Value=synapse-health-backend-api')
    $ddbDims = @('Name=TableName,Value=synapse-health-backend-rate-limits')
    Write-Host ''
    Write-Host 'CloudWatch - métricas agregadas en la ventana de prueba' -ForegroundColor Cyan
    $queries = @(
        [pscustomobject]@{Namespace='AWS/ApiGateway'; Metric='Count'; Dimensions=$apiDims; Statistic='Sum'},
        [pscustomobject]@{Namespace='AWS/ApiGateway'; Metric='4xx'; Dimensions=$apiDims; Statistic='Sum'},
        [pscustomobject]@{Namespace='AWS/ApiGateway'; Metric='5xx'; Dimensions=$apiDims; Statistic='Sum'},
        [pscustomobject]@{Namespace='AWS/ApiGateway'; Metric='Latency'; Dimensions=$apiDims; Statistic='Average'},
        [pscustomobject]@{Namespace='AWS/Lambda'; Metric='Invocations'; Dimensions=$lambdaDims; Statistic='Sum'},
        [pscustomobject]@{Namespace='AWS/Lambda'; Metric='Errors'; Dimensions=$lambdaDims; Statistic='Sum'},
        [pscustomobject]@{Namespace='AWS/Lambda'; Metric='Throttles'; Dimensions=$lambdaDims; Statistic='Sum'},
        [pscustomobject]@{Namespace='AWS/Lambda'; Metric='Duration'; Dimensions=$lambdaDims; Statistic='Average'},
        [pscustomobject]@{Namespace='AWS/DynamoDB'; Metric='ThrottledRequests'; Dimensions=$ddbDims; Statistic='Sum'}
    )
    foreach ($query in $queries) {
        Write-Host (Get-MetricPoint -Namespace $query.Namespace -Metric $query.Metric -Dimensions $query.Dimensions -Statistic $query.Statistic -StartTime $start -EndTime $end)
    }
    Write-Host 'CloudWatch agrupa por minuto y puede tardar en publicar datos; las cifras pueden incluir tráfico ajeno a esta prueba.' -ForegroundColor Gray
}

function Start-PaginationTest {
    Show-Header
    $k6 = Get-Command k6 -ErrorAction SilentlyContinue
    if (-not $k6) { throw 'No se encontró k6. Instálalo y vuelve a abrir este ejecutable.' }
    & k6 version | Out-Null
    if ($LASTEXITCODE -ne 0) { throw 'k6 no pudo iniciar.' }

    $baseUrl = $defaultApi
    $pageLimit = 1
    $maxPages = 2
    $pagePacing = 3
    $thinkTime = 1
    $vus = 3
    Write-Host 'La prueba recorrerá automáticamente las ocho categorías paginadas.' -ForegroundColor Cyan
    Write-Host 'Usará hasta 3 VUs, 1 fila por página y 3 segundos entre solicitudes.' -ForegroundColor Yellow
    Write-Host 'Solo hace lecturas; el contador temporal de rate-limits del backend sí se actualiza.' -ForegroundColor Gray
    $token = Get-CognitoAccessToken
    $areas = @(Get-CatalogItems $baseUrl '/api/v1/areas' $token)
    if ($areas.Count -eq 0) { throw 'AWS no devolvió áreas para ejecutar la prueba.' }
    $area = $areas[0]
    $areaId = [Uri]::EscapeDataString([string]$area.id)
    $topics = @(Get-CatalogItems $baseUrl "/api/v1/areas/$areaId/topics" $token)
    if ($topics.Count -eq 0) { throw 'El área automática no tiene temas; no se puede probar quizzes ni apuntes.' }
    $topic = $topics[0]
    $topicId = [Uri]::EscapeDataString([string]$topic.id)
    $areaName = if ($area.name) { $area.name } else { 'primera área disponible' }
    $topicName = if ($topic.title) { $topic.title } else { 'primer tema disponible' }
    $targets = @(
        @{label='Áreas médicas'; path='/api/v1/areas'},
        @{label="Temas de $areaName"; path="/api/v1/areas/$areaId/topics"},
        @{label="Quizzes de $areaName"; path="/api/v1/areas/$areaId/quizzes"},
        @{label="Quizzes de $topicName"; path="/api/v1/areas/$areaId/topics/$topicId/quizzes"},
        @{label="Apuntes de $topicName"; path="/api/v1/areas/$areaId/topics/$topicId/study-notes"},
        @{label='Mi progreso'; path='/api/v1/progress/me'},
        @{label='Mi historial'; path='/api/v1/history'},
        @{label='Ranking'; path='/api/v1/leaderboard'}
    )
    $env:BASE_URL = $baseUrl
    $env:TARGETS_JSON = ConvertTo-Json -InputObject $targets -Compress
    $env:TARGET_LABEL = 'Todas las categorías paginadas'
    $env:ACCESS_TOKEN = $token
    $env:PAGE_LIMIT = [string]$pageLimit
    $env:MAX_PAGES = [string]$maxPages
    $env:LOAD_VUS = [string]$vus
    $env:THINK_TIME_SECONDS = [string]$thinkTime
    $env:PAGE_PACING_SECONDS = [string]$pagePacing
    try {
        Write-Host "Área y tema elegidos automáticamente: $areaName → $topicName" -ForegroundColor White
        Write-Host 'Colecciones: catálogo, progreso, historial y ranking.' -ForegroundColor White
        Write-Host 'El informe aparecerá al terminar; no se crearán usuarios ni contenido.' -ForegroundColor Gray
        & k6 run (Join-Path $PSScriptRoot 'aws_pagination_load.js')
        $k6Exit = $LASTEXITCODE
    } finally {
        foreach ($name in @('BASE_URL', 'TARGETS_JSON', 'TARGET_LABEL', 'ACCESS_TOKEN', 'PAGE_LIMIT',
            'MAX_PAGES', 'LOAD_VUS', 'THINK_TIME_SECONDS', 'PAGE_PACING_SECONDS')) {
            Remove-Item "Env:$name" -ErrorAction SilentlyContinue
        }
        $token = $null
    }
    if ($k6Exit -ne 0) { Write-Host "k6 terminó con código $k6Exit; revisa errores/umbrales en el informe." -ForegroundColor Red }
    else { Write-Host 'La prueba de todas las categorías terminó correctamente.' -ForegroundColor Green }
}

try {
    Start-PaginationTest
} catch {
    $errorMessage = $_.Exception.Message
    if ([string]::IsNullOrWhiteSpace($errorMessage)) { $errorMessage = 'Error sin detalle; comprueba la sesión y permisos de AWS CLI.' }
    Write-Host "No se pudo ejecutar: $errorMessage" -ForegroundColor Red
}
Write-Host ''
Read-Host 'Presiona Enter para cerrar'

