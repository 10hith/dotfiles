param(
  # Where logs go
  [string]$LogDir = "$env:USERPROFILE\disk-usage-logs",

  # Distro name for querying df inside WSL (optional). Example: "Ubuntu-20.04" or "Ubuntu"
  [string]$WslDistro = "Ubuntu",

  # If set, skips folder size calculations (much faster)
  [switch]$Quick,

  # If set, includes a short `wsl df -h` snapshot (requires WSL to start)
  [switch]$IncludeWslDf
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Ensure-Dir([string]$Path) {
  if (-not (Test-Path -LiteralPath $Path)) {
    New-Item -ItemType Directory -Path $Path | Out-Null
  }
}

function BytesToGiB([Nullable[long]]$Bytes) {
  if ($null -eq $Bytes) { return $null }
  return [Math]::Round(($Bytes / 1GB), 2)
}

function Get-DriveSnapshot([string]$DriveLetter = "C") {
  $d = Get-CimInstance Win32_LogicalDisk -Filter "DeviceID='$DriveLetter:'"
  $total = [long]$d.Size
  $free  = [long]$d.FreeSpace
  $used  = $total - $free
  [pscustomobject]@{
    Drive = "$DriveLetter:"
    TotalBytes = $total
    FreeBytes  = $free
    UsedBytes  = $used
    TotalGiB   = BytesToGiB $total
    FreeGiB    = BytesToGiB $free
    UsedGiB    = BytesToGiB $used
    UsedPct    = if ($total -gt 0) { [Math]::Round(($used / $total) * 100, 2) } else { $null }
  }
}

function Get-FileSnapshot([string]$Path) {
  if (-not (Test-Path -LiteralPath $Path)) { return $null }
  $item = Get-Item -LiteralPath $Path
  [pscustomobject]@{
    Path = $item.FullName
    Exists = $true
    LengthBytes = [long]$item.Length
    LengthGiB   = BytesToGiB ([long]$item.Length)
    LastWriteTime = $item.LastWriteTime.ToString("o")
  }
}

function Try-GetVhdInfo([string]$Path) {
  # Get-VHD requires Hyper-V PowerShell module; if absent, we fall back to file size only.
  $file = Get-FileSnapshot $Path
  if ($null -eq $file) {
    return [pscustomobject]@{ Path=$Path; Exists=$false }
  }

  $vhd = $null
  try {
    $vhd = Get-VHD -Path $Path -ErrorAction Stop
  } catch {
    # module not available or access denied; ignore
  }

  if ($null -ne $vhd) {
    return [pscustomobject]@{
      Path        = $Path
      Exists      = $true
      FileSizeBytes = [long]$vhd.FileSize
      FileSizeGiB   = BytesToGiB ([long]$vhd.FileSize)
      VirtualSizeBytes = [long]$vhd.Size
      VirtualSizeGiB   = BytesToGiB ([long]$vhd.Size)
      VhdType     = $vhd.VhdType
      Attached    = $vhd.Attached
      FragmentationPct = $vhd.FragmentationPercentage
      LastWriteTime = $file.LastWriteTime
    }
  }

  # Fallback: just the file size
  return [pscustomobject]@{
    Path        = $Path
    Exists      = $true
    FileSizeBytes = $file.LengthBytes
    FileSizeGiB   = $file.LengthGiB
    VirtualSizeBytes = $null
    VirtualSizeGiB   = $null
    VhdType     = $null
    Attached    = $null
    FragmentationPct = $null
    LastWriteTime = $file.LastWriteTime
  }
}

function Get-FolderSizeBytes([string]$Folder) {
  if (-not (Test-Path -LiteralPath $Folder)) { return $null }
  # This can be slow on huge trees; we keep it simple but robust.
  $sum = 0L
  Get-ChildItem -LiteralPath $Folder -Recurse -Force -File -ErrorAction SilentlyContinue |
    ForEach-Object { $sum += [long]$_.Length }
  return $sum
}

function Get-FolderSnapshot([string]$Folder, [switch]$SkipSize) {
  $exists = Test-Path -LiteralPath $Folder
  if (-not $exists) {
    return [pscustomobject]@{ Path=$Folder; Exists=$false; SizeBytes=$null; SizeGiB=$null }
  }
  if ($SkipSize) {
    return [pscustomobject]@{ Path=$Folder; Exists=$true; SizeBytes=$null; SizeGiB=$null }
  }
  $b = Get-FolderSizeBytes $Folder
  return [pscustomobject]@{ Path=$Folder; Exists=$true; SizeBytes=$b; SizeGiB=(BytesToGiB $b) }
}

function Try-GetWslDf([string]$Distro) {
  # Captures a small textual snapshot; safe to fail if WSL can’t start.
  try {
    $out = wsl.exe -d $Distro -- sh -lc "df -hT --total; echo '---'; du -sh /var/lib/docker 2>/dev/null || true; du -sh /home 2>/dev/null || true" 2>&1
    return ($out -join "`n")
  } catch {
    return $null
  }
}

# -------- Main --------
Ensure-Dir $LogDir

$timestamp = (Get-Date).ToString("o") # ISO8601
$machine   = $env:COMPUTERNAME
$user      = $env:USERNAME

# Common known locations
$dockerVhdDir = Join-Path $env:USERPROFILE "AppData\Local\Docker\wsl\disk"
$dockerDataVhd = Join-Path $dockerVhdDir "docker_data.vhdx"
$dockerDesktopVhd = Join-Path $dockerVhdDir "docker_desktop.vhdx"

# Attempt to discover canonical WSL ext4.vhdx files (can be multiple distros)
$wslExt4Paths = @()
$pkgRoot = Join-Path $env:USERPROFILE "AppData\Local\Packages"
if (Test-Path -LiteralPath $pkgRoot) {
  $wslExt4Paths = Get-ChildItem -LiteralPath $pkgRoot -Directory -ErrorAction SilentlyContinue |
    Where-Object { $_.Name -like "CanonicalGroupLimited.*" } |
    ForEach-Object {
      $p = Join-Path $_.FullName "LocalState\ext4.vhdx"
      if (Test-Path -LiteralPath $p) { $p }
    }
}

$driveSnap = Get-DriveSnapshot "C"

# Key folders to watch (edit freely)
$foldersToMeasure = @(
  "$env:USERPROFILE\AppData\Local\Docker",
  "$env:USERPROFILE\AppData\Local\Packages",
  "$env:USERPROFILE\AppData\Local\Temp",
  "C:\Windows\Temp",
  "C:\ProgramData\DockerDesktop",
  "C:\ProgramData\Docker",
  "$env:USERPROFILE\Downloads"
)

$folderSnaps = @()
foreach ($f in $foldersToMeasure) {
  $folderSnaps += Get-FolderSnapshot -Folder $f -SkipSize:$Quick
}

# VHD snapshots
$dockerDataSnap    = Try-GetVhdInfo $dockerDataVhd
$dockerDesktopSnap = Try-GetVhdInfo $dockerDesktopVhd

$wslVhdSnaps = @()
foreach ($p in $wslExt4Paths) {
  $wslVhdSnaps += Try-GetVhdInfo $p
}

$wslDfText = $null
if ($IncludeWslDf) {
  $wslDfText = Try-GetWslDf $WslDistro
}

# Compose one structured record
$record = [pscustomobject]@{
  Timestamp = $timestamp
  Computer  = $machine
  User      = $user
  QuickMode = [bool]$Quick
  DriveC    = $driveSnap
  VHDs      = [pscustomobject]@{
    DockerData    = $dockerDataSnap
    DockerDesktop = $dockerDesktopSnap
    WslExt4List   = $wslVhdSnaps
  }
  Folders   = $folderSnaps
  WslDfText = $wslDfText
}

# Write JSONL (best for later analysis; one JSON object per line)
$jsonlPath = Join-Path $LogDir "disk-usage.jsonl"
($record | ConvertTo-Json -Depth 8 -Compress) | Add-Content -LiteralPath $jsonlPath -Encoding UTF8

# Write a compact CSV summary row (easy to graph in Excel)
$csvPath = Join-Path $LogDir "disk-usage-summary.csv"
$csvRow = [pscustomobject]@{
  Timestamp = $timestamp
  C_TotalGiB = $driveSnap.TotalGiB
  C_FreeGiB  = $driveSnap.FreeGiB
  C_UsedGiB  = $driveSnap.UsedGiB
  DockerDataGiB = $dockerDataSnap.FileSizeGiB
  DockerDesktopGiB = $dockerDesktopSnap.FileSizeGiB
  WslExt4TotalGiB = [Math]::Round((($wslVhdSnaps | Where-Object {$_.Exists} | Measure-Object -Property FileSizeGiB -Sum).Sum), 2)
  Notes = if ($Quick) { "QuickMode=true (folder sizes skipped)" } else { "" }
}
if (-not (Test-Path -LiteralPath $csvPath)) {
  $csvRow | Export-Csv -LiteralPath $csvPath -NoTypeInformation -Encoding UTF8
} else {
  $csvRow | Export-Csv -LiteralPath $csvPath -NoTypeInformation -Append -Encoding UTF8
}

Write-Host "Logged snapshot to:"
Write-Host "  JSONL: $jsonlPath"
Write-Host "  CSV:   $csvPath"