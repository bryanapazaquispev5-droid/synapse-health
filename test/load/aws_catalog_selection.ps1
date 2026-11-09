function Get-CatalogItems {
    param([string]$BaseUrl, [string]$Path, [string]$AccessToken)
    $items = @()
    $cursor = $null
    $seen = @{}
    for ($page = 0; $page -lt 100; $page++) {
        $url = "$BaseUrl$Path`?limit=100"
        if ($cursor) { $url += '&cursor=' + [Uri]::EscapeDataString($cursor) }
        try {
            $response = Invoke-RestMethod -Method Get -Uri $url -Headers @{Authorization="Bearer $AccessToken"; Accept='application/json'} -TimeoutSec 20
        } catch {
            $status = $null
            if ($_.Exception.Response.StatusCode) { $status = [int]$_.Exception.Response.StatusCode }
            $detail = $_.ErrorDetails.Message
            if ($status) { throw "La API respondió HTTP $status al preparar $Path; $detail" }
            throw 'No se pudo conectar con la API al preparar las colecciones; no se inició la carga.'
        }
        if (-not $response.data.items) { throw 'La API devolvió una lista vacía o con un formato inesperado.' }
        $items += @($response.data.items)
        $cursor = [string]$response.data.nextCursor
        if (-not $cursor) { return $items }
        if ($seen.ContainsKey($cursor)) { throw 'La API repitió el cursor; se detuvo la lectura para evitar un ciclo.' }
        $seen[$cursor] = $true
        Start-Sleep -Milliseconds 750
    }
    throw 'La lista supera el máximo seguro de páginas para esta selección.'
}

function Select-CatalogItem {
    param([object[]]$Items, [string]$Kind)
    if ($Items.Count -eq 0) { throw "No hay $Kind disponibles en AWS." }
    Write-Host "`nELIGE $Kind POR NOMBRE" -ForegroundColor Cyan
    for ($index = 0; $index -lt $Items.Count; $index++) {
        $item = $Items[$index]
        $name = if ($item.title) { $item.title } elseif ($item.name) { $item.name } else { "Elemento $($index + 1)" }
        Write-Host ("  {0}. {1}" -f ($index + 1), $name)
    }
    while ($true) {
        $selected = 0
        if ([int]::TryParse((Read-Host "Número de $Kind"), [ref]$selected) -and $selected -ge 1 -and $selected -le $Items.Count) {
            $item = $Items[$selected - 1]
            if (-not $item.id) { throw 'La API devolvió un elemento sin identificador.' }
            return $item
        }
        Write-Host "Elige un número entre 1 y $($Items.Count)." -ForegroundColor Yellow
    }
}

function Resolve-PaginationTarget {
    param([int]$Choice, [string]$BaseUrl, [string]$AccessToken)
    switch ($Choice) {
        1 { return @{label='Áreas médicas'; path='/api/v1/areas'} }
        2 { $area = Select-CatalogItem (Get-CatalogItems $BaseUrl '/api/v1/areas' $AccessToken) 'área'; return @{label="Temas de $($area.name)"; path="/api/v1/areas/$($area.id)/topics"} }
        3 { $area = Select-CatalogItem (Get-CatalogItems $BaseUrl '/api/v1/areas' $AccessToken) 'área'; return @{label="Quizzes de $($area.name)"; path="/api/v1/areas/$($area.id)/quizzes"} }
        4 { $area = Select-CatalogItem (Get-CatalogItems $BaseUrl '/api/v1/areas' $AccessToken) 'área'; $topic = Select-CatalogItem (Get-CatalogItems $BaseUrl "/api/v1/areas/$($area.id)/topics" $AccessToken) 'tema'; return @{label="Quizzes de $($topic.title)"; path="/api/v1/areas/$($area.id)/topics/$($topic.id)/quizzes"} }
        5 { $area = Select-CatalogItem (Get-CatalogItems $BaseUrl '/api/v1/areas' $AccessToken) 'área'; $topic = Select-CatalogItem (Get-CatalogItems $BaseUrl "/api/v1/areas/$($area.id)/topics" $AccessToken) 'tema'; return @{label="Apuntes de $($topic.title)"; path="/api/v1/areas/$($area.id)/topics/$($topic.id)/study-notes"} }
        6 { return @{label='Mi progreso'; path='/api/v1/progress/me'} }
        7 { return @{label='Mi historial'; path='/api/v1/history'} }
        8 { return @{label='Ranking'; path='/api/v1/leaderboard'} }
        default { throw 'La colección seleccionada no es válida.' }
    }
}
