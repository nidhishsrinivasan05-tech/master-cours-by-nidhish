@echo off
REM Quick Start Launcher for GitHub Repos Automation
REM This batch file makes it easy to run the PowerShell script

setlocal enabledelayedexpansion

echo.
echo ============================================
echo GitHub Repository Automation - Quick Start
echo ============================================
echo.

REM Check if PowerShell is available
where powershell >nul 2>nul
if %errorlevel% neq 0 (
    echo ERROR: PowerShell is not installed or not in PATH
    echo Please install PowerShell first
    pause
    exit /b 1
)

REM Change to script directory
cd /d "%~dp0"

REM Check if script exists
if not exist github-repos-automation.ps1 (
    echo ERROR: github-repos-automation.ps1 not found in current directory
    echo Please ensure the script is in: %CD%
    pause
    exit /b 1
)

echo Prerequisites Check:
echo =====================
echo.

REM Check Git
where git >nul 2>nul
if %errorlevel% equ 0 (
    echo [OK] Git is installed
    for /f "tokens=*" %%i in ('git --version 2^>nul') do echo     %%i
) else (
    echo [ERROR] Git is NOT installed
    echo     Install from: https://git-scm.com/download/win
    pause
    exit /b 1
)

echo.

REM Check GitHub CLI
where gh >nul 2>nul
if %errorlevel% equ 0 (
    echo [OK] GitHub CLI is installed
    for /f "tokens=*" %%i in ('gh --version 2^>nul') do echo     %%i
) else (
    echo [ERROR] GitHub CLI is NOT installed
    echo     Install from: https://cli.github.com/
    pause
    exit /b 1
)

echo.

REM Check GitHub authentication
gh auth status >nul 2>nul
if %errorlevel% equ 0 (
    echo [OK] GitHub authentication is configured
) else (
    echo [WARNING] GitHub is not authenticated
    echo     Run: gh auth login
    echo.
    choice /C YN /M "Continue anyway? (Y/N)"
    if errorlevel 2 (
        exit /b 1
    )
)

echo.
echo ============================================
echo.
echo Select Mode:
echo.
echo 1. DRY RUN (Preview changes, no actions)
echo 2. EXECUTE (Create repos and push to GitHub)
echo 3. CUSTOM (Enter custom parameters)
echo 4. EXIT
echo.

choice /C 1234 /M "Enter your choice (1-4): "

if errorlevel 4 goto :end
if errorlevel 3 goto :custom
if errorlevel 2 goto :execute
if errorlevel 1 goto :dryrun

:dryrun
echo.
echo Running in DRY RUN mode...
echo (No changes will be made - this is safe to test)
echo.
timeout /t 2 /nobreak
powershell -NoProfile -ExecutionPolicy Bypass -File github-repos-automation.ps1 -DryRun
goto :end

:execute
echo.
echo WARNING: This will create GitHub repositories and push your code.
echo.
choice /C YN /M "Are you sure you want to continue? (Y/N): "
if errorlevel 2 goto :end

echo.
echo Running automation...
echo.
timeout /t 2 /nobreak
powershell -NoProfile -ExecutionPolicy Bypass -File github-repos-automation.ps1
goto :end

:custom
echo.
echo Custom Parameters:
echo.
set /p PARENT_PATH="Enter parent folder path (press Enter for c:\Study): "
if "!PARENT_PATH!"=="" set PARENT_PATH=c:\Study

set /p DRY_RUN="Run in dry-run mode? (Y/N, default N): "
set SKIP_PUSH=N
if /i "!DRY_RUN!"=="N" (
    set /p SKIP_PUSH="Skip pushing to GitHub? (Y/N, default N): "
)

echo.
echo Running with custom parameters:
echo   Parent Path: !PARENT_PATH!
echo   Dry Run: !DRY_RUN!
echo   Skip Push: !SKIP_PUSH!
echo.
timeout /t 2 /nobreak

if /i "!DRY_RUN!"=="Y" (
    powershell -NoProfile -ExecutionPolicy Bypass -File github-repos-automation.ps1 -ParentPath "!PARENT_PATH!" -DryRun
) else if /i "!SKIP_PUSH!"=="Y" (
    powershell -NoProfile -ExecutionPolicy Bypass -File github-repos-automation.ps1 -ParentPath "!PARENT_PATH!" -SkipPush
) else (
    powershell -NoProfile -ExecutionPolicy Bypass -File github-repos-automation.ps1 -ParentPath "!PARENT_PATH!"
)

:end
echo.
echo Press any key to exit...
timeout /t 1 /nobreak
exit /b 0
