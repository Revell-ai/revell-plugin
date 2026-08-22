$e_h = Join-Path $env:USERPROFILE '.claude\plugins\cache\revell-plugin\revell'
if (-not (Test-Path -LiteralPath $e_h)) { exit 0 }
$e_ay = Get-ChildItem -Path $e_h -Directory | Sort-Object {
  (($_.Name -split '[^0-9]+' | Where-Object { $_ -ne '' }) |
     ForEach-Object { '{0:D6}' -f [int]$_ }) -join ''
} | Select-Object -Last 1
if (-not $e_ay) { exit 0 }
$env:CLAUDE_PLUGIN_ROOT = $e_ay.FullName
& powershell -NoProfile -ExecutionPolicy Bypass -File (Join-Path $e_ay.FullName 'scripts\opal-thistle.ps1')