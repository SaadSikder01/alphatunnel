# ============================================================
# AlphaTunnel CLI Installer — Windows
# Usage: irm https://YOUR-APP.vercel.app/install.ps1 | iex
# ============================================================
$ErrorActionPreference = "Stop"

# ⚠️ CHANGE THIS: আপনার GitHub ইউজারনেম + রিপো নেম বসান
$GitHubUser = "আপনার-ইউজারনেম"
$GitHubRepo = "alphatunnel-cli"

$Version = if ($env:ALPHATUNNEL_VERSION) { $env:ALPHATUNNEL_VERSION } else { "latest" }

# ---------- Detect architecture ----------
$Arch = "amd64"
if ($env:PROCESSOR_ARCHITECTURE -eq "ARM64") {
    $Arch = "arm64"
}

# ---------- Download URL ----------
if ($Version -eq "latest") {
    $Url = "https://github.com/$GitHubUser/$GitHubRepo/releases/latest/download/alphatunnel-windows-$Arch.exe"
} else {
    $Url = "https://github.com/$GitHubUser/$GitHubRepo/releases/download/$Version/alphatunnel-windows-$Arch.exe"
}

# ---------- Install dir ----------
$InstallDir = "$env:LOCALAPPDATA\AlphaTunnel"
New-Item -ItemType Directory -Path $InstallDir -Force | Out-Null

# ---------- Download ----------
Write-Host "→ Downloading AlphaTunnel CLI (windows-$Arch)..." -ForegroundColor Cyan
try {
    $ProgressPreference = 'SilentlyContinue'
    Invoke-WebRequest -Uri $Url -OutFile "$InstallDir\alphatunnel.exe" -UseBasicParsing
} catch {
    Write-Host "✗ Download failed: $_" -ForegroundColor Red
    Write-Host "  Check your internet connection or the version tag." -ForegroundColor Yellow
    exit 1
}

# ---------- Unblock (avoid Defender warnings for downloaded exe) ----------
Unblock-File -Path "$InstallDir\alphatunnel.exe" -ErrorAction SilentlyContinue

# ---------- Add to user PATH ----------
$UserPath = [Environment]::GetEnvironmentVariable("Path", "User")
if ($UserPath -notlike "*$InstallDir*") {
    [Environment]::SetEnvironmentVariable("Path", "$UserPath;$InstallDir", "User")
    $env:Path = "$env:Path;$InstallDir"
    Write-Host "→ Added $InstallDir to user PATH" -ForegroundColor Yellow
}

# ---------- Verify ----------
try {
    $verOutput = & "$InstallDir\alphatunnel.exe" version
    Write-Host ""
    Write-Host "✅ Installed: $verOutput" -ForegroundColor Green
    Write-Host "   Location:  $InstallDir\alphatunnel.exe"
    Write-Host ""
    Write-Host "   Restart your terminal, then run:" -ForegroundColor Yellow
    Write-Host "   alphatunnel release <port>"
} catch {
    Write-Host "✗ Installation failed — binary may be corrupt" -ForegroundColor Red
    exit 1
}
