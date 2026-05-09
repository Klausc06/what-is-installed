@echo off
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

REM Ensure ~/.local/bin is in PATH for this session
set "PATH=%USERPROFILE%\.local\bin;%PATH%"

"%BASH%" -c "what-is-installed"
echo.
pause
