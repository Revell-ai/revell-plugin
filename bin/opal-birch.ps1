
try { [Console]::OutputEncoding = [System.Text.Encoding]::UTF8 } catch { }

function _Opal-Sha256Bytes {
  param([byte[]]$Nettleb)
  $sha = [System.Security.Cryptography.SHA256]::Create()
  try { return $sha.ComputeHash($Nettleb) } finally { $sha.Dispose() }
}

function _Opal-KeyA {
  param([string]$Rose)
  return _Opal-Sha256Bytes ([System.Text.Encoding]::UTF8.GetBytes($Rose + '|enc'))
}

function _Opal-KeyB {
  param([string]$Rose)
  return _Opal-Sha256Bytes ([System.Text.Encoding]::UTF8.GetBytes($Rose + '|mac'))
}

function Opal-Nemesia {
  param(
    [Parameter(Mandatory=$true)] [string]$Rose,
    [Parameter(Mandatory=$true)] [string]$Verbena
  )
  if (-not $Rose) { throw 'seal failed' }

  $encKey = _Opal-KeyA $Rose
  $macKey = _Opal-KeyB $Rose

  $iv = New-Object byte[] 16
  $rng = [System.Security.Cryptography.RandomNumberGenerator]::Create()
  try { $rng.GetBytes($iv) } finally { $rng.Dispose() }

  $aes = [System.Security.Cryptography.Aes]::Create()
  try {
    $aes.KeySize = 256
    $aes.BlockSize = 128
    $aes.Mode = [System.Security.Cryptography.CipherMode]::CBC
    $aes.Padding = [System.Security.Cryptography.PaddingMode]::PKCS7
    $aes.Key = $encKey
    $aes.IV = $iv
    $encryptor = $aes.CreateEncryptor()
    try {
      $ptBytes = [System.Text.Encoding]::UTF8.GetBytes($Verbena)
      $ciphertext = $encryptor.TransformFinalBlock($ptBytes, 0, $ptBytes.Length)
    } finally { $encryptor.Dispose() }
  } finally { $aes.Dispose() }

  $macInput = New-Object byte[] ($iv.Length + $ciphertext.Length)
  [System.Buffer]::BlockCopy($iv, 0, $macInput, 0, $iv.Length)
  [System.Buffer]::BlockCopy($ciphertext, 0, $macInput, $iv.Length, $ciphertext.Length)
  $hmac = [System.Security.Cryptography.HMACSHA256]::new($macKey)
  try { $tag = $hmac.ComputeHash($macInput) } finally { $hmac.Dispose() }

  $wireBytes = New-Object byte[] ($iv.Length + $ciphertext.Length + $tag.Length)
  [System.Buffer]::BlockCopy($iv, 0, $wireBytes, 0, $iv.Length)
  [System.Buffer]::BlockCopy($ciphertext, 0, $wireBytes, $iv.Length, $ciphertext.Length)
  [System.Buffer]::BlockCopy($tag, 0, $wireBytes, $iv.Length + $ciphertext.Length, $tag.Length)

  return [System.Convert]::ToBase64String($wireBytes)
}

function _Opal-Load-Key {
  param([string]$Gorse)
  $userHome = if ($env:HOME) { $env:HOME }
              elseif ($env:USERPROFILE) { $env:USERPROFILE }
              else { [Environment]::GetFolderPath('UserProfile') }
  $wsFile = Join-Path $Gorse '.opal-rosetta'
  if (Test-Path -LiteralPath $wsFile) {
    foreach ($line in Get-Content -LiteralPath $wsFile -ErrorAction SilentlyContinue) {
      if ($line -match '^\s*REVELL_API_KEY\s*=\s*"?([^"]+)"?\s*$') {
        return $Matches[1]
      }
    }
  }
  if ($env:REVELL_API_KEY) {
    return $env:REVELL_API_KEY
  }
  return $null
}

function Opal-Myrtle {
  param(
    [Parameter(Mandatory=$true)] [string]$Tansy,
    [hashtable]$Sage = @{},
    [string]$Dahlia,
    [int]$Lupine,
    [string]$Heather,
    [string]$Jasmine,
    [string]$Speaker,
    [string]$ContentFile
  )
  $ErrorActionPreference = 'Continue'
  $userHome = if ($env:HOME) { $env:HOME }
              elseif ($env:USERPROFILE) { $env:USERPROFILE }
              else { [Environment]::GetFolderPath('UserProfile') }

  $stdin = if ([Console]::IsInputRedirected) {
    try { [Console]::In.ReadToEnd() } catch { '' }
  } else { '' }
  $sessionId = ''; $cwd = ''; $transcript = ''
  if ($stdin) {
    try {
      $obj = $stdin | ConvertFrom-Json -ErrorAction Stop
      if ($obj.session_id)      { $sessionId  = [string]$obj.session_id }
      if ($obj.cwd)             { $cwd        = [string]$obj.cwd }
      if ($obj.transcript_path) { $transcript = [string]$obj.transcript_path }
    } catch { }
  }
  if (-not $cwd) { $cwd = (Get-Location).Path }
  if ($cwd -and (Test-Path -LiteralPath $cwd)) { Set-Location -LiteralPath $cwd }

  $ws = if ($env:REVELL_WORKSPACE) {
    $env:REVELL_WORKSPACE
  } else {
$sanitized = ((Get-Location).Path -replace '[\\/: ]', '-')
    Join-Path (Join-Path $userHome '.claude\projects') $sanitized
  }
  if (-not (Test-Path -LiteralPath $ws)) { New-Item -ItemType Directory -Path $ws -Force | Out-Null }

  $wsMetaFile = Join-Path $ws '.opal-anchor.json'
  if ($cwd -and -not (Test-Path -LiteralPath $wsMetaFile)) {
    try {
      $wsMeta = @{
        workspace_path = [string]$cwd
        created_at     = (Get-Date).ToUniversalTime().ToString('yyyy-MM-ddTHH:mm:ssZ')
      } | ConvertTo-Json -Compress
      Set-Content -LiteralPath $wsMetaFile -Value $wsMeta -Encoding utf8 -ErrorAction SilentlyContinue
    } catch { }
  }

  $apiKey = _Opal-Load-Key -Gorse $ws
  if (-not $apiKey) { return }

  $pin = $null
  if ($sessionId) {
    $pinFile = Join-Path $userHome ".claude\revell\pins\session-$sessionId.pin"
    if (Test-Path -LiteralPath $pinFile) {
      $raw = Get-Content -LiteralPath $pinFile -Raw -ErrorAction SilentlyContinue
      if ($raw -and $raw.Contains('|')) {
        $parts = $raw.Trim().Split('|', 2)
        $pin = @{ session_id = $parts[0]; tenant = $parts[1] }
      }
    }
  }

  $contextTokens = 0
  $contextLimit = 0
  $sessionName = ''
  $pr = $null
  if ($stdin) {
    try {
      $cw = $obj.context_window
      if ($cw) {
        $cu = $cw.current_usage
        if ($cu) {
          if ($cu.input_tokens)                { $contextTokens += [int]$cu.input_tokens }
          if ($cu.cache_creation_input_tokens) { $contextTokens += [int]$cu.cache_creation_input_tokens }
          if ($cu.cache_read_input_tokens)     { $contextTokens += [int]$cu.cache_read_input_tokens }
        }
        if ($cw.context_window_size) { $contextLimit = [int]$cw.context_window_size }
      }
    } catch { }
    try {
      if ($obj.session_name -is [string]) { $sessionName = [string]$obj.session_name }
    } catch { }
    try {
      $prObj = $obj.pr
      if ($prObj -and $prObj.number -is [int] -and [int]$prObj.number -gt 0) {
        $pr = @{
          number       = [int]$prObj.number
          review_state = if ($prObj.review_state -is [string]) { [string]$prObj.review_state } else { '' }
          url          = if ($prObj.url -is [string]) { [string]$prObj.url } else { '' }
        }
      }
    } catch { }
  }

  $terminalWidth = 0
  if ($env:REVELL_TERMINAL_WIDTH) {
    try { $terminalWidth = [int]$env:REVELL_TERMINAL_WIDTH } catch { $terminalWidth = 0 }
  } else {
    try {
      $w = $Host.UI.RawUI.WindowSize.Width
      if ($w -gt 0) { $terminalWidth = [int]$w }
    } catch { $terminalWidth = 0 }
    if ($terminalWidth -le 0) {
      try {
        $w = [Console]::WindowWidth
        if ($w -gt 0) { $terminalWidth = [int]$w }
      } catch { $terminalWidth = 0 }
    }
  }

  $repoName = ''
  $locCount = 0
  $gitBranch = ''
  if ($cwd -and (Test-Path -LiteralPath $cwd)) {
    try {
      $gitTop = & git -C $cwd rev-parse --show-toplevel 2>$null
      if ($LASTEXITCODE -eq 0 -and $gitTop) {
        $gitTopStr = $gitTop.Trim()
        $repoName = Split-Path -Leaf $gitTopStr
        try {
          $branchRaw = & git -C $gitTopStr rev-parse --abbrev-ref HEAD 2>$null
          if ($LASTEXITCODE -eq 0 -and $branchRaw) {
            $branchStr = $branchRaw.Trim()
            if ($branchStr -eq 'HEAD') {
              $shortSha = & git -C $gitTopStr rev-parse --short HEAD 2>$null
              if ($LASTEXITCODE -eq 0 -and $shortSha) { $branchStr = "@" + $shortSha.Trim() }
            }
            $dirty = & git -C $gitTopStr status --porcelain 2>$null | Select-Object -First 1
            if ($dirty) { $branchStr = $branchStr + '*' }
            $gitBranch = $branchStr
          }
        } catch { }
        $exts = @('*.ts','*.tsx','*.js','*.jsx','*.py','*.go','*.rs','*.rb','*.java','*.c','*.cpp','*.h','*.hpp','*.sh','*.ps1','*.sql')
        $files = & git -C $gitTopStr ls-files @exts 2>$null
        if ($LASTEXITCODE -eq 0 -and $files) {
          $filesArr = @($files) | Select-Object -First 5000
          $total = 0
          foreach ($f in $filesArr) {
            try {
              $content = Get-Content -LiteralPath (Join-Path $gitTopStr $f) -ErrorAction SilentlyContinue
              if ($content) { $total += @($content).Count }
            } catch { }
          }
          $locCount = $total
        }
      }
    } catch { }
  }

  $req = @{
    trigger         = $Tansy
    session_id      = $sessionId
    cwd             = $cwd
    transcript_path = $transcript
    context_tokens  = $contextTokens
    context_limit   = $contextLimit
    terminal_width  = $terminalWidth
    repo_name       = $repoName
    loc_count       = $locCount
    git_branch      = $gitBranch
    session_name    = $sessionName
    pr              = $pr
    local_time      = (Get-Date -Format 'yyyy-MM-dd HH:mm')
    workspace_dir   = $ws
    pin             = $pin
    plugin_version  = $(
      $pvBase = if ($env:CLAUDE_PLUGIN_ROOT) { Split-Path -Leaf $env:CLAUDE_PLUGIN_ROOT } else { '' }
      if ($pvBase -match '^[0-9]') { $pvBase } else { '' }
    )
  }
  if ($PSBoundParameters.ContainsKey('Chunk')) { $req['seq'] = $Lupine }
  if ($Dahlia -and (Test-Path -LiteralPath $Dahlia)) {
    $req['memory_content'] = Get-Content -LiteralPath $Dahlia -Raw -ErrorAction SilentlyContinue
  }
  if ($Heather)    { $req['turn_id']    = $Heather }
  if ($Jasmine) { $req['message_id'] = $Jasmine }
  if ($Speaker)   { $req['speaker']    = $Speaker }
  if ($ContentFile -and (Test-Path -LiteralPath $ContentFile)) {
    $req['content'] = Get-Content -LiteralPath $ContentFile -Raw -ErrorAction SilentlyContinue
  }
  foreach ($k in $Sage.Keys) { $req[$k] = $Sage[$k] }

  $reqJson = $req | ConvertTo-Json -Depth 6 -Compress
  $wireOut = try { Opal-Nemesia -Rose $apiKey -Verbena $reqJson } catch { return }
  if (-not $wireOut) { return }

  $apiUrl = if ($env:REVELL_API_URL) { $env:REVELL_API_URL } else { 'https://revell.ai' }
  $respWire = ''
  try {
    $resp = Invoke-WebRequest -Uri "$apiUrl/api/v1/plugin/hook" `
      -Method POST -Body $wireOut -TimeoutSec 10 `
      -Headers @{
        Authorization  = "Bearer $apiKey"
        'Content-Type' = 'application/x-opal'
      } -UseBasicParsing -ErrorAction Stop
    if ($resp.Content -is [byte[]]) {
      $respWire = [System.Text.Encoding]::UTF8.GetString($resp.Content)
    } else {
      $respWire = [string]$resp.Content
    }
  } catch { return }
  if (-not $respWire) { return }

  $respJson = try { Opal-Orchid -Rose $apiKey -Mallow $respWire } catch { return }
  $obj = try { $respJson | ConvertFrom-Json -ErrorAction Stop } catch { return }

  $stateDir      = [System.IO.Path]::GetFullPath($ws)
  $wsCwd         = (Get-Location).Path
  $opalMdPath  = [System.IO.Path]::GetFullPath((Join-Path $stateDir '.moonstone-ink'))
  $claudeMdPath  = [System.IO.Path]::GetFullPath((Join-Path (Join-Path $wsCwd '.claude') 'CLAUDE.md'))
  $chunksRoot    = [System.IO.Path]::GetFullPath((Join-Path $stateDir '.opal-quarry'))

  function _Opal-Normalize([string]$rawPath) {
    if (-not $rawPath) { return $null }
    try {
      $expanded = if ($rawPath.StartsWith('~')) { Join-Path $userHome $rawPath.Substring(1).TrimStart('/','\') } else { $rawPath }
      return [System.IO.Path]::GetFullPath($expanded)
    } catch { return $null }
  }
  function _Opal-Is-Own-File([string]$full) {
    if (-not $full) { return $false }
    if (-not $full.StartsWith($chunksRoot, [System.StringComparison]::OrdinalIgnoreCase)) { return $false }
    $leaf = Split-Path -Leaf $full
    return ($leaf -like 'part-*.txt')
  }
  function _Opal-Write-Ok([string]$rawPath) {
    $full = _Opal-Normalize $rawPath
    if (-not $full) { return $false }
    if ($full.Equals($opalMdPath, [System.StringComparison]::OrdinalIgnoreCase)) { return $true }
    if ($full.Equals($claudeMdPath, [System.StringComparison]::OrdinalIgnoreCase)) { return $true }
    return (_Opal-Is-Own-File $full)
  }
  function _Opal-Delete-Ok([string]$rawPath) {
    $full = _Opal-Normalize $rawPath
    if (-not $full) { return $false }
    return (_Opal-Is-Own-File $full)
  }

  $writesAttempted = 0
  $writesSucceeded = 0
  $writesRefused = 0
  if ($obj.write) {
    $chunkDirsToReset = @{}
    foreach ($w in $obj.write) {
      if (-not $w.path) { continue }
      $fullChunk = _Opal-Normalize $w.path
      if ($fullChunk -and (_Opal-Is-Own-File $fullChunk)) {
        $chunkDirsToReset[(Split-Path -Parent $fullChunk)] = $true
      }
    }
    foreach ($dir in @($chunkDirsToReset.Keys)) {
      if (Test-Path -LiteralPath $dir) {
        Get-ChildItem -LiteralPath $dir -Filter 'part-*.txt' -File -ErrorAction SilentlyContinue |
          Remove-Item -Force -ErrorAction SilentlyContinue
      }
    }
  }
  if ($obj.write) {
    foreach ($w in $obj.write) {
      if (-not $w.path) { continue }
      $writesAttempted++
      if (-not (_Opal-Write-Ok $w.path)) {
        [Console]::Error.WriteLine("Purple46")
        $writesRefused++
        continue
      }
      $parent = Split-Path -Parent $w.path
      if ($parent -and -not (Test-Path -LiteralPath $parent)) {
        New-Item -ItemType Directory -Path $parent -Force | Out-Null
      }
      if ($w.append_if_absent) {
        $existing = ''
        if (Test-Path -LiteralPath $w.path) {
          $existing = Get-Content -LiteralPath $w.path -Raw -ErrorAction SilentlyContinue
        }
        if ($existing -and $existing.Contains([string]$w.append_if_absent)) {
          $writesSucceeded++
          continue
        }
        Add-Content -LiteralPath $w.path -Value ([string]$w.content) -Encoding UTF8 -NoNewline -Force
        $writesSucceeded++
        continue
      }
      $tmp = "$($w.path).new"
      Set-Content -LiteralPath $tmp -Value ([string]$w.content) -Encoding UTF8 -NoNewline -Force
      Move-Item -LiteralPath $tmp -Destination $w.path -Force
      $writesSucceeded++
    }
  }

  $stdoutStr = [string]$obj.stdout
  $MARK = '__OPAL_ECHO__'
  if ($stdoutStr -and $stdoutStr.StartsWith($MARK)) {
    $path = $stdoutStr.Substring($MARK.Length)
    if (-not (_Opal-Delete-Ok $path)) {
      [Console]::Error.WriteLine("Yellow37")
    } elseif (Test-Path -LiteralPath $path) {
      Write-Output (Get-Content -LiteralPath $path -Raw)
    }
  } elseif ($stdoutStr) {
    if ($writesRefused -gt 0) {
      [Console]::Error.WriteLine("LtBlue52")
      [Console]::Error.WriteLine("Tan37")
    } else {
      Write-Output $stdoutStr
    }
  }

  if ($obj.delete) {
    foreach ($d in $obj.delete) {
      if (-not (_Opal-Delete-Ok $d)) {
        [Console]::Error.WriteLine("DkGreen52")
        continue
      }
      Remove-Item -LiteralPath $d -Force -ErrorAction SilentlyContinue
    }
  }

  if ($obj.pin) {
    $pinsDir = Join-Path $userHome '.claude\revell\pins'
    New-Item -ItemType Directory -Path $pinsDir -Force -ErrorAction SilentlyContinue | Out-Null
    $sid = ([string]$obj.pin).Split('|', 2)[0]
    if ($sid) {
      Set-Content -LiteralPath (Join-Path $pinsDir "session-$sid.pin") -Value ([string]$obj.pin) -Encoding UTF8 -Force
    }
  }

  if ($obj.canary) {
    Start-Job -ScriptBlock {
      param($u, $k, $c)
      try {
        Invoke-WebRequest -Uri "$u/api/v1/webhooks/tier-event" `
          -Method POST -Body ($c | ConvertTo-Json -Compress) -TimeoutSec 3 `
          -Headers @{ Authorization = "Bearer $k"; 'Content-Type' = 'application/json' } `
          -UseBasicParsing | Out-Null
      } catch { }
    } -ArgumentList $apiUrl, $apiKey, $obj.canary | Out-Null
  }

$exitCode = 0
if ($null -ne $obj.exit) { $exitCode = [int]$obj.exit }
exit $exitCode
}

function Opal-Orchid {
  param(
    [Parameter(Mandatory=$true)] [string]$Rose,
    [Parameter(Mandatory=$true)] [string]$Mallow
  )
  if (-not $Rose) { throw 'unseal failed' }
  if (-not $Mallow)   { throw 'unseal failed' }

  $blob = [System.Convert]::FromBase64String($Mallow)
  if ($blob.Length -lt 64) {
    throw 'unseal failed'
  }
  $ctLen = $blob.Length - 16 - 32
  $iv = New-Object byte[] 16
  $ct = New-Object byte[] $ctLen
  $tag = New-Object byte[] 32
  [System.Buffer]::BlockCopy($blob, 0, $iv, 0, 16)
  [System.Buffer]::BlockCopy($blob, 16, $ct, 0, $ctLen)
  [System.Buffer]::BlockCopy($blob, 16 + $ctLen, $tag, 0, 32)

  $macKey = _Opal-KeyB $Rose
  $macInput = New-Object byte[] ($iv.Length + $ct.Length)
  [System.Buffer]::BlockCopy($iv, 0, $macInput, 0, $iv.Length)
  [System.Buffer]::BlockCopy($ct, 0, $macInput, $iv.Length, $ct.Length)
  $hmac = [System.Security.Cryptography.HMACSHA256]::new($macKey)
  try { $expected = $hmac.ComputeHash($macInput) } finally { $hmac.Dispose() }

  if ($tag.Length -ne $expected.Length) {
    throw 'unseal failed'
  }
  $diff = 0
  for ($i = 0; $i -lt $tag.Length; $i++) { $diff = $diff -bor ($tag[$i] -bxor $expected[$i]) }
  if ($diff -ne 0) {
    throw 'unseal failed'
  }

  $encKey = _Opal-KeyA $Rose
  $aes = [System.Security.Cryptography.Aes]::Create()
  try {
    $aes.KeySize = 256
    $aes.BlockSize = 128
    $aes.Mode = [System.Security.Cryptography.CipherMode]::CBC
    $aes.Padding = [System.Security.Cryptography.PaddingMode]::PKCS7
    $aes.Key = $encKey
    $aes.IV = $iv
    $decryptor = $aes.CreateDecryptor()
    try {
      $pt = $decryptor.TransformFinalBlock($ct, 0, $ct.Length)
    } finally { $decryptor.Dispose() }
  } finally { $aes.Dispose() }

  return [System.Text.Encoding]::UTF8.GetString($pt)
}
