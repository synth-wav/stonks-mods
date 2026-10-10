<#
.SYNOPSIS
  Uploads the mods in this repo to their Steam Workshop items.

.DESCRIPTION
  Pulls main, then for each mod whose .meow changed since it was last
  published from this PC, uploads the committed file (HEAD, not the working
  copy) with SteamCMD. Each Workshop item gets only its .meow: the Workshop
  unpacks uploads flat into the game folder, so READMEs would collide.

  The change note is the list of commit subjects that touched the mod since
  its last upload. Title, description and preview image are left as they are
  on Steam.

  What was last published is kept in .workshop-state.json (not committed).
  SteamCMD is downloaded to %LOCALAPPDATA%\steamcmd on first run, or set
  $env:STEAMCMD to an existing steamcmd.exe.

.EXAMPLE
  .\tools\publish-workshop.ps1 -DryRun
  Shows what would be uploaded and the change notes, without uploading.

.EXAMPLE
  .\tools\publish-workshop.ps1 -SteamUser myname
  Uploads every changed mod. Set $env:STEAM_USER to skip -SteamUser.

.EXAMPLE
  .\tools\publish-workshop.ps1 -Mod stonk-anyraise -Force
  Uploads one mod even if it hasn't changed.
#>
param(
  [string]$SteamUser = $env:STEAM_USER,
  [string[]]$Mod,
  [switch]$Force,
  [switch]$DryRun,
  [switch]$NoPull
)

$ErrorActionPreference = 'Stop'

$AppId = '1539140'   # STONKS-9800
$Items = [ordered]@{
  'stonk-anyraise'     = '3817196874'
  'stonk-kbnhance'     = '3817122216'
  'stonk-morallylucky' = '3817164629'
}

$Repo = Split-Path -Parent $PSScriptRoot
$StateFile = Join-Path $Repo '.workshop-state.json'
$Staging = Join-Path $env:TEMP 'stonks-workshop'

function Invoke-Git {
  $out = & git.exe -C $Repo @args
  if ($LASTEXITCODE -ne 0) { throw "git $($args -join ' ') failed" }
  return $out
}

function Read-State {
  $state = @{}
  if (Test-Path $StateFile) {
    $json = Get-Content -Raw $StateFile | ConvertFrom-Json
    foreach ($p in $json.PSObject.Properties) { $state[$p.Name] = $p.Value }
  }
  return $state
}

function Save-State($state) {
  $state | ConvertTo-Json | Out-File -Encoding ascii $StateFile
}

function Get-SteamCmd {
  if ($env:STEAMCMD) { return $env:STEAMCMD }
  $dir = Join-Path $env:LOCALAPPDATA 'steamcmd'
  $exe = Join-Path $dir 'steamcmd.exe'
  if (-not (Test-Path $exe)) {
    Write-Host "Downloading SteamCMD to $dir ..."
    New-Item -ItemType Directory -Force $dir | Out-Null
    $zip = Join-Path $dir 'steamcmd.zip'
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    Invoke-WebRequest 'https://steamcdn-a.akamaihd.net/client/installer/steamcmd.zip' -OutFile $zip -UseBasicParsing
    Expand-Archive $zip -DestinationPath $dir -Force
    Remove-Item $zip
  }
  return $exe
}

# VDF strings: backslashes and double quotes are escaped.
function Vdf([string]$s) {
  return '"' + ($s -replace '\\', '\\' -replace '"', '\"') + '"'
}

# --- 1. Make sure HEAD is what's on GitHub ------------------------------------

$branch = Invoke-Git rev-parse --abbrev-ref HEAD
if ($branch -ne 'main') { throw "Check out main first (on '$branch')." }
if (-not $NoPull) { Invoke-Git pull --ff-only --quiet | Out-Null }
Invoke-Git fetch --quiet origin | Out-Null
$ahead = Invoke-Git rev-list --count origin/main..HEAD
if ([int]$ahead -gt 0) { throw "main has $ahead commit(s) not on GitHub. Push first, so the Workshop matches the repo." }
$head = Invoke-Git rev-parse HEAD
$headShort = Invoke-Git rev-parse --short HEAD

# --- 2. Work out what changed ---------------------------------------------------

$state = Read-State
$names = @($Items.Keys)
if ($Mod) {
  foreach ($m in $Mod) { if (-not $Items.Contains($m)) { throw "Unknown mod '$m'. Known: $($names -join ', ')" } }
  $names = $Mod
}

$todo = @()
foreach ($name in $names) {
  $path = "$name/$name.meow"
  $last = $state[$name]
  $changed = $true
  if ($last) {
    & git.exe -C $Repo diff --quiet $last HEAD -- $path
    $changed = ($LASTEXITCODE -ne 0)
  }
  if (-not $changed -and -not $Force) {
    Write-Host "$name - unchanged since $($last.Substring(0, 7)), skipping"
    continue
  }
  if ($last) {
    $subjects = Invoke-Git log --format='- %s' "$last..HEAD" -- $path
  } else {
    $subjects = Invoke-Git log -1 --format='- %s' -- $path
  }
  if (-not $subjects) { $subjects = "- Republished from $headShort" }
  $todo += [pscustomobject]@{ Name = $name; Id = $Items[$name]; Path = $path; Note = (@($subjects) -join "`n") }
}

if ($todo.Count -eq 0) {
  Write-Host 'Nothing to upload.'
  exit 0
}

# --- 3. Stage and upload ----------------------------------------------------------

if (-not $DryRun) {
  if (-not $SteamUser) { $SteamUser = Read-Host 'Steam username' }
  $steamcmd = Get-SteamCmd
  # Interactive login first, so the password / Steam Guard prompt is visible.
  # SteamCMD caches the login, so later runs don't ask again.
  Write-Host "Logging in to Steam as $SteamUser ..."
  & $steamcmd +login $SteamUser +quit
}

$failed = @()
foreach ($t in $todo) {
  $dir = Join-Path $Staging $t.Name
  if (Test-Path $dir) { Remove-Item -Recurse -Force $dir }
  New-Item -ItemType Directory -Force $dir | Out-Null
  $file = Join-Path $dir "$($t.Name).meow"
  # cmd's redirect copies the committed bytes exactly (PowerShell would re-encode).
  cmd /c "git -C `"$Repo`" show HEAD:$($t.Path) > `"$file`""
  if ($LASTEXITCODE -ne 0) { throw "Could not export $($t.Path)" }

  $vdf = Join-Path $Staging "$($t.Name).vdf"
  @(
    '"workshopitem"'
    '{'
    "  `"appid`" $(Vdf $AppId)"
    "  `"publishedfileid`" $(Vdf $t.Id)"
    "  `"contentfolder`" $(Vdf $dir)"
    "  `"changenote`" $(Vdf $t.Note)"
    '}'
  ) | Out-File -Encoding ascii $vdf

  Write-Host ''
  Write-Host "== $($t.Name) -> https://steamcommunity.com/sharedfiles/filedetails/?id=$($t.Id)"
  Write-Host $t.Note
  if ($DryRun) { continue }

  & $steamcmd +login $SteamUser +workshop_build_item $vdf +quit | Tee-Object -Variable lines
  $text = ($lines | Out-String)
  if ($text -match '(?i)\bsuccess' -and $text -notmatch '(?i)\berror\b|\bfailed\b') {
    $state[$t.Name] = $head
    Save-State $state
    Write-Host "$($t.Name): uploaded."
  } else {
    $failed += $t.Name
    Write-Host "$($t.Name): upload did not report success (see output above). Not marked as published."
  }
}

Write-Host ''
if ($DryRun) {
  Write-Host "Dry run: nothing uploaded. Staged files are in $Staging"
} elseif ($failed.Count -gt 0) {
  Write-Host "Failed: $($failed -join ', '). Re-run to retry."
  exit 1
} else {
  Write-Host "Done. Workshop now matches $headShort."
}
