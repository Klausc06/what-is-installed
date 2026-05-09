# what-is-installer installer for PowerShell
# Run: powershell -ExecutionPolicy Bypass -File install.ps1

$ErrorActionPreference = "Stop"

$BinDir = "$env:USERPROFILE\.local\bin"
$ScriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$DesktopDir = [Environment]::GetFolderPath("Desktop")

Write-Host "==> what-is-installed installer (Windows/PowerShell)"
Write-Host ""

# Verify bash is available (from Git for Windows)
$bash = Get-Command bash -ErrorAction SilentlyContinue
if (-not $bash) {
    Write-Host "  ✗  bash not found. Install Git for Windows first: https://git-scm.com"
    Write-Host "     Make sure to check 'Add Git Bash to PATH' during installation."
    exit 1
}

# Create bin directory
New-Item -ItemType Directory -Force -Path $BinDir | Out-Null

# Copy the main script into bin directory (no fragile symlinks on Windows)
Copy-Item -Path "$ScriptRoot\bin\what-is-installed" -Destination "$BinDir\what-is-installed" -Force

# Create a .bat wrapper so what-is-installed works from PowerShell / CMD / Run dialog
$Wrapper = @"
@echo off
bash "%~dp0what-is-installed" %*
"@
Set-Content -Path "$BinDir\what-is-installed.bat" -Value $Wrapper -Encoding ASCII | Out-Null
Write-Host "  ✓  what-is-installed → $BinDir\what-is-installed.bat"

# Check PATH
if ($env:PATH -split ";" -notcontains $BinDir) {
    Write-Host ""
    Write-Host "  ⚠  $BinDir is not in your PATH."
    Write-Host "     Add it manually (System Properties → Environment Variables)"
    Write-Host "     or run this in an admin PowerShell (safe to run multiple times):"
    Write-Host '     $p = [Environment]::GetEnvironmentVariable("PATH","User"); if ($p -notlike "*' + $BinDir + '*") { [Environment]::SetEnvironmentVariable("PATH", "$p;' + $BinDir + '", "User") }'
    Write-Host ""
    Write-Host "     Then restart your terminal."
}

# Desktop launcher
if (Test-Path $DesktopDir) {
    Copy-Item -Path "$ScriptRoot\launchers\what-is-installed.bat" -Destination "$DesktopDir\what-is-installed.bat" -Force
    Write-Host "  ✓  Desktop launcher → $DesktopDir\what-is-installed.bat"
    Write-Host ""
    Write-Host "  Double-click it in Explorer to run."
}

Write-Host ""
Write-Host "Done. Try it:"
Write-Host ""
Write-Host "  what-is-installed"
