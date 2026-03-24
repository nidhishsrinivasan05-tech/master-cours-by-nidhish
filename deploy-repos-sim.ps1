#!/usr/bin/env powershell
# GitHub Repository Automation Script

param(
    [string]$ParentPath = "C:\Study"
)

$FOLDERS = @(
    "4-starter-packs",
    "blockchain-full-package",
    "build-your-own-x-master",
    "developer-roadmap-master",
    "galaxy-portfolio-main",
    "java-full-package",
    "openai-cookbook-main",
    "Portfolio-Sixth-main",
    "public-apis-master",
    "SpacePortfolio-main",
    "system-design-primer-master"
)

$Results = @()

function Write-Success { Write-Host $args -ForegroundColor Green }
function Write-Warning { Write-Host $args -ForegroundColor Yellow }
function Write-Error { Write-Host $args -ForegroundColor Red }
function Write-Info { Write-Host $args -ForegroundColor Cyan }

Write-Host ""
Write-Info "╔════════════════════════════════════════════════════════════════╗"
Write-Info "║     GitHub Repository Creation Automation - SIMULATION MODE    ║"
Write-Info "╚════════════════════════════════════════════════════════════════╝"
Write-Host ""

Write-Info "Parent directory: $ParentPath"
Write-Info "Folders to process: $($FOLDERS.Count)"
Write-Host ""

# Check prerequisites
Write-Info "Checking prerequisites..."
if (!(git --version 2>$null)) {
    Write-Error "✗ Git is not installed"
    exit 1
}
Write-Success "✓ Git is installed"

if (!(gh --version 2>$null)) {
    Write-Error "✗ GitHub CLI is not installed"
    exit 1
}
Write-Success "✓ GitHub CLI is installed"

$authStatus = gh auth status 2>$null
if ($LASTEXITCODE -ne 0) {
    Write-Error "✗ GitHub CLI authentication required. Run: gh auth login"
    exit 1
}
Write-Success "✓ GitHub authenticated"
Write-Host ""

# Process folders
foreach ($folder in $FOLDERS) {
    $path = Join-Path $ParentPath $folder
    
    Write-Info "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    Write-Info "Processing: $folder"
    Write-Info "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    
    $result = @{
        Folder = $folder
        Status = "Pending"
        Url = ""
        Notes = ""
    }
    
    # Check if folder exists
    if (!(Test-Path -Path $path -PathType Container)) {
        Write-Warning "⊘ Folder does not exist, skipping"
        $result.Status = "Skipped"
        $result.Notes = "Folder not found"
        $Results += $result
        continue
    }
    
    # Check if folder is empty
    $files = @(Get-ChildItem -Path $path -Recurse -ErrorAction SilentlyContinue | Where-Object { !$_.PSIsContainer })
    if ($files.Count -eq 0) {
        Write-Warning "⊘ Folder is empty, skipping"
        $result.Status = "Skipped"
        $result.Notes = "Empty folder"
        $Results += $result
        continue
    }
    
    # Warn about zip files
    $zips = @(Get-ChildItem -Path $path -Filter "*.zip" -Recurse -ErrorAction SilentlyContinue)
    if ($zips.Count -gt 0) {
        Write-Warning "⚠ WARNING: Contains $($zips.Count) .zip file(s)"
        $result.Notes = "Contains zip files"
    }
    
    # Check for existing .git
    if (Test-Path -Path "$path\.git" -PathType Container) {
        Write-Warning "⊘ Git repository already exists, skipping"
        $result.Status = "Skipped"
        $result.Notes = "Already has .git folder"
        $Results += $result
        continue
    }
    
    # Simulate Git operations
    Write-Info "📁 [SIMULATION] Would initialize Git repository..."
    Write-Info "📝 [SIMULATION] Would commit all files..."
    Write-Info "🌐 [SIMULATION] Would create GitHub repository..."
    Write-Info "🚀 [SIMULATION] Would push to GitHub..."
    
    # Get expected URL
    $user = gh api user --jq '.login' 2>$null
    if ($user) {
        $url = "https://github.com/$user/$folder"
    } else {
        $url = "https://github.com/{username}/$folder"
    }
    
    $result.Status = "Ready"
    $result.Url = $url
    $Results += $result
    
    Write-Success "✓ Ready to deploy: $url"
    Write-Host ""
}

# Summary
Write-Host ""
Write-Info "╔════════════════════════════════════════════════════════════════╗"
Write-Info "║                      SIMULATION SUMMARY                       ║"
Write-Info "╚════════════════════════════════════════════════════════════════╝"
Write-Host ""

$readyCount = @($Results | Where-Object { $_.Status -eq "Ready" }).Count
$skippedCount = @($Results | Where-Object { $_.Status -eq "Skipped" }).Count

Write-Info "Total Folders: $($Results.Count)"
Write-Success "Ready for deployment: $readyCount"
Write-Warning "Skipped: $skippedCount"
Write-Host ""

Write-Info "GitHub Repository URLs (preview):"
Write-Info "───────────────────────────────────────────────────────────────"

foreach ($result in $Results) {
    if ($result.Status -eq "Ready") {
        Write-Success "$($result.Folder): $($result.Url)"
    }
    elseif ($result.Status -eq "Skipped") {
        Write-Warning "$($result.Folder): [SKIPPED] $($result.Notes)"
    }
}

Write-Host ""
Write-Info "✓ SIMULATION COMPLETE"
Write-Info ""
Write-Info "Next steps:"
Write-Info "1. Review the simulation results above"
Write-Info "2. Run production mode: powershell -ExecutionPolicy Bypass -File .\deploy-repos-prod.ps1"
Write-Info ""
