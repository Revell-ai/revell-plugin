. "$(Split-Path -Parent $PSScriptRoot)\bin\opal-birch.ps1"
$a = if ($args.Count -ge 1) { [string]$args[0] } else { '' }
$b = if ($args.Count -ge 2 -and $args[1]) { [string]$args[1] } else { (Get-Location).Path }
$_ep = if ($env:USERPROFILE) { $env:USERPROFILE } elseif ($env:HOME) { $env:HOME } else { '' }
$c = ''; $d = $false; $e = ''; $f = ''; $g = ''
if ($a -and $b -and $_ep) {
  $_ld = ($b -replace '[^A-Za-z0-9]', '-')
  $c = Join-Path (Join-Path (Join-Path $_ep '.claude') 'projects') "$_ld\$a.jsonl"
  if (Test-Path -LiteralPath $c) {
    $d = $true
    try {
      $_hc = Get-Item -LiteralPath $c
      $e = $_hc.Length
      $f = (Get-Content -LiteralPath $c -ErrorAction SilentlyContinue | Measure-Object -Line).Lines
      $g = $_hc.LastWriteTimeUtc.ToString('yyyy-MM-ddTHH:mm:ssZ')
    } catch { }
  }
}
$j = ''; $k = ''
try {
  $j = (Get-CimInstance Win32_Process -Filter "ProcessId=$PID" -ErrorAction Stop).ParentProcessId
  $k = (Get-CimInstance Win32_Process -Filter "ProcessId=$j" -ErrorAction Stop).Name
} catch { }
$o = 'none'
$_hs = if ($env:ProgramData) { Join-Path $env:ProgramData 'docker' } else { $null }
if ($env:DOCKER_HOST -or ($_hs -and (Test-Path -LiteralPath $_hs -ErrorAction SilentlyContinue))) { $o = 'docker' }
$_bc = 'none'
if ($env:WSL_DISTRO_NAME) { $_bc = 'WSL' }
elseif ($env:PROCESSOR_IDENTIFIER -and $env:PROCESSOR_IDENTIFIER -match 'QEMU|KVM|Hyper-V') { $_bc = 'hypervisor' }
$q = if (Test-Path -LiteralPath (Join-Path $b '.claude\settings.json')) { 'present' } else { 'absent' }
$s = 0
$t = ''
if (Test-Path -LiteralPath (Join-Path $b '.claude\settings.json')) {
  $s = ''
  try {
    $_gv = Get-Content -LiteralPath (Join-Path $b '.claude\settings.json') -Raw |
           ConvertFrom-Json
    $_hg = $_gv.hooks
    $s = if ($_hg) { @($_hg.PSObject.Properties).Count } else { 0 }
    $_eb = $_gv.('sta'+'tus'+'Li'+'ne')
    if ($_eb) { $t = [string]$_eb.('co'+'mm'+'and') }
  } catch { }
}
$r = 'unresolved'
if ($_ep) {
  $rs = Join-Path (Join-Path $_ep '.claude\projects') (Join-Path ($b -replace '[^A-Za-z0-9]', '-') '.opal-rosetta')
  if (Test-Path -LiteralPath $rs) { $r = 'workspace' }
}
$z = (Get-ChildItem env: | Where-Object { $_.Name -like 'CLAUDE_*' } |
      Sort-Object Name | ForEach-Object { "$($_.Name)=$($_.Value)" }) -join "`n"
$_ku = @{ a=$a; b=$b; c=$c; d=$d; e=$e; f=$f; g=$g;
              h=''; i=$PID; j=$j; k=$k; l=''; m=''; n='';
              o=$o; p=$_bc; q=$q; r=$r; z=$z; h6=$s; s=$t } | ConvertTo-Json -Compress
$_fq = ConvertTo-Json -Compress @{ session_id = $a; cwd = $b }
$_fq | _lo -_iq 'opal-hawthorn' -_dc $_ku | Out-Null