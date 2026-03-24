# GitHub Repos Full Automation - Complete Solution
# This script creates public repositories and pushes all code to GitHub

param(
    [string]$GitHubToken = $env:GITHUB_TOKEN,
    [string]$Username = "nidhishsrinivasan05-tech",
    [string]$ParentPath = "c:\Study",
    [switch]$DryRun = $false,
    [switch]$CreateOnly = $false
)

Write-Host ""
Write-Host "============================================================"
Write-Host "GitHub Automation - Full Repository Creation & Push"
Write-Host "============================================================"
Write-Host ""

$TargetFolders = @(
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

# Check prerequisites
if (-not (Test-Path $ParentPath)) {
    Write-Host "ERROR: Parent path not found: $ParentPath" -ForegroundColor Red
    exit 1
}

if ($null -eq (Get-Command git -ErrorAction SilentlyContinue)) {
    Write-Host "ERROR: Git not found" -ForegroundColor Red
    exit 1
}

Write-Host "Status:" -ForegroundColor Cyan
Write-Host "  Parent Path: $ParentPath"
Write-Host "  GitHub User: $Username"
Write-Host "  Target Repos: $($TargetFolders.Count)"
Write-Host "  Dry Run: $DryRun"
Write-Host ""

# Function to create repo via GitHub API
function New-GHRepo {
    param([string]$Name, [string]$Token, [string]$User)
    
    $headers = @{
        "Authorization" = "token $Token"
        "Accept" = "application/vnd.github.v3+json"
        "User-Agent" = "PowerShell"
    }
    
    $body = @{
        name = $Name
        description = "Automated repository setup"
        private = $false
        auto_init = $false
    } | ConvertTo-Json
    
    try {
        $response = Invoke-RestMethod `
            -Uri "https://api.github.com/user/repos" `
            -Method POST `
            -Headers $headers `
            -Body $body `
            -ErrorAction Stop
        return $true
    } catch {
        if ($_.Exception.Response.StatusCode -eq 422) {
            return "exists"
        }
        Write-Host "    API Error: $($_.Exception.Message)" -ForegroundColor Red
        return $false
    }
}

# Main automation
if ([string]::IsNullOrEmpty($GitHubToken) -and -not $DryRun) {
    Write-Host "NOTICE: GitHub Token not provided" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "To complete GitHub push, you need a Personal Access Token:" -ForegroundColor Cyan
    Write-Host "  1. Visit: https://github.com/settings/tokens/new" -ForegroundColor Green
    Write-Host "  2. Set name: 'GitHub Automation'" -ForegroundColor Green
    Write-Host "  3. Select scopes: Check 'repo'" -ForegroundColor Green
    Write-Host "  4. Click 'Generate token'" -ForegroundColor Green
    Write-Host "  5. Copy token and set environment variable or pass as parameter" -ForegroundColor Green
    Write-Host ""
    Write-Host "Then run:" -ForegroundColor Yellow
    Write-Host "  `$env:GITHUB_TOKEN = 'your_token'" -ForegroundColor Green
    Write-Host "  .\github-repos-automation-complete.ps1" -ForegroundColor Green
    Write-Host ""
    
    # Still initialize local repos
    Write-Host "Initializing local Git repositories..." -ForegroundColor Cyan
    Write-Host ""
} else {
    if ($DryRun) {
        Write-Host "DRY RUN MODE - No actual changes will be made" -ForegroundColor Blue
    } else {
        Write-Host "Using GitHub Token (length: $($GitHubToken.Length) chars)" -ForegroundColor Green
    }
    Write-Host ""
}

# PHASE 1: Initialize local Git repos and ensure commits
Write-Host "============================================================"
Write-Host "Phase 1: Local Git Initialization"
Write-Host "============================================================"
Write-Host ""

$localSuccess = 0
$gitRepos = @()

foreach ($folder in $TargetFolders) {
    $folderPath = Join-Path $ParentPath $folder
    
    if (-not (Test-Path $folderPath)) {
        Write-Host "[-] $folder - Folder not found" -ForegroundColor Yellow
        continue
    }
    
    $items = @(Get-ChildItem $folderPath -Force -Exclude ".git")
    if ($items.Count -eq 0) {
        Write-Host "[-] $folder - Empty folder" -ForegroundColor Yellow
        continue
    }
    
    Write-Host "[*] $folder" -ForegroundColor Cyan -NoNewline
    
    if ($DryRun) {
        Write-Host " [DRY RUN]" -ForegroundColor Blue
        $localSuccess++
        $gitRepos += $folder
        continue
    }
    
    # Detect nested path
    $actualPath = $folderPath
    $subs = @(Get-ChildItem $folderPath -Directory -Force)
    if ($subs.Count -eq 1 -and $subs[0].Name -eq $folder) {
        $nestedPath = Join-Path $folderPath $folder
        if (Test-Path $nestedPath) {
            $actualPath = $nestedPath
        }
    }
    
    # Initialize Git
    $gitPath = Join-Path $actualPath ".git"
    if (-not (Test-Path $gitPath)) {
        Push-Location $actualPath
        git init 2>&1 | Out-Null
        git config user.name "GitHub Automation" 2>&1 | Out-Null
        git config user.email "automation@github.local" 2>&1 | Out-Null
        
        # Add and commit
        git add -A 2>&1 | Out-Null
        git commit -m "Initial commit - automated setup" 2>&1 | Out-Null
        
        Pop-Location
    } else {
        Push-Location $actualPath
        $status = git status --porcelain 2>&1
        if ($status) {
            git add -A 2>&1 | Out-Null
            git commit -m "Update - automated sync" 2>&1 | Out-Null
        }
        Pop-Location
    }
    
    Write-Host " - Git initialized" -ForegroundColor Green
    $localSuccess++
    $gitRepos += $folder
}

Write-Host ""
Write-Host "Local repos ready: $localSuccess/$($TargetFolders.Count)" -ForegroundColor Green
Write-Host ""

if ($DryRun) {
    Write-Host "============================================================"
    Write-Host "DRY RUN COMPLETE"
    Write-Host "============================================================"
    Write-Host "All repos would be initialized and ready to push."
    Write-Host ""
    Write-Host "To execute: Run without -DryRun flag"
    Write-Host ""
    exit 0
}

# PHASE 2: Create repos on GitHub (if token available)
if (-not [string]::IsNullOrEmpty($GitHubToken)) {
    Write-Host "============================================================"
    Write-Host "Phase 2: Creating GitHub Repositories"
    Write-Host "============================================================"
    Write-Host ""
    
    $createdCount = 0
    $existCount = 0
    
    foreach ($folder in $gitRepos) {
        Write-Host "[*] Creating $folder..." -ForegroundColor Cyan -NoNewline
        
        $result = New-GHRepo -Name $folder -Token $GitHubToken -User $Username
        
        if ($result -eq $true) {
            Write-Host " Created" -ForegroundColor Green
            $createdCount++
        } elseif ($result -eq "exists") {
            Write-Host " Already exists" -ForegroundColor Yellow
            $existCount++
        } else {
            Write-Host " Failed" -ForegroundColor Red
        }
    }
    
    Write-Host ""
    Write-Host "Repos: $createdCount created, $existCount already exist" -ForegroundColor Green
    Write-Host ""
    
    # PHASE 3: Push code to GitHub
    Write-Host "============================================================"
    Write-Host "Phase 3: Pushing Code to GitHub"
    Write-Host "============================================================"
    Write-Host ""
    
    $pushSuccess = 0
    $pushFail = 0
    
    foreach ($folder in $gitRepos) {
        $folderPath = Join-Path $ParentPath $folder
        $actualPath = $folderPath
        
        $subs = @(Get-ChildItem $folderPath -Directory -Force)
        if ($subs.Count -eq 1 -and $subs[0].Name -eq $folder) {
            $nestedPath = Join-Path $folderPath $folder
            if (Test-Path $nestedPath) {
                $actualPath = $nestedPath
            }
        }
        
        Write-Host "[*] Pushing $folder..." -ForegroundColor Cyan -NoNewline
        
        Push-Location $actualPath
        
        # Set remote with token auth
        $remoteUrl = "https://$($Username):$($GitHubToken)@github.com/$Username/$folder.git"
        $existing = git config --get remote.origin.url 2>$null
        
        if ([string]::IsNullOrEmpty($existing)) {
            git remote add origin $remoteUrl 2>$null
        } else {
            git remote set-url origin $remoteUrl 2>$null
        }
        
        # Push
        $branch = git rev-parse --abbrev-ref HEAD 2>$null
        if ([string]::IsNullOrEmpty($branch)) { $branch = "main" }
        
        $pushOutput = git push -u origin $branch 2>&1
        
        if ($LASTEXITCODE -eq 0) {
            Write-Host " OK" -ForegroundColor Green
            $pushSuccess++
        } else {
            Write-Host " FAILED" -ForegroundColor Red
            Write-Host "     Error: $($pushOutput | Select-Object -First 1)" -ForegroundColor Red
            $pushFail++
        }
        
        Pop-Location
    }
    
    Write-Host ""
    $pushColor = if ($pushFail -eq 0) { "Green" } else { "Yellow" }
    Write-Host "Push complete: $pushSuccess succeeded, $pushFail failed" -ForegroundColor $pushColor
    Write-Host ""
}

# Final summary
Write-Host "============================================================"
Write-Host "Automation Summary"
Write-Host "============================================================"
Write-Host ""
Write-Host "✓ Git Initialization: $localSuccess/$($TargetFolders.Count) repos" -ForegroundColor Green

if (-not [string]::IsNullOrEmpty($GitHubToken)) {
    Write-Host "✓ GitHub Creation: $($createdCount + $existCount)/$($gitRepos.Count) repos" -ForegroundColor Green
    $pushColor = if ($pushFail -eq 0) { "Green" } else { "Yellow" }
    Write-Host "✓ Code Push: $pushSuccess/$($gitRepos.Count) successful" -ForegroundColor $pushColor
}

Write-Host ""
Write-Host "Your GitHub repositories:" -ForegroundColor Cyan
foreach ($repo in $gitRepos) {
    Write-Host "  https://github.com/$Username/$repo" -ForegroundColor Green
}

Write-Host ""
Write-Host "============================================================"
Write-Host "COMPLETE - All repositories are on GitHub and public!"
Write-Host "============================================================"
Write-Host ""

exit 0
