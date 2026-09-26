$ErrorActionPreference = 'Stop'
$projectRoot = Split-Path -Parent $PSScriptRoot
$jar = Join-Path $projectRoot 'dist/dev.coderecorder_0.2.6.jar'
if (!(Test-Path $jar)) { throw 'Run scripts/build.ps1 first.' }
$stage = Join-Path $projectRoot ('build/package-' + [guid]::NewGuid().ToString('N'))
$dropins = Join-Path $stage 'dropins'
New-Item -ItemType Directory -Force -Path $dropins | Out-Null
Copy-Item -LiteralPath $jar -Destination $dropins
Copy-Item -LiteralPath (Join-Path $projectRoot 'player') -Destination $stage -Recurse
Copy-Item -LiteralPath (Join-Path $projectRoot 'README.md') -Destination $stage
$archive = Join-Path $projectRoot 'dist/code-recorder-0.2.6.zip'
Compress-Archive -Path (Join-Path $stage '*') -DestinationPath $archive -Force
Write-Output "Packaged: $archive"
