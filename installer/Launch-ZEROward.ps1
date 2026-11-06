# ZEROward Windows installed launcher (localhost app in user's default browser).
$ErrorActionPreference = 'Stop'
$port = 5189
$serverPath = Join-Path $PSScriptRoot 'app\src\server.mjs'
$appDir = Join-Path $PSScriptRoot 'app'
$nodeExe = Join-Path $PSScriptRoot 'runtime\node.exe'
$target = "http://127.0.0.1:$port/"
$localState = Join-Path $env:LOCALAPPDATA 'ZEROward'
New-Item -ItemType Directory -Force -Path $localState | Out-Null
function Alert([string]$message) {
  try {
    Add-Type -AssemblyName System.Windows.Forms
    [System.Windows.Forms.MessageBox]::Show($message,'ZEROward','OK','Warning') | Out-Null
  } catch { Write-Error $message }
}
try {
  if (!(Test-Path $nodeExe) -or !(Test-Path $serverPath)) { throw 'Installed ZEROward executable or server file not found.' }
  $listener = @(Get-NetTCPConnection -LocalPort $port -State Listen -ErrorAction SilentlyContinue | Where-Object LocalAddress -in @('127.0.0.1','::1','0.0.0.0','::'))
  if ($listener.Count -gt 0) {
    $owned = $false
    foreach ($ln in $listener) {
      $p = Get-CimInstance Win32_Process -Filter "ProcessId = $($ln.OwningProcess)" -ErrorAction SilentlyContinue
      if ($p -and $p.Name -eq 'node.exe' -and $p.CommandLine -and $p.CommandLine.Contains($serverPath)) { $owned = $true; break }
    }
    if (!$owned) { throw "Port $port is occupied by a different application. Close it first; ZEROward will not stop another program." }
  } else {
    $proc = Start-Process -FilePath $nodeExe -ArgumentList ('"' + $serverPath + '"') -WorkingDirectory $appDir -WindowStyle Hidden -PassThru -RedirectStandardOutput (Join-Path $localState 'server-out.log') -RedirectStandardError (Join-Path $localState 'server-error.log')
    [PSCustomObject]@{pid=$proc.Id; serverPath=$serverPath} | ConvertTo-Json | Set-Content -LiteralPath (Join-Path $localState 'server-process.json') -Encoding UTF8
  }
  $ready = $false
  for ($i=0; $i -lt 45; $i++) {
    try {
      $r = Invoke-WebRequest -Uri $target -UseBasicParsing -TimeoutSec 2 -ErrorAction Stop
      if ($r.StatusCode -eq 200 -and $r.Content -match '<!doctype html>') { $ready = $true; break }
    } catch {}
    Start-Sleep -Milliseconds 400
  }
  if (!$ready) { throw "ZEROward didn't respond on port $port. Check $localState\server-error.log" }
  Start-Process $target
} catch { Alert $_.Exception.Message }
