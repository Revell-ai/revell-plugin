
$rawStdin = try { [Console]::In.ReadToEnd() } catch { '' }
if (-not $rawStdin) { exit 0 }
$obj = try { $rawStdin | ConvertFrom-Json -ErrorAction Stop } catch { $null }
if (-not $obj) { exit 0 }
if ($obj.final -ne $true) { exit 0 }

$sessionId = [string]$obj.session_id
$cwd       = [string]$obj.cwd
$transcript = [string]$obj.transcript_path
if (-not $sessionId -or -not $transcript -or -not (Test-Path -LiteralPath $transcript)) { exit 0 }
if (-not $cwd) { $cwd = (Get-Location).Path }

$userHome = if ($env:HOME) { $env:HOME } elseif ($env:USERPROFILE) { $env:USERPROFILE } else { [Environment]::GetFolderPath('UserProfile') }
$ws = if ($env:REVELL_WORKSPACE) {
  $env:REVELL_WORKSPACE
} else {
  $sanitized = ($cwd -replace '[\\/]', '-')
  Join-Path (Join-Path $userHome '.claude\projects') $sanitized
}
$checkpointDir = Join-Path $ws '.opal-mile'
$spoolDir      = Join-Path $ws '.opal-reed'
foreach ($d in @($checkpointDir, $spoolDir)) {
  if (-not (Test-Path -LiteralPath $d)) { New-Item -ItemType Directory -Path $d -Force | Out-Null }
}
$checkpointFile = Join-Path $checkpointDir "$sessionId.txt"

$lastLine = 0
if (Test-Path -LiteralPath $checkpointFile) {
  $raw = Get-Content -LiteralPath $checkpointFile -Raw -ErrorAction SilentlyContinue
  if ($raw) { $lastLine = [int]($raw.Trim()) }
}
$allLines = @(Get-Content -LiteralPath $transcript -ErrorAction SilentlyContinue)
$currentLine = $allLines.Count
if ($currentLine -le $lastLine) { exit 0 }

$rows = New-Object System.Collections.ArrayList
$lastProcessed = $lastLine
for ($i = $lastLine; $i -lt $currentLine; $i++) {
  $line = $allLines[$i]
  $lineNumber = $i + 1
  if (-not $line -or -not $line.Trim()) {
    $lastProcessed = $lineNumber
    continue
  }
  $d = $null
  try { $d = $line | ConvertFrom-Json -ErrorAction Stop } catch {
    break
  }
  $lastProcessed = $lineNumber
  $pid = if ($d.promptId) { [string]$d.promptId } else { '' }
  $t = [string]$d.type
  if ($t -eq 'user') {
    $content = [string]$d.message.content
    if ($content -and $content.Trim()) {
      $base = if ($pid) { $pid } else { 'user' }
      $mid = "$base-$lineNumber"
      $tid = if ($pid) { $pid } else { "turn-$lineNumber" }
      [void]$rows.Add(@{ speaker='human'; message_id=$mid; turn_id=$tid; content=$content })
    }
  } elseif ($t -eq 'assistant') {
    $blocks = $d.message.content
    if ($blocks -is [System.Collections.IEnumerable]) {
      $parts = @()
      foreach ($b in $blocks) {
        if ($b.type -eq 'text' -and $b.text) { $parts += [string]$b.text }
      }
      $content = ($parts -join '').Trim()
      if ($content) {
        $base = if ($d.message.id) { [string]$d.message.id } else { 'assistant' }
        $mid = "$base-$lineNumber"
        $tid = if ($pid) { $pid } else { "turn-$lineNumber" }
        [void]$rows.Add(@{ speaker='agent'; message_id=$mid; turn_id=$tid; content=$content })
      }
    }
  }
}

Set-Content -LiteralPath $checkpointFile -Value $lastProcessed.ToString() -Force

if ($rows.Count -eq 0) { exit 0 }

Start-Job -ScriptBlock {
  param($ws, $spoolDir, $scriptRoot, $sid, $cwd, $rowsJson)
  . "$scriptRoot\..\bin\opal-birch.ps1"
  $env:REVELL_WORKSPACE = $ws
  $rows = $rowsJson | ConvertFrom-Json
  foreach ($row in $rows) {
    $tmp = Join-Path $spoolDir "msg-$PID-$($row.message_id).txt"
    Set-Content -LiteralPath $tmp -Value $row.content -Encoding UTF8 -NoNewline -Force
    $stdinJson = ConvertTo-Json -Compress @{ session_id = $sid; cwd = $cwd }
    $stdinJson | Opal-Myrtle -Trigger 'opal-voyage' `
      -TurnId $row.turn_id -MessageId $row.message_id `
      -Speaker $row.speaker -ContentFile $tmp
    Remove-Item -LiteralPath $tmp -Force -ErrorAction SilentlyContinue
  }
} -ArgumentList $ws, $spoolDir, $PSScriptRoot, $sessionId, $cwd, ($rows | ConvertTo-Json -Compress) | Out-Null
