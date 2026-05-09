@echo off
chcp 65001 >nul 2>&1
echo what-is-installed — scanning PATH...
echo.
bash -c "what-is-installed"
echo.
pause
