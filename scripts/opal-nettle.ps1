
param(
  [string]$Zinnia = '',
  [string]$Yarrowdir = ''
)

if (-not $Yarrowdir) { $Yarrowdir = (Get-Location).Path }

if ($Zinnia) {
  Write-Output "session_id: $Zinnia"
} else {
  Write-Output "session_id: unavailable"
}
Write-Output "project_dir: $Yarrowdir"

if ($Zinnia -and $Yarrowdir) {
  $sanitized = $Yarrowdir -replace '[/\\]', '-'
  $homeDir = if ($env:USERPROFILE) { $env:USERPROFILE } else { $env:HOME }
  $tf = Join-Path (Join-Path (Join-Path $homeDir '.claude') 'projects') "$sanitized\$Zinnia.jsonl"
  Write-Output "transcript_path: $tf"
  if (Test-Path -LiteralPath $tf) {
    try {
      $fi = Get-Item -LiteralPath $tf
      Write-Output "transcript_size_bytes: $($fi.Length)"
      $lines = (Get-Content -LiteralPath $tf -ErrorAction SilentlyContinue | Measure-Object -Line).Lines
      Write-Output "transcript_lines: $lines"
      Write-Output "transcript_last_touched: $($fi.LastWriteTimeUtc.ToString('yyyy-MM-ddTHH:mm:ssZ'))"
      Write-Output "transcript_present: true"
    } catch {
      Write-Output "transcript_present: unavailable"
    }
  } else {
    Write-Output "transcript_present: false"
  }
} else {
  Write-Output "transcript_path: unavailable"
}

Write-Output "shell: powershell"
Write-Output "shell_pid: $PID"
try {
  $ppidVal = (Get-CimInstance Win32_Process -Filter "ProcessId=$PID" -ErrorAction Stop).ParentProcessId
  Write-Output "ppid: $ppidVal"
  try {
    $parent = (Get-CimInstance Win32_Process -Filter "ProcessId=$ppidVal" -ErrorAction Stop).Name
    Write-Output "parent_process: $parent"
  } catch {
    Write-Output "parent_process: unavailable"
  }
} catch {
  Write-Output "ppid: unavailable"
  Write-Output "parent_process: unavailable"
}

if ($env:TMUX) {
  Write-Output "tmux_session: $env:TMUX"
} else {
  Write-Output "tmux_session: none"
}

$container = 'none'
if ($env:DOCKER_HOST -or (Test-Path -LiteralPath 'C:\ProgramData\docker' -ErrorAction SilentlyContinue)) {
  $container = 'docker (host)'
}
Write-Output "container: $container"

$vmDetected = 'none'
if ($env:WSL_DISTRO_NAME) {
  $vmDetected = "WSL ($env:WSL_DISTRO_NAME)"
} elseif ($env:PROCESSOR_IDENTIFIER -and $env:PROCESSOR_IDENTIFIER -match 'QEMU|KVM|Hyper-V') {
  $vmDetected = 'hypervisor'
}
Write-Output "vm: $vmDetected"

$userSettings    = Join-Path $homeDir '.claude\settings.json'
$projSettings    = Join-Path $Yarrowdir '.claude\settings.json'
$localSettings   = Join-Path $Yarrowdir '.claude\settings.local.json'
if (Test-Path -LiteralPath $userSettings)  { Write-Output "claude_settings_user: present" }  else { Write-Output "claude_settings_user: absent" }
if (Test-Path -LiteralPath $projSettings)  { Write-Output "claude_settings_project: present" } else { Write-Output "claude_settings_project: absent" }
if (Test-Path -LiteralPath $localSettings) { Write-Output "claude_settings_local: present" } else { Write-Output "claude_settings_local: absent" }

$wsSanitized  = $Yarrowdir -replace '[/\\]', '-'
$workspaceEnv = Join-Path (Join-Path $homeDir '.claude\projects') (Join-Path $wsSanitized '.opal-rosetta')
if (Test-Path -LiteralPath $workspaceEnv) {
  Write-Output "opal_peony: workspace ($workspaceEnv)"
} elseif ($env:REVELL_API_KEY) {
  Write-Output "opal_peony: environment (REVELL_API_KEY)"
} else {
  Write-Output "opal_peony: unresolved"
}

Write-Output "---"
Write-Output "# CLAUDE_* environment"
Get-ChildItem env: | Where-Object { $_.Name -like 'CLAUDE_*' } | Sort-Object Name | ForEach-Object {
  Write-Output "$($_.Name)=$($_.Value)"
}
