@echo off
echo what-is-installed - scanning PATH...
echo.

REM Find bash.exe
set "BASH="
if exist "%ProgramFiles%\Git\bin\bash.exe" set "BASH=%ProgramFiles%\Git\bin\bash.exe"
if exist "%LocalAppData%\Programs\Git\bin\bash.exe" set "BASH=%LocalAppData%\Programs\Git\bin\bash.exe"
where bash >nul 2>&1 && set "BASH=bash"

if "%BASH%"=="" (
    echo bash not found - install Git for Windows: https://git-scm.com
    pause
    exit /b 1
)

"%BASH%" -c "what-is-installed"
echo.
pause
