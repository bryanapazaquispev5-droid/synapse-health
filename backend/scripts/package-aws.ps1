$ErrorActionPreference = 'Stop'
$backendRoot = [System.IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..'))
$distRoot = Join-Path $backendRoot 'dist'
$stageRoot = Join-Path $distRoot ('aws-package-' + [guid]::NewGuid().ToString('N'))
New-Item -ItemType Directory -Force -Path (Join-Path $stageRoot 'src/aws') | Out-Null
Copy-Item -Path (Join-Path $backendRoot 'src/aws/*') -Destination (Join-Path $stageRoot 'src/aws')
foreach ($sourceName in @('http.mjs','cors.mjs','history-repository.mjs','cognito-runtime.mjs','cognito-user-status.mjs')) {
    Copy-Item -LiteralPath (Join-Path $backendRoot ('src/' + $sourceName)) -Destination (Join-Path $stageRoot 'src')
}
Copy-Item -LiteralPath (Join-Path $backendRoot 'package.json') -Destination $stageRoot
Copy-Item -LiteralPath (Join-Path $backendRoot 'package-lock.json') -Destination $stageRoot
$npmCommand = (Get-Command npm.cmd -ErrorAction Stop).Source
& $npmCommand ci --omit=dev --ignore-scripts --no-audit --no-fund --prefix $stageRoot
if ($LASTEXITCODE -ne 0) { throw 'Production dependency install failed.' }
if (Test-Path -LiteralPath (Join-Path $stageRoot 'node_modules/firebase-admin')) { throw 'Firebase must not enter the Lambda artifact.' }
$archive = Join-Path $distRoot 'synapse-health-aws.zip'
Compress-Archive -Path (Join-Path $stageRoot '*') -DestinationPath $archive -Force
$stream = [System.IO.File]::OpenRead($archive)
$hasher = [System.Security.Cryptography.SHA256]::Create()
try { $hash = [System.BitConverter]::ToString($hasher.ComputeHash($stream)).Replace('-', '') }
finally { $stream.Dispose(); $hasher.Dispose() }
Write-Output ('AWS Lambda artifact: ' + $archive)
Write-Output ('SHA256: ' + $hash)
