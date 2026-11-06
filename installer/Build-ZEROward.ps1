# ZEROward local Windows prototype installer build script.
# Does not modify the original project; stages a copy under this kit.
param(
  [string]$ProjectRoot = 'C:\Users\user\Desktop\SKT\ZEROward',
  [string]$NodeExe = 'C:\Program Files\nodejs\node.exe',
  [string]$IsccExe = ''
)
$ErrorActionPreference = 'Stop'
$kit = $PSScriptRoot
$client = Join-Path $ProjectRoot 'on-client'
$stage = Join-Path $kit 'build\stage'
$app = Join-Path $stage 'app'
$runtime = Join-Path $stage 'runtime'
$script = Join-Path $kit 'ZEROward.iss'

if (!(Test-Path (Join-Path $client 'src\server.mjs'))) { throw "Missing on-client\src\server.mjs: $client" }
if (!(Test-Path (Join-Path $client 'public\index.html'))) { throw "Missing on-client\public\index.html: $client" }
if (!(Test-Path $NodeExe)) { throw "Node executable missing: $NodeExe" }
if (!(Test-Path $script)) { throw "Inno Setup script missing: $script" }

if (!($IsccExe -and (Test-Path -LiteralPath $IsccExe))) {
  $possible = @(
    (Join-Path ${env:ProgramFiles(x86)} 'Inno Setup 7\ISCC.exe'),
    (Join-Path $env:ProgramFiles 'Inno Setup 7\ISCC.exe'),
    (Join-Path ${env:ProgramFiles(x86)} 'Inno Setup 6\ISCC.exe'),
    (Join-Path $env:ProgramFiles 'Inno Setup 6\ISCC.exe')
  )
  $possible = $possible | Where-Object { $_ -and (Test-Path $_) }
  if ($possible.Count -gt 0) { $IsccExe = $possible[0] }
}
if (!($IsccExe -and (Test-Path -LiteralPath $IsccExe))) { throw 'Inno Setup 6 or 7 ISCC.exe not found. Install it from https://jrsoftware.org/isinfo.php then retry.' }

# Review before distributing: output may contain local project data.
if (Test-Path $stage) { Remove-Item -LiteralPath $stage -Recurse -Force }
New-Item -ItemType Directory -Force -Path $app, $runtime, (Join-Path $kit 'output') | Out-Null

# Build a copy. Explicit excludes for common credentials, development metadata and caches.
$excludeDirs = @('.git','node_modules','.vercel','.next','coverage','dist','build','.vscode')
$excludeFiles = @('.env','.env.*','*.pem','*.key','*.pfx','*.p12','id_rsa*','*token*.json','*credential*.json','*secret*.json')
& robocopy.exe $client $app /E /NFL /NDL /NJH /NJS /R:1 /W:1 /XD $excludeDirs /XF $excludeFiles | Out-Null
if ($LASTEXITCODE -gt 7) { throw "robocopy failed: $LASTEXITCODE" }
Copy-Item -LiteralPath $NodeExe -Destination (Join-Path $runtime 'node.exe')
Copy-Item -LiteralPath (Join-Path $kit 'Launch-ZEROward.ps1') -Destination (Join-Path $stage 'Launch-ZEROward.ps1')
Copy-Item -LiteralPath (Join-Path $kit 'Stop-ZEROward.ps1') -Destination (Join-Path $stage 'Stop-ZEROward.ps1')

# If the app requires production npm packages, install them into the STAGING COPY only.
$packageFile = Join-Path $app 'package.json'
if (Test-Path $packageFile) {
  $package = Get-Content -LiteralPath $packageFile -Raw | ConvertFrom-Json
  $dependencies = @($package.dependencies.PSObject.Properties)
  if ($package.dependencies -and $dependencies.Count -gt 0) {
    Write-Host "Installing $($dependencies.Count) production dependency/dependencies in staged copy only..."
    $npm = Join-Path (Split-Path -Parent $NodeExe) 'npm.cmd'
    if (!(Test-Path $npm)) { throw 'Production npm packages needed but npm.cmd not found.' }
    Push-Location $app
    try {
      if (Test-Path 'package-lock.json') { & $npm ci --omit=dev --no-audit --no-fund }
      else { & $npm install --omit=dev --no-audit --no-fund }
      if ($LASTEXITCODE -ne 0) { throw 'npm production install failed.' }
    } finally { Pop-Location }
  }
}

Write-Host 'Staged app prepared. Review build\stage for secrets and sensitive assets before sharing.'
& $IsccExe $script
if ($LASTEXITCODE -ne 0) { throw "Inno Setup compiler failed: $LASTEXITCODE" }
$installer = Join-Path $kit 'output\ZEROward-Setup.exe'
if (!(Test-Path $installer)) { throw "Compiler returned success but installer missing: $installer" }
$hash = (Get-FileHash -Algorithm SHA256 -LiteralPath $installer).Hash
Write-Host "INSTALLER: $installer"
Write-Host "SHA256: $hash"
Write-Host 'NOTE: Built installer must still be tested on Windows; this prototype opens the default web browser.'
