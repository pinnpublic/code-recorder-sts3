param(
    [string]$JdkHome = 'C:\Program Files\Eclipse Adoptium\jdk-11.0.30.7-hotspot'
)
$ErrorActionPreference = 'Stop'
$projectRoot = Split-Path -Parent $PSScriptRoot
$classes = Join-Path $projectRoot 'build/classes'
$output = Join-Path $projectRoot ('build/test-' + [guid]::NewGuid().ToString('N'))
New-Item -ItemType Directory -Force -Path $output | Out-Null
& (Join-Path $JdkHome 'bin/javac.exe') --release 11 -encoding UTF-8 -classpath $classes -d $output (Join-Path $projectRoot 'tests/CoreTest.java')
if ($LASTEXITCODE -ne 0) { throw 'Test compilation failed' }
& (Join-Path $JdkHome 'bin/java.exe') -classpath "$classes;$output" CoreTest $output
if ($LASTEXITCODE -ne 0) { throw 'Java tests failed' }
$env:RECORDING_TEST_DIR = $output
try {
    & node --test (Join-Path $projectRoot 'tests/replay.test.cjs') (Join-Path $projectRoot 'tests/player-controls.test.cjs')
    if ($LASTEXITCODE -ne 0) { throw 'Replay tests failed' }
} finally { Remove-Item Env:\RECORDING_TEST_DIR }
