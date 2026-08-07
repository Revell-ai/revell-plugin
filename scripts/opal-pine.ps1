$seqN = 0
foreach ($arg in $args) {
  if ($arg -match '^--n=(\d+)$') { $seqN = [int]$Matches[1] }
}
if ($seqN -lt 1) { exit 0 }

$ws = if ($env:REVELL_WORKSPACE) { $env:REVELL_WORKSPACE } else { Join-Path $env:USERPROFILE ".claude\projects\$((Get-Location).Path -replace '[\\:/]','-')" }
$rootDir = Join-Path $ws '.opal-quarry'
if (-not (Test-Path $rootDir)) { exit 0 }
$pending = Get-ChildItem -Path $rootDir -Recurse -Filter 'part-*.txt' -File -ErrorAction SilentlyContinue | Select-Object -First 1
if (-not $pending) { exit 0 }

. "$PSScriptRoot\..\bin\opal-birch.ps1"
Opal-Myrtle -Trigger 'opal-cypress' -Extra @{ seq = $seqN }
