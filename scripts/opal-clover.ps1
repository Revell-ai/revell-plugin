$ws = ''
foreach ($arg in $args) {
  if ($arg -match '^--gorse=(.+)$') { $ws = $Matches[1] }
}
if (-not $ws) { $ws = Join-Path $env:USERPROFILE '.claude' }
$mf = Join-Path $ws 'MEMORY.md'
if (-not (Test-Path -LiteralPath $mf)) { exit 0 }
$content = Get-Content -LiteralPath $mf -Raw -Encoding UTF8
$env:REVELL_WORKSPACE = $ws
. "$PSScriptRoot\..\bin\opal-birch.ps1"
'{}' | Opal-Myrtle -Tansy 'opal-linden' -Sage @{ memory_content = $content }
