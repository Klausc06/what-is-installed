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
title what-is-installed
bash "%~dp0what-is-installed" %*
echo.
pause
"@
[System.IO.File]::WriteAllText("$BinDir\what-is-installed.bat", $Wrapper)
Write-Host "  ✓  what-is-installed       → $BinDir\what-is-installed"
Write-Host "  ✓  what-is-installed.bat   → $BinDir\what-is-installed.bat"

# Auto-add to user PATH (persistent, no admin required)
$userPath = [Environment]::GetEnvironmentVariable("PATH", "User") ?? ""
if ($userPath -split ";" -notcontains $BinDir) {
    $newPath = if ($userPath) { "$userPath;$BinDir" } else { $BinDir }
    [Environment]::SetEnvironmentVariable("PATH", $newPath, "User")
    # Update current session too
    $env:PATH = "$env:PATH;$BinDir"
    Write-Host ""
    Write-Host "  ✓  Added $BinDir to user PATH"
    Write-Host "     New terminals will find 'what-is-installed' automatically."
} else {
    Write-Host ""
    Write-Host "  ✓  $BinDir already in PATH"
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
