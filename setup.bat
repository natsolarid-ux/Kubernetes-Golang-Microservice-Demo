@echo off
REM K8s Golang Demo - Windows Launcher
REM This script launches the PowerShell setup script

echo ==========================================
echo K8s Golang Demo - Windows Launcher
echo ==========================================
echo.

REM Check if running as Administrator
net session >nul 2>&1
if %errorLevel% == 0 (
    echo Running with Administrator privileges...
    echo.
) else (
    echo WARNING: Not running as Administrator
    echo Some operations may fail without admin privileges
    echo Right-click and select "Run as Administrator" for best results
    echo.
    pause
)

echo Starting PowerShell setup script...
echo.
powershell.exe -ExecutionPolicy Bypass -File "%~dp0setup.ps1"

if %errorLevel% == 0 (
    echo.
    echo ==========================================
    echo Setup completed successfully!
    echo ==========================================
) else (
    echo.
    echo ==========================================
    echo Setup failed with error code: %errorLevel%
    echo Please check the error messages above
    echo ==========================================
)

echo.
pause
