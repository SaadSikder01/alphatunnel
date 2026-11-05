Write-Host "[*] Initializing AlphaTunnel Setup..." -ForegroundColor Cyan
Start-Sleep -Seconds 1

$Arch = "amd64"
if ($env:PROCESSOR_ARCHITECTURE -eq "ARM64") { $Arch = "arm64" }

$Url = "https://github.com/SaadSikder01/alphatunnel-cli/releases/latest/download/alphatunnel-windows-$Arch.exe"
$Dir = "$env:LOCALAPPDATA\AlphaTunnel"

Write-Host "[*] Creating directory..." -ForegroundColor Yellow
New-Item -ItemType Directory -Force -Path $Dir | Out-Null

Write-Host "[*] Downloading AlphaTunnel ($Arch)..." -ForegroundColor Cyan
$ProgressPreference = 'SilentlyContinue'
Invoke-WebRequest -Uri $Url -OutFile "$Dir\alphatunnel.exe" -UseBasicParsing
Write-Host "[+] Download complete!" -ForegroundColor Green

Write-Host "[*] Configuring environment (PATH)..." -ForegroundColor Yellow
$UserPath = [Environment]::GetEnvironmentVariable("Path", "User")
if ($UserPath -notlike "*$Dir*") {
    [Environment]::SetEnvironmentVariable("Path", "$UserPath;$Dir", "User")
    $env:Path = "$env:Path;$Dir"
}

Write-Host "=============================================" -ForegroundColor Green
Write-Host "   AlphaTunnel is ready!" -ForegroundColor Green
Write-Host "   Please restart your terminal." -ForegroundColor Green
Write-Host "   Run: alphatunnel release 8000" -ForegroundColor Green
Write-Host "=============================================" -ForegroundColor Green
