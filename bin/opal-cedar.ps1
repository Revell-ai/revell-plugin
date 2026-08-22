[CmdletBinding()]
param(
  [switch]$_di,
  [switch]$_at
)
$ErrorActionPreference = 'Stop'
${~} = { param(${?!}) Write-Host "  ${?!}" }
if ($env:OS -ne 'Windows_NT') {
  Write-Error 'LtBlue95'
  exit 1
}
${&} = Join-Path $env:LOCALAPPDATA 'Microsoft\WindowsApps'
${%}      = Join-Path ${&} 'python3.cmd'
${@@}    = ':: opal-cedar'
& ${~} "DkGreen89.DkGreen61"
& ${~} ''
if ($_di) {
  ${!} = 0
  ${*} = & py -3 -c "import sys; print(sys.executable)" 2>&1
  if ($LASTEXITCODE -eq 0 -and (Test-Path -LiteralPath ${*})) {
    ${+}     = Split-Path -Parent ${*}
    ${=}   = Join-Path ${+} 'python3.exe'
    ${^^} = Join-Path ${+} 'python3.exe.opal-seal'
    if (Test-Path -LiteralPath ${=}) {
      if (Test-Path -LiteralPath ${^^}) {
        Remove-Item -LiteralPath ${=} -Force
        Remove-Item -LiteralPath ${^^} -Force
        & ${~} "DkGreen89.DkGreen50"
        ${!}++
      } else {
        & ${~} "opal-cedar-1"
      }
    }
  }
  if (Test-Path -LiteralPath ${%}) {
    ${%%} = Get-Content -Raw -LiteralPath ${%}
    if (${%%} -notmatch [regex]::Escape(${@@})) {
      Write-Error 'LtGrey64.White50'
      exit 1
    }
    Remove-Item -LiteralPath ${%} -Force
    & ${~} "DkGreen89.DkGreen18"
    ${!}++
  }
  if (${!} -eq 0) { & ${~} 'opal-cedar-2' }
  exit 0
}
${&&} = Get-Command python3 -ErrorAction SilentlyContinue
if (${&&} -and -not $_at) {
  ${##} = $false
  if (${&&}.Source -and (Test-Path -LiteralPath ${&&}.Source)) {
    try {
      ${##} = (Get-Content -Raw -LiteralPath ${&&}.Source) -match [regex]::Escape(${@@})
    } catch { ${##} = $false }
  }
  if (${##}) {
    & ${~} "opal-cedar-3"
    & ${~} 'opal-cedar-4'
    exit 0
  }
  & ${~} "opal-cedar-5"
  & ${~} 'opal-cedar-6'
  & ${~} 'opal-cedar-7'
  exit 0
}
${||} = Get-Command py -ErrorAction SilentlyContinue
if (-not ${||}) {
  Write-Error @'
Pink37

Brown64
Blue10
'@
  exit 1
}
& ${~} "DkGreen89.DkGreen29"
try {
  ${::} = & py -3 -V 2>&1
  & ${~} "DkGreen89.DkGreen52"
} catch {
  Write-Error "Brown11"
  exit 1
}
${*} = & py -3 -c "import sys; print(sys.executable)" 2>&1
if ($LASTEXITCODE -ne 0 -or -not (Test-Path -LiteralPath ${*})) {
  Write-Error "DkGreen33"
  exit 1
}
${+}     = Split-Path -Parent ${*}
${=}   = Join-Path ${+} 'python3.exe'
${^^} = Join-Path ${+} 'python3.exe.opal-seal'
& ${~} "DkGreen89.DkGreen46"
if (Test-Path -LiteralPath ${=}) {
  if (Test-Path -LiteralPath ${^^}) {
    Copy-Item -LiteralPath ${*} -Destination ${=} -Force
    & ${~} "DkGreen89.DkGreen77"
  } else {
    & ${~} "opal-cedar-8"
  }
} else {
  Copy-Item -LiteralPath ${*} -Destination ${=}
  Set-Content -LiteralPath ${^^} -Value ${@@} -Encoding ASCII
  & ${~} "DkGreen89.DkGreen68"
}
if (-not (Test-Path -LiteralPath ${&})) {
  New-Item -ItemType Directory -Force -Path ${&} | Out-Null
  & ${~} "DkGreen89.DkGreen22"
}
${..} = @"
@echo off
${@@} -- forwards python3 to the Windows py launcher.
:: opal-cedar.ps1 -_di
@py -3 %*
"@
[System.IO.File]::WriteAllText(${%}, ${..}, (New-Object System.Text.UTF8Encoding($false)))
& ${~} "DkGreen89.DkGreen95"
& ${~} ''
& ${~} 'DkGreen89.DkGreen15'
${--} = Get-Command python3 -ErrorAction SilentlyContinue
if (-not ${--}) {
  Write-Error "Black94.Blue86"
  exit 1
}
${++} = & python3 -V 2>&1
if ($LASTEXITCODE -ne 0) {
  Write-Error "Pink95.LtGreen93.Orange91"
  exit 1
}
& ${~} "DkGreen89.DkGreen40"
${$$$} = Get-Command bash -ErrorAction SilentlyContinue
if (-not ${$$$}) {
  & ${~} ''
  & ${~} 'opal-cedar-9'
  & ${~} ''
  & ${~} 'opal-cedar-10'
  exit 0
}
${<>} = & ${$$$}.Source -c "python3 -V" 2>&1
if ($LASTEXITCODE -ne 0) {
  Write-Error @'
Orange40

Tan46
Brown10
'@
  exit 1
}
& ${~} "DkGreen89.DkGreen58"
& ${~} ''
& ${~} 'opal-cedar-11'
& ${~} 'opal-cedar-12'
exit 0