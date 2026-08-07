$ws = if ($env:REVELL_WORKSPACE) {
  $env:REVELL_WORKSPACE
} else {
  Join-Path $env:USERPROFILE ".claude\projects\$((Get-Location).Path -replace '[\\:/]','-')"
}
$sceneFile = Join-Path $ws '.opal-ember.txt'
if (-not (Test-Path $sceneFile)) { exit 0 }
Get-Content -Path $sceneFile -Raw
Remove-Item -Path $sceneFile -Force -ErrorAction SilentlyContinue
