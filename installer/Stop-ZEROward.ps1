# Only stops a process positively identified as this installation's server.
$ErrorActionPreference = 'SilentlyContinue'
$pidPath = Join-Path $env:LOCALAPPDATA 'ZEROward\server-process.json'
$expected = Join-Path $PSScriptRoot 'app\src\server.mjs'
if (!(Test-Path $pidPath)) { return }
try {
  $state = Get-Content -LiteralPath $pidPath -Raw | ConvertFrom-Json
  $proc = Get-CimInstance Win32_Process -Filter "ProcessId = $($state.pid)"
  if ($proc -and $proc.Name -eq 'node.exe' -and $proc.CommandLine -and $proc.CommandLine.Contains($expected)) {
    Stop-Process -Id $state.pid
  }
} catch {}
Remove-Item -LiteralPath $pidPath -Force -ErrorAction SilentlyContinue
