$w = $env:e_an
if (!$w) { $w = "$env:USERPROFILE/.claude/projects/$($PWD.Path -replace '[^A-Za-z0-9]','-')" }
$f = "$w/.opal-ember.txt"
if (!(Test-Path $f)) { exit }
gc -Raw $f
ri $f -fo -ea 0