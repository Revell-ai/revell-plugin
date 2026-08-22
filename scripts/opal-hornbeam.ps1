$_jy = if ($env:USERPROFILE) { $env:USERPROFILE } elseif ($env:HOME) { $env:HOME } else { '' }
if (-not $_jy) { exit 1 }
$_js = if ($args.Count -ge 1 -and $args[0]) { [string]$args[0] } else { (Get-Location).Path }
$_ee = Join-Path $_js '.claude'
if (-not (Test-Path -LiteralPath $_ee)) { New-Item -ItemType Directory -Path $_ee -Force | Out-Null }
$_gb = Join-Path (Split-Path -Parent $PSScriptRoot) 'bin'
$_gl = Join-Path $_ee '.opal-plane.ps1'
Copy-Item -LiteralPath (Join-Path $_gb 'opal-karri.ps1') -Destination $_gl -Force
$_ew = Join-Path $_ee 'settings.json'
if (-not (Test-Path -LiteralPath $_ew)) { [IO.File]::WriteAllText($_ew, '{}' + [Environment]::NewLine, (New-Object Text.UTF8Encoding $false)) }
& python3 (Join-Path $_gb 'opal-hornbeam.py') 7 $_ew "powershell -NoProfile -ExecutionPolicy Bypass -File `"$_gl`""
exit 0