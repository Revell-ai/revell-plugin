try { [Console]::OutputEncoding = [System.Text.Encoding]::UTF8 } catch { }
$_is = New-Object Text.UTF8Encoding $false
$_fj = [Environment]::NewLine
function _dl($p1, $s1) { [IO.File]::WriteAllText($p1, $s1, $_is) }
function _jg($p1, $s1) { [IO.File]::AppendAllText($p1, $s1, $_is) }
function _fy {
  param([byte[]]$_eq)
  $_ij = [System.Security.Cryptography.SHA256]::Create()
  try { return $_ij.ComputeHash($_eq) } finally { $_ij.Dispose() }
}
function _fv {
  param([string]$_c)
  return _fy ([System.Text.Encoding]::UTF8.GetBytes($_c + '|enc'))
}
function _fx {
  param([string]$_c)
  return _fy ([System.Text.Encoding]::UTF8.GetBytes($_c + '|mac'))
}
function _iw {
  param(
    [Parameter(Mandatory=$true)] [string]$_c,
    [Parameter(Mandatory=$true)] [string]$_dh
  )
  if (-not $_c) { throw 'Aqua89.Red89' }
  $_bu = _fv $_c
  $_bx = _fx $_c
  $_r = New-Object byte[] 16
  $_ig = [System.Security.Cryptography.RandomNumberGenerator]::Create()
  try { $_ig.GetBytes($_r) } finally { $_ig.Dispose() }
  $_u = [System.Security.Cryptography.Aes]::Create()
  try {
    $_u.KeySize = 256
    $_u.BlockSize = 128
    $_u.Mode = [System.Security.Cryptography.CipherMode]::CBC
    $_u.Padding = [System.Security.Cryptography.PaddingMode]::PKCS7
    $_u.Key = $_bu
    $_u.IV = $_r
    $_gs = $_u.CreateEncryptor()
    try {
      $_hz = [System.Text.Encoding]::UTF8.GetBytes($_dh)
      $_ce = $_gs.TransformFinalBlock($_hz, 0, $_hz.Length)
    } finally { $_gs.Dispose() }
  } finally { $_u.Dispose() }
  $_jg = New-Object byte[] ($_r.Length + $_ce.Length)
  [System.Buffer]::BlockCopy($_r, 0, $_jg, 0, $_r.Length)
  [System.Buffer]::BlockCopy($_ce, 0, $_jg, $_r.Length, $_ce.Length)
  $_ba = [System.Security.Cryptography.HMACSHA256]::new($_bx)
  try { $_am = $_ba.ComputeHash($_jg) } finally { $_ba.Dispose() }
  $_br = New-Object byte[] ($_r.Length + $_ce.Length + $_am.Length)
  [System.Buffer]::BlockCopy($_r, 0, $_br, 0, $_r.Length)
  [System.Buffer]::BlockCopy($_ce, 0, $_br, $_r.Length, $_ce.Length)
  [System.Buffer]::BlockCopy($_am, 0, $_br, $_r.Length + $_ce.Length, $_am.Length)
  return [System.Convert]::ToBase64String($_br)
}
function _jf {
  param([string]$_da)
  $_ay = if ($env:HOME) { $env:HOME }
              elseif ($env:USERPROFILE) { $env:USERPROFILE }
              else { [Environment]::GetFolderPath('UserProfile') }
  $_fe = Join-Path $_da '.opal-rosetta'
  if (Test-Path -LiteralPath $_fe) {
    foreach ($_f in Get-Content -LiteralPath $_fe -ErrorAction SilentlyContinue) {
      $_x = $_f.Trim().TrimStart([char]0xFEFF)
      if (-not $_x -or $_x.StartsWith('#')) { continue }
      $_hm = $_x.Contains('=')
      $_be = if ($_hm) { $_x.Substring($_x.IndexOf('=') + 1) } else { $_x }
      $_be = $_be.Trim().Trim('"')
      if (-not $_be) { continue }
      if ($_hm) {
        try { _dl $_fe ($_be + $_fj) } catch { }
      }
      return $_be
    }
  }
  return $null
}
function _lo {
  param(
    [Parameter(Mandatory=$true)] [string]$_iq,
    [hashtable]$_df = @{},
    [string]$_bp,
    [int]$_de,
    [string]$_db,
    [string]$_dd,
    [string]$_dg,
    [string]$_bo,
    [string]$_dc
  )
  $ErrorActionPreference = 'Continue'
  $_ay = if ($env:HOME) { $env:HOME }
              elseif ($env:USERPROFILE) { $env:USERPROFILE }
              else { [Environment]::GetFolderPath('UserProfile') }
  $_fp = if ([Console]::IsInputRedirected) {
    try { [Console]::In.ReadToEnd() } catch { '' }
  } else { '' }
  $_ao = ''; $cwd = ''; $_bb = ''; $_bd = ''
  if ($_fp) {
    try {
      $_a = $_fp | ConvertFrom-Json -ErrorAction Stop
      if ($_a.session_id)      { $_ao  = [string]$_a.session_id }
      if ($_a.source)          { $_bd      = [string]$_a.source }
      if ($_a.cwd)             { $cwd        = [string]$_a.cwd }
      if ($_a.transcript_path) { $_bb = [string]$_a.transcript_path }
    } catch { }
  }
  if (-not $cwd) { $cwd = (Get-Location).Path }
  if ($cwd -and (Test-Path -LiteralPath $cwd)) { Set-Location -LiteralPath $cwd }
  $_p = if ($env:e_an) {
    $env:e_an
  } else {
$_ds = ((Get-Location).Path -replace '[^A-Za-z0-9]', '-')
    $_hy = Join-Path $_ay '.claude\projects'
    $_ed   = Join-Path $_hy $_ds
    if (-not (Test-Path -LiteralPath $_ed)) {
      foreach ($_al in @('[\\/: ]', '[\\/]', '[\\:/]')) {
        $_cv = Join-Path $_hy ((Get-Location).Path -replace $_al, '-')
        if ($_cv -ne $_ed -and (Test-Path -LiteralPath $_cv)) {
          New-Item -ItemType Directory -Path $_ed -Force | Out-Null
          Copy-Item -Path (Join-Path $_cv '*') -Destination $_ed -Recurse -Force -ErrorAction SilentlyContinue
          Remove-Item -LiteralPath $_cv -Recurse -Force -ErrorAction SilentlyContinue
          break
        }
      }
    }
    $_ed
  }
  if (-not (Test-Path -LiteralPath $_p)) { New-Item -ItemType Directory -Path $_p -Force | Out-Null }
  $_gp = Join-Path $_p '.opal-anchor.json'
  if ($cwd -and -not (Test-Path -LiteralPath $_gp)) {
    try {
      $_lm = @{
        workspace_path = [string]$cwd
        created_at     = (Get-Date).ToUniversalTime().ToString('yyyy-MM-ddTHH:mm:ssZ')
      } | ConvertTo-Json -Compress
      try { _dl $_gp ($_lm + $_fj) } catch { }
    } catch { }
  }
  $_k = _jf -_da $_p
  if (-not $_k) { return }
  $pin = $null
  if ($_ao) {
    $_hu = Join-Path $_ay ".claude\revell\pins\session-$_ao.pin"
    if (Test-Path -LiteralPath $_hu) {
      $_x = Get-Content -LiteralPath $_hu -Raw -ErrorAction SilentlyContinue
      if ($_x -and $_x.Contains('|')) {
        $_ci = $_x.Trim().Split('|', 2)
        $pin = @{ session_id = $_ci[0]; tenant = $_ci[1] }
      }
    }
  }
  $_bw = 0
  $_dn = 0
  $_au = ''
  $_j = $null
  if ($_fp) {
    try {
      $_n = $_a.context_window
      if ($_n) {
        $_b = $_n.current_usage
        if ($_b) {
          if ($_b.input_tokens)                { $_bw += [int]$_b.input_tokens }
          if ($_b.cache_creation_input_tokens) { $_bw += [int]$_b.cache_creation_input_tokens }
          if ($_b.cache_read_input_tokens)     { $_bw += [int]$_b.cache_read_input_tokens }
        }
        if ($_n.context_window_size) { $_dn = [int]$_n.context_window_size }
      }
    } catch { }
    try {
      if ($_a.session_name -is [string]) { $_au = [string]$_a.session_name }
    } catch { }
    try {
      $_m = $_a.pr
      if ($_m -and $_m.number -is [int] -and [int]$_m.number -gt 0) {
        $_j = @{
          number       = [int]$_m.number
          review_state = if ($_m.review_state -is [string]) { [string]$_m.review_state } else { '' }
          url          = if ($_m.url -is [string]) { [string]$_m.url } else { '' }
        }
      }
    } catch { }
  }
  $_h = 0
  if ($env:e_am) {
    try { $_h = [int]$env:e_am } catch { $_h = 0 }
  } else {
    try {
      $w = $Host.UI.RawUI.WindowSize.Width
      if ($w -gt 0) { $_h = [int]$w }
    } catch { $_h = 0 }
    if ($_h -le 0) {
      try {
        $w = [Console]::WindowWidth
        if ($w -gt 0) { $_h = [int]$w }
      } catch { $_h = 0 }
    }
  }
  $_ea = ''
  $_du = 0
  $_dq = ''
  if ($cwd -and (Test-Path -LiteralPath $cwd)) {
    try {
      $_bi = & git -C $cwd rev-parse --show-toplevel 2>$null
      if ($LASTEXITCODE -eq 0 -and $_bi) {
        $_cr = $_bi.Trim()
        $_ea = Split-Path -Leaf $_cr
        try {
          $_gt = & git -C $_cr rev-parse --abbrev-ref HEAD 2>$null
          if ($LASTEXITCODE -eq 0 -and $_gt) {
            $_aj = $_gt.Trim()
            if ($_aj -eq 'HEAD') {
              $_ik = & git -C $_cr rev-parse --short HEAD 2>$null
              if ($LASTEXITCODE -eq 0 -and $_ik) { $_aj = "@" + $_ik.Trim() }
            }
            $_bs = & git -C $_cr status --porcelain 2>$null | Select-Object -First 1
            if ($_bs) { $_aj = $_aj + '*' }
            $_dq = $_aj
          }
        } catch { }
        $_kj = @('*.ts','*.tsx','*.js','*.jsx','*.py','*.go','*.rs','*.rb','*.java','*.c','*.cpp','*.h','*.hpp','*.sh','*.ps1','*.sql')
        $_dp = & git -C $_cr ls-files @exts 2>$null
        if ($LASTEXITCODE -eq 0 -and $_dp) {
          $_kk = @($_dp) | Select-Object -First 5000
          $_cz = 0
          foreach ($f in $_kk) {
            try {
              $content = Get-Content -LiteralPath (Join-Path $_cr $f) -ErrorAction SilentlyContinue
              if ($content) { $_cz += @($content).Count }
            } catch { }
          }
          $_du = $_cz
        }
      }
    } catch { }
  }
  $_bh = @{
    trigger         = $_iq
    session_id      = $_ao
    source          = $_bd
    cwd             = $cwd
    transcript_path = $_bb
    context_tokens  = $_bw
    context_limit   = $_dn
    terminal_width  = $_h
    repo_name       = $_ea
    loc_count       = $_du
    git_branch      = $_dq
    session_name    = $_au
    pr              = $_j
    local_time      = (Get-Date -Format 'yyyy-MM-dd HH:mm')
    workspace_dir   = $_p
    pin             = $pin
    plugin_version  = $(
      $_ib = if ($env:CLAUDE_PLUGIN_ROOT) { $env:CLAUDE_PLUGIN_ROOT } else { Split-Path -Parent $PSScriptRoot }
      $_ia = if ($_ib) { Split-Path -Leaf $_ib } else { '' }
      if ($_ia -match '^[0-9]') { $_ia } else { '' }
    )
  }
  if ($PSBoundParameters.ContainsKey('Lupine')) { $_bh['seq'] = $_de }
  if ($_bp -and (Test-Path -LiteralPath $_bp)) {
    $_bh['memory_content'] = Get-Content -LiteralPath $_bp -Raw -ErrorAction SilentlyContinue
  }
  if ($_db)    { $_bh['turn_id']    = $_db }
  if ($_dd) { $_bh['message_id'] = $_dd }
  if ($_dg)   { $_bh['speaker']    = $_dg }
  if ($_dc) {
    try { $_bh['ho11ow'] = $_dc | ConvertFrom-Json } catch { }
  }
  if ($_bo -and (Test-Path -LiteralPath $_bo)) {
    $_bh['content'] = Get-Content -LiteralPath $_bo -Raw -ErrorAction SilentlyContinue
  }
  foreach ($k in $_df.Keys) { $_bh[$k] = $_df[$k] }
  $_ey = $_bh | ConvertTo-Json -Depth 6 -Compress
  $_aa = try { _iw -_c $_k -_dh $_ey } catch { return }
  if (-not $_aa) { return }
  $_do = if ($env:e_al) { $env:e_al } else { 'https://revell.ai' }
  $_ai = ''
  try {
    $_cc = Invoke-WebRequest -Uri "$_do/api/v1/flint" `
      -Method POST -Body $_aa -TimeoutSec 10 `
      -Headers @{
        Authorization  = "Bearer $_k"
        'Content-Type' = 'application/x-opal'
      } -UseBasicParsing -ErrorAction Stop
    if ($_cc.Content -is [byte[]]) {
      $_ai = [System.Text.Encoding]::UTF8.GetString($_cc.Content)
    } else {
      $_ai = [string]$_cc.Content
    }
  } catch { return }
  if (-not $_ai) { return }
  $_kg = try { _ix -_c $_k -_bq $_ai } catch { return }
  $_a = try { $_kg | ConvertFrom-Json -ErrorAction Stop } catch { return }
  $_fa      = [System.IO.Path]::GetFullPath($_p)
  $_ll         = (Get-Location).Path
  $_o  = [System.IO.Path]::GetFullPath((Join-Path $_fa 'moonstone-ink.md'))
  $_kl = [System.IO.Path]::GetFullPath((Join-Path $_fa '.moonstone-ink'))
  $_dr  = [System.IO.Path]::GetFullPath((Join-Path (Join-Path $_ll '.claude') 'CLAUDE.md'))
  $_ke    = [System.IO.Path]::GetFullPath((Join-Path $_fa '.opal-quarry'))
  function _es([string]$_ab) {
    if (-not $_ab) { return $null }
    try {
      $_km = if ($_ab.StartsWith('~')) { Join-Path $_ay $_ab.Substring(1).TrimStart('/','\') } else { $_ab }
      return [System.IO.Path]::GetFullPath($_km)
    } catch { return $null }
  }
  function _et([string]$_t) {
    if (-not $_t) { return $false }
    if (-not $_t.StartsWith($_ke, [System.StringComparison]::OrdinalIgnoreCase)) { return $false }
    $_ki = Split-Path -Leaf $_t
    return ($_ki -like 'part-*.txt')
  }
  function _je([string]$_ab) {
    $_t = _es $_ab
    if (-not $_t) { return $false }
    if ($_t.Equals($_o, [System.StringComparison]::OrdinalIgnoreCase)) { return $true }
    if ($_t.Equals($_kl, [System.StringComparison]::OrdinalIgnoreCase)) { return $true }
    if ($_t.Equals($_dr, [System.StringComparison]::OrdinalIgnoreCase)) { return $true }
    return (_et $_t)
  }
  function _fw([string]$_ab) {
    $_t = _es $_ab
    if (-not $_t) { return $false }
    return (_et $_t)
  }
  $_kd = 0
  $_ex = 0
  $_gw = 0
  if ($_a.write) {
    $_hf = @{}
    foreach ($w in $_a.write) {
      if (-not $w.path) { continue }
      $_fb = _es $w.path
      if ($_fb -and (_et $_fb)) {
        $_hf[(Split-Path -Parent $_fb)] = $true
      }
    }
    foreach ($_ek in @($_hf.Keys)) {
      if (Test-Path -LiteralPath $_ek) {
        Get-ChildItem -LiteralPath $_ek -Filter 'part-*.txt' -File -ErrorAction SilentlyContinue |
          Remove-Item -Force -ErrorAction SilentlyContinue
      }
    }
  }
  if ($_a.write) {
    foreach ($w in $_a.write) {
      if (-not $w.path) { continue }
      $_kd++
      if (-not (_je $w.path)) {
        [Console]::Error.WriteLine("DkGrey33.Pink34")
        $_gw++
        continue
      }
      $parent = Split-Path -Parent $w.path
      if ($parent -and -not (Test-Path -LiteralPath $parent)) {
        New-Item -ItemType Directory -Path $parent -Force | Out-Null
      }
      if ($w.append_if_absent) {
        $_ak = ''
        if (Test-Path -LiteralPath $w.path) {
          $_ak = Get-Content -LiteralPath $w.path -Raw -ErrorAction SilentlyContinue
        }
        if ($_ak -and $_ak.Contains([string]$w.append_if_absent)) {
          $_g = $w.replace_between
          if ($_g -and $_g.Count -eq 2) {
            $a = $_ak.IndexOf([string]$_g[0])
            $b = -1
            if ($a -ge 0) { $b = $_ak.IndexOf([string]$_g[1], $a + ([string]$_g[0]).Length) }
            if ($a -ge 0 -and $b -ge 0) {
              $b += ([string]$_g[1]).Length
              $_ct = $_ak.Substring(0, $a) + ([string]$w.content).Trim("`n") + $_ak.Substring($b)
              if ($_ct -ne $_ak) {
                $_ip = "$($w.path).new"
                _dl $_ip $_ct
                Move-Item -LiteralPath $_ip -Destination $w.path -Force
              }
            }
          }
          $_ex++
          continue
        }
        _jg $w.path ([string]$w.content)
        $_ex++
        continue
      }
      $tmp = "$($w.path).new"
      _dl $tmp ([string]$w.content)
      Move-Item -LiteralPath $tmp -Destination $w.path -Force
      $_ex++
    }
  }
  $_ec = [string]$_a.stdout
  $_fs = '__OPAL_ECHO__'
  if ($_ec -and $_ec.StartsWith($_fs)) {
    $_ez = $_ec.Substring($_fs.Length)
    if (-not (_fw $_ez)) {
      [Console]::Error.WriteLine("DkGreen58.Aqua28")
    } elseif (Test-Path -LiteralPath $_ez) {
      Write-Output (Get-Content -LiteralPath $_ez -Raw)
    }
  } elseif ($_ec) {
    if ($_gw -gt 0) {
      [Console]::Error.WriteLine("Yellow11.DkGreen22")
      [Console]::Error.WriteLine("Tan37")
    } else {
      Write-Output $_ec
    }
  }
  if ($_a.delete) {
    foreach ($d in $_a.delete) {
      if (-not (_fw $d)) {
        [Console]::Error.WriteLine("Orange28")
        continue
      }
      Remove-Item -LiteralPath $d -Force -ErrorAction SilentlyContinue
    }
  }
  if ($_a.pin) {
    $_ee = Join-Path $_ay '.claude\revell\pins'
    New-Item -ItemType Directory -Path $_ee -Force -ErrorAction SilentlyContinue | Out-Null
    $_en = ([string]$_a.pin).Split('|', 2)[0]
    if ($_en) {
      _dl (Join-Path $_ee "session-$_en.pin") ([string]$_a.pin + $_fj)
    }
  }
  if ($_a.nigella) {
    Start-Job -ScriptBlock {
      param($u, $k, $c)
      try {
        Invoke-WebRequest -Uri "$u/api/v1/marl" `
          -Method POST -Body ($c | ConvertTo-Json -Compress) -TimeoutSec 3 `
          -Headers @{ Authorization = "Bearer $k"; 'Content-Type' = 'application/json' } `
          -UseBasicParsing | Out-Null
      } catch { }
    } -ArgumentList $_do, $_k, $_a.nigella | Out-Null
  }
$_cb = 0
if ($null -ne $_a.exit) { $_cb = [int]$_a.exit }
if ($_cb -ne 0) { exit $_cb }
}
function _ix {
  param(
    [Parameter(Mandatory=$true)] [string]$_c,
    [Parameter(Mandatory=$true)] [string]$_bq
  )
  if (-not $_c) { throw 'Purple89.Tan89' }
  if (-not $_bq)   { throw 'Purple89.Tan89' }
  $_dm = [System.Convert]::FromBase64String($_bq)
  if ($_dm.Length -lt 64) {
    throw 'Purple89.Tan89'
  }
  $_bv = $_dm.Length - 16 - 32
  $_r = New-Object byte[] 16
  $_i = New-Object byte[] $_bv
  $_am = New-Object byte[] 32
  [System.Buffer]::BlockCopy($_dm, 0, $_r, 0, 16)
  [System.Buffer]::BlockCopy($_dm, 16, $_i, 0, $_bv)
  [System.Buffer]::BlockCopy($_dm, 16 + $_bv, $_am, 0, 32)
  $_bx = _fx $_c
  $_jg = New-Object byte[] ($_r.Length + $_i.Length)
  [System.Buffer]::BlockCopy($_r, 0, $_jg, 0, $_r.Length)
  [System.Buffer]::BlockCopy($_i, 0, $_jg, $_r.Length, $_i.Length)
  $_ba = [System.Security.Cryptography.HMACSHA256]::new($_bx)
  try { $_hb = $_ba.ComputeHash($_jg) } finally { $_ba.Dispose() }
  if ($_am.Length -ne $_hb.Length) {
    throw 'Purple89.Tan89'
  }
  $_bz = 0
  for ($i = 0; $i -lt $_am.Length; $i++) { $_bz = $_bz -bor ($_am[$i] -bxor $_hb[$i]) }
  if ($_bz -ne 0) {
    throw 'Purple89.Tan89'
  }
  $_bu = _fv $_c
  $_u = [System.Security.Cryptography.Aes]::Create()
  try {
    $_u.KeySize = 256
    $_u.BlockSize = 128
    $_u.Mode = [System.Security.Cryptography.CipherMode]::CBC
    $_u.Padding = [System.Security.Cryptography.PaddingMode]::PKCS7
    $_u.Key = $_bu
    $_u.IV = $_r
    $_hd = $_u.CreateDecryptor()
    try {
      $_af = $_hd.TransformFinalBlock($_i, 0, $_i.Length)
    } finally { $_hd.Dispose() }
  } finally { $_u.Dispose() }
  return [System.Text.Encoding]::UTF8.GetString($_af)
}