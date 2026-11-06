# Creates a sanitized source archive for ChatGPT review without changing original sources.
param([string]$ProjectRoot = 'C:\Users\user\Desktop\SKT\ZEROward')
$ErrorActionPreference = 'Stop'
$client = Join-Path $ProjectRoot 'on-client'
if (!(Test-Path (Join-Path $client 'src\server.mjs'))) { throw "Cannot find ZEROward source: $client" }
$temp = Join-Path $env:TEMP ('zeroward-export-' + [guid]::NewGuid().ToString('N'))
$dest = Join-Path $temp 'on-client'
New-Item -ItemType Directory -Force -Path $dest | Out-Null
try {
  & robocopy.exe $client $dest /E /NFL /NDL /NJH /NJS /R:1 /W:1 /XD .git node_modules .vercel .next coverage dist build .vscode /XF .env .env.* '*.pem' '*.key' '*.pfx' '*.p12' '*token*.json' '*credential*.json' '*secret*.json' 'id_rsa*' | Out-Null
  if ($LASTEXITCODE -gt 7) { throw "Copy failed: $LASTEXITCODE" }
  $stamp = Get-Date -Format 'yyyyMMdd-HHmmss'
  $zip = Join-Path ([Environment]::GetFolderPath('Desktop')) ("ZEROward-source-review-$stamp.zip")
  Compress-Archive -Path $dest -DestinationPath $zip -CompressionLevel Optimal
  Write-Host "CREATED: $zip"
  Write-Host 'IMPORTANT: Review ZIP contents for passwords, tokens, personal data and configuration secrets before uploading.'
} finally {
  if (Test-Path $temp) { Remove-Item $temp -Recurse -Force }
}
