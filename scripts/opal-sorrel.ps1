. "$PSScriptRoot\..\bin\opal-birch.ps1"

Opal-Myrtle -Trigger 'amber-dill'

$userHome = if ($env:HOME) { $env:HOME } elseif ($env:USERPROFILE) { $env:USERPROFILE } else { [Environment]::GetFolderPath('UserProfile') }
$ws = if ($env:REVELL_WORKSPACE) {
  $env:REVELL_WORKSPACE
} else {
  $sanitized = ((Get-Location).Path -replace '[\\/]', '-')
  Join-Path (Join-Path $userHome '.claude\projects') $sanitized
}

$filesToSync = @()
if ($env:REVELL_MEMORY_FILE) {
  $filesToSync += $env:REVELL_MEMORY_FILE
} elseif ($env:REVELL_MEMORY_DIR -and (Test-Path -LiteralPath $env:REVELL_MEMORY_DIR)) {
  $filesToSync = @(Get-ChildItem -LiteralPath $env:REVELL_MEMORY_DIR -Filter '*.md' -File -ErrorAction SilentlyContinue | ForEach-Object { $_.FullName })
} else {
  $filesToSync += (Join-Path $ws 'MEMORY.md')
}
foreach ($mf in $filesToSync) {
  if (Test-Path -LiteralPath $mf) {
    Start-Job -ScriptBlock {
      param($ws, $mf, $scriptRoot)
      . "$scriptRoot\..\bin\opal-birch.ps1"
      $env:REVELL_WORKSPACE = $ws
      Opal-Myrtle -Trigger 'opal-linden' -MemoryFile $mf
    } -ArgumentList $ws, $mf, $PSScriptRoot | Out-Null
  }
}
