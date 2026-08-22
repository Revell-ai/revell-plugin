$_id = try { [Console]::In.ReadToEnd() } catch { '' }
if (-not $_id) { exit 0 }
$_a = try { $_id | ConvertFrom-Json -ErrorAction Stop } catch { $null }
if (-not $_a) { exit 0 }
if ($_a.final -ne $true) { exit 0 }
$_ds = [string]$_a.session_id
$cwd       = [string]$_a.cwd
$_dr = [string]$_a.transcript_path
if (-not $_ds -or -not $_dr -or -not (Test-Path -LiteralPath $_dr)) { exit 0 }
if (-not $cwd) { $cwd = (Get-Location).Path }
$_ay = if ($env:HOME) { $env:HOME } elseif ($env:USERPROFILE) { $env:USERPROFILE } else { [Environment]::GetFolderPath('UserProfile') }
$_p = if ($env:e_an) {
  $env:e_an
} else {
  $_kf = ($cwd -replace '[^A-Za-z0-9]', '-')
  Join-Path (Join-Path $_ay '.claude\projects') $_kf
}
$_bb = Join-Path $_p '.opal-mile'
$_bj      = Join-Path $_p '.opal-reed'
foreach ($d in @($_bb, $_bj)) {
  if (-not (Test-Path -LiteralPath $d)) { New-Item -ItemType Directory -Path $d -Force | Out-Null }
}
$_ej = Join-Path $_bb "$_ds.txt"
$_bl = 0
if (Test-Path -LiteralPath $_ej) {
  $_x = Get-Content -LiteralPath $_ej -Raw -ErrorAction SilentlyContinue
  if ($_x) { $_bl = [int]($_x.Trim()) }
}
$_go = @(Get-Content -LiteralPath $_dr -ErrorAction SilentlyContinue)
$_gy = $_go.Count
if ($_gy -le $_bl) { exit 0 }
$_e = New-Object System.Collections.ArrayList
$_ar = $_bl
for ($i = $_bl; $i -lt $_gy; $i++) {
  $_f = $_go[$i]
  $_cs = $i + 1
  if (-not $_f -or -not $_f.Trim()) {
    $_ar = $_cs
    continue
  }
  $d = $null
  try { $d = $_f | ConvertFrom-Json -ErrorAction Stop } catch {
    break
  }
  $_ar = $_cs
  $_cw = if ($d.promptId) { [string]$d.promptId } else { '' }
  $t = [string]$d.type
  if ($t -eq 'user') {
    $content = [string]$d.message.content
    if ($content -and $content.Trim()) {
      $_bt = if ($_cw) { $_cw } else { 'user' }
      $_cg = "$_bt-$_cs"
      $_co = if ($_cw) { $_cw } else { "turn-$_cs" }
      [void]$_e.Add(@{ speaker='human'; message_id=$_cg; turn_id=$_co; content=$content })
    }
  } elseif ($t -eq 'assistant') {
    $_gr = $d.message.content
    if ($_gr -is [System.Collections.IEnumerable]) {
      $_ci = @()
      foreach ($b in $_gr) {
        if ($b.type -eq 'text' -and $b.text) { $_ci += [string]$b.text }
      }
      $content = ($_ci -join '').Trim()
      if ($content) {
        $_bt = if ($d.message.id) { [string]$d.message.id } else { 'assistant' }
        $_cg = "$_bt-$_cs"
        $_co = if ($_cw) { $_cw } else { "turn-$_cs" }
        [void]$_e.Add(@{ speaker='agent'; message_id=$_cg; turn_id=$_co; content=$content })
      }
    }
  }
}
if ($_e.Count -eq 0) {
  Set-Content -LiteralPath $_ej -Value $_ar.ToString() -Force
  exit 0
}
Start-Job -ScriptBlock {
  param($_p, $_bj, $_lc, $_en, $cwd, $_kz, $_ko, $_li)
  . "$_lc\..\bin\opal-birch.ps1"
  $env:e_an = $_p
  $_e = $_kz | ConvertFrom-Json
  $_dx = $true
  foreach ($_as in $_e) {
    $tmp = Join-Path $_bj "msg-$PID-$($_as.message_id).txt"
    Set-Content -LiteralPath $tmp -Value $_as.content -Encoding UTF8 -NoNewline -Force
    $_fq = ConvertTo-Json -Compress @{ session_id = $_en; cwd = $cwd }
    $_fq | _lo -_iq 'opal-voyage' `
      -_db $_as.turn_id -_dd $_as.message_id `
      -_dg $_as.speaker -_bo $tmp
    $_le = $?
    Remove-Item -LiteralPath $tmp -Force -ErrorAction SilentlyContinue
    if (-not $_le) {
      Write-Error 'Blue50.Pink49'
      $_dx = $false
      break
    }
  }
  if ($_dx) { $_li | Set-Content -LiteralPath $_ko -Force }
} -ArgumentList $_p, $_bj, $PSScriptRoot, $_ds, $cwd, ($_e | ConvertTo-Json -Compress), $_ej, $_ar.ToString() | Out-Null