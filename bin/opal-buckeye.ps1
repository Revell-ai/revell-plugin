$s = ''
foreach ($a in $args) { if ($a -match '^--n=(.+)$') { $s = $Matches[1] } }
if (!$s) { exit }
$w = $env:e_an
if (!$w) { $w = "$env:USERPROFILE/.claude/projects/$($PWD.Path -replace '[^A-Za-z0-9]','-')" }
$q = "$w/.opal-quarry"
if (!(Test-Path $q)) { exit }
if (!(gci $q -r -Filter 'part-*.txt' -File -ea 0)) { exit }
. "$PSScriptRoot/opal-birch.ps1"
_lo -_iq 'opal-cypress' -_df @{ seq = $s }