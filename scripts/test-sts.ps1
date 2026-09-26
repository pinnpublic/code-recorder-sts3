param(
    [string]$StsHome = 'C:\dev\sts-3.9.18.RELEASE',
    [string]$JdkHome = 'C:\Program Files\Eclipse Adoptium\jdk-11.0.30.7-hotspot'
)
$ErrorActionPreference = 'Stop'
$projectRoot = Split-Path -Parent $PSScriptRoot
$runRoot = Join-Path $projectRoot ('build/sts-test-' + [guid]::NewGuid().ToString('N'))
$config = Join-Path $runRoot 'configuration'
$simple = Join-Path $config 'org.eclipse.equinox.simpleconfigurator'
$classes = Join-Path $runRoot 'classes'
New-Item -ItemType Directory -Force -Path $simple,$classes | Out-Null
$classpath = (Join-Path $StsHome 'plugins/*') + ';' + (Join-Path $projectRoot 'dist/dev.coderecorder_0.2.5.jar')
$sources = @(Get-ChildItem (Join-Path $projectRoot 'tests/eclipse/src') -Recurse -Filter '*.java' | ForEach-Object { $_.FullName })
& (Join-Path $JdkHome 'bin/javac.exe') --release 11 -encoding UTF-8 -classpath $classpath -d $classes $sources
if ($LASTEXITCODE -ne 0) { throw 'Integration test compilation failed' }
$testJar = Join-Path $runRoot 'dev.coderecorder.tests_0.1.0.jar'
& (Join-Path $JdkHome 'bin/jar.exe') --create --file $testJar --manifest (Join-Path $projectRoot 'tests/eclipse/META-INF/MANIFEST.MF') -C $classes . -C (Join-Path $projectRoot 'tests/eclipse') plugin.xml
if ($LASTEXITCODE -ne 0) { throw 'Test JAR failed' }
function FileUri([string]$path) { return ([uri]$path).AbsoluteUri }
$bundleLines = Get-Content (Join-Path $StsHome 'configuration/org.eclipse.equinox.simpleconfigurator/bundles.info') | Where-Object { !($_.StartsWith('org.eclipse.egit.')) } | ForEach-Object {
    if ($_.StartsWith('#')) { $_ } else {
        $parts = $_.Split(',')
        $parts[2] = FileUri (Join-Path $StsHome $parts[2])
        $parts -join ','
    }
}
$bundleLines += 'dev.coderecorder,0.2.5,' + (FileUri (Join-Path $projectRoot 'dist/dev.coderecorder_0.2.5.jar')) + ',4,false'
$bundleLines += 'dev.coderecorder.tests,0.1.0,' + (FileUri $testJar) + ',4,false'
[IO.File]::WriteAllLines((Join-Path $simple 'bundles.info'), $bundleLines, [Text.UTF8Encoding]::new($false))
$framework = Get-ChildItem (Join-Path $StsHome 'plugins') -Filter 'org.eclipse.osgi_*.jar' | Select-Object -First 1
$configurator = Get-ChildItem (Join-Path $StsHome 'plugins') -Filter 'org.eclipse.equinox.simpleconfigurator_*.jar' | Select-Object -First 1
$launcher = Get-ChildItem (Join-Path $StsHome 'plugins') -Filter 'org.eclipse.equinox.launcher_*.jar' | Select-Object -First 1
$settings = @(
    'osgi.bundles=reference:' + (FileUri $configurator.FullName) + '@1:start'
    'osgi.bundles.defaultStartLevel=4'
    'org.eclipse.equinox.simpleconfigurator.configUrl=' + (FileUri (Join-Path $simple 'bundles.info'))
    'osgi.framework=' + (FileUri $framework.FullName)
    'eclipse.application=dev.coderecorder.tests.run'
    'org.eclipse.update.reconcile=false'
    'osgi.configuration.cascaded=false'
)
[IO.File]::WriteAllLines((Join-Path $config 'config.ini'), $settings, [Text.UTF8Encoding]::new($false))
$arguments = @(
    '-Drecorder.test.output="' + $runRoot + '"'
    '-Xmx1024m'
    '-jar "' + $launcher.FullName + '"'
    '-configuration "' + $config + '"'
    '-data "' + (Join-Path $runRoot 'workspace') + '"'
    '-application dev.coderecorder.tests.run'
    '-nosplash -consoleLog -clean'
)
$process = Start-Process -FilePath (Join-Path $JdkHome 'bin/java.exe') -ArgumentList $arguments -WindowStyle Hidden -PassThru -RedirectStandardOutput (Join-Path $runRoot 'stdout.log') -RedirectStandardError (Join-Path $runRoot 'stderr.log')
Write-Output "PID=$($process.Id)"
Write-Output "OUTPUT=$runRoot"
