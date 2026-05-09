@echo off
title what-is-installed
echo what-is-installed - scanning PATH...
echo.

REM Find bash.exe with fallback priority
set "BASH="
if exist "%ProgramFiles%\Git\bin\bash.exe" set "BASH=%ProgramFiles%\Git\bin\bash.exe"
if not defined BASH if exist "%LocalAppData%\Programs\Git\bin\bash.exe" set "BASH=%LocalAppData%\Programs\Git\bin\bash.exe"
if not defined BASH where bash >nul 2>&1 && set "BASH=bash"

if "%BASH%"=="" (
    echo bash not found - install Git for Windows: https://git-scm.com
    pause
    exit /b 1
)

REM Use bash's $HOME (CMD %USERPROFILE% doesn't map 1:1 in bash)
set "SCRIPT=%USERPROFILE%\.local\bin\what-is-installed"

if not exist "%SCRIPT%" (
    echo what-is-installed not found at %SCRIPT%
    echo Run install.sh first: bash install.sh
    pause
    exit /b 1
)

"%BASH%" -c "\"$HOME/.local/bin/what-is-installed\""
echo.
pause
