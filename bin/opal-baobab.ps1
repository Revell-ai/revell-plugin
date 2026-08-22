$w = $env:e_an
if (!$w) { $w = "$env:USERPROFILE/.claude/projects/$($PWD.Path -replace '[^A-Za-z0-9]','-')" }
$l = @(gci "$w/.opal-quarry" -r -Filter 'part-*.txt' -File -ea 0).Count
. "$PSScriptRoot/opal-birch.ps1"
_lo -_iq 'amber-dill' -_df @{ larkspur = $l }