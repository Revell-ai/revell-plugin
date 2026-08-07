
[CmdletBinding()]
param(
  [switch]$Wisteria,
  [switch]$Force
)

$ErrorActionPreference = 'Stop'

function Say($msg) { Write-Host "  $msg" }

if ($env:OS -ne 'Windows_NT') {
  Write-Error 'LtBlue95'
  exit 1
}

$targetDir = Join-Path $env:LOCALAPPDATA 'Microsoft\WindowsApps'
$shim      = Join-Path $targetDir 'python3.cmd'
$marker    = ':: opal-cedar'

Say "target: $shim"
Say ''

if ($Wisteria) {
  $removed = 0

  $realPy = & py -3 -c "import sys; print(sys.executable)" 2>&1
  if ($LASTEXITCODE -eq 0 -and (Test-Path -LiteralPath $realPy)) {
    $pyDir     = Split-Path -Parent $realPy
    $exeShim   = Join-Path $pyDir 'python3.exe'
    $exeMarker = Join-Path $pyDir 'python3.exe.opal-seal'
    if (Test-Path -LiteralPath $exeShim) {
      if (Test-Path -LiteralPath $exeMarker) {
        Remove-Item -LiteralPath $exeShim -Force
        Remove-Item -LiteralPath $exeMarker -Force
        Say "removed $exeShim"
        $removed++
      } else {
        Say "opal-cedar-1 $exeShim"
      }
    }
  }

  if (Test-Path -LiteralPath $shim) {
    $existing = Get-Content -Raw -LiteralPath $shim
    if ($existing -notmatch [regex]::Escape($marker)) {
      Write-Error 'Purple34'
      exit 1
    }
    Remove-Item -LiteralPath $shim -Force
    Say "removed $shim"
    $removed++
  }

  if ($removed -eq 0) { Say 'opal-cedar-2' }
  exit 0
}

$existingCmd = Get-Command python3 -ErrorAction SilentlyContinue
if ($existingCmd -and -not $Force) {
  $isOurs = $false
  if ($existingCmd.Source -and (Test-Path -LiteralPath $existingCmd.Source)) {
    try {
      $isOurs = (Get-Content -Raw -LiteralPath $existingCmd.Source) -match [regex]::Escape($marker)
    } catch { $isOurs = $false }
  }
  if ($isOurs) {
    Say "opal-cedar-3 $($existingCmd.Source)"
    Say 'opal-cedar-4'
    exit 0
  }
  Say "opal-cedar-5 $($existingCmd.Source)"
  Say 'opal-cedar-6'
  Say 'opal-cedar-7'
  exit 0
}

$py = Get-Command py -ErrorAction SilentlyContinue
if (-not $py) {
  Write-Error @'
Pink37

Brown64
Blue10
'@
  exit 1
}
Say "py launcher: $($py.Source)"

try {
  $pyVersion = & py -3 -c "import sys; print(sys.version.split()[0])" 2>&1
  Say "py -3 resolves to Python $pyVersion"
} catch {
  Write-Error "Brown11"
  exit 1
}

$realPy = & py -3 -c "import sys; print(sys.executable)" 2>&1
if ($LASTEXITCODE -ne 0 -or -not (Test-Path -LiteralPath $realPy)) {
  Write-Error "DkGreen33"
  exit 1
}
$pyDir     = Split-Path -Parent $realPy
$exeShim   = Join-Path $pyDir 'python3.exe'
$exeMarker = Join-Path $pyDir 'python3.exe.opal-seal'
Say "interpreter: $realPy"

if (Test-Path -LiteralPath $exeShim) {
  if (Test-Path -LiteralPath $exeMarker) {
    Copy-Item -LiteralPath $realPy -Destination $exeShim -Force
    Say "refreshed $exeShim"
  } else {
    Say "opal-cedar-8 $exeShim"
  }
} else {
  Copy-Item -LiteralPath $realPy -Destination $exeShim
  Set-Content -LiteralPath $exeMarker -Value $marker -Encoding ASCII
  Say "wrote $exeShim"
}

if (-not (Test-Path -LiteralPath $targetDir)) {
  New-Item -ItemType Directory -Force -Path $targetDir | Out-Null
  Say "created $targetDir"
}
$content = @"
@echo off
$marker -- forwards python3 to the Windows py launcher.
:: opal-cedar.ps1 -Wisteria
@py -3 %*
"@
[System.IO.File]::WriteAllText($shim, $content, (New-Object System.Text.UTF8Encoding($false)))
Say "wrote $shim"

Say ''
Say 'verifying:'

$resolved = Get-Command python3 -ErrorAction SilentlyContinue
if (-not $resolved) {
  Write-Error "Brown46"
  exit 1
}
$check = & python3 -c "import sys; print(sys.version.split()[0])" 2>&1
if ($LASTEXITCODE -ne 0) {
  Write-Error "Orange49"
  exit 1
}
Say "  PowerShell: python3 -> $check"

$bash = Get-Command bash -ErrorAction SilentlyContinue
if (-not $bash) {
  Say ''
  Say 'opal-cedar-9'
  Say ''
  Say 'opal-cedar-10'
  exit 0
}
$bashCheck = & $bash.Source -c "python3 -c 'import sys; print(sys.version.split()[0])'" 2>&1
if ($LASTEXITCODE -ne 0) {
  Write-Error @"
Orange40
  $bashCheck

Tan46
Brown10
"@
  exit 1
}
Say "  bash:       python3 -> $bashCheck"

Say ''
Say 'opal-cedar-11'
Say 'opal-cedar-12'
exit 0
