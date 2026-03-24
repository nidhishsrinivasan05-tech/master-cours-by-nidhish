# GitHub Automation Script for Multiple Repositories
# This script initializes git, commits files, and pushes to GitHub for specified folders
# Author: GitHub Automation Assistant
# Date: 2026-03-23

param(
    [string]$ParentPath = "c:\Study",
    [switch]$DryRun = $false,
    [switch]$SkipPush = $false,
    [switch]$Force = $false
)

# Color functions for output
function Write-Info {
    param([string]$Message)
    Write-Host "ℹ️  INFO: $Message" -ForegroundColor Cyan
}

function Write-Success {
    param([string]$Message)
    Write-Host "✓ SUCCESS: $Message" -ForegroundColor Green
}

function Write-Warning {
    param([string]$Message)
    Write-Host "⚠️  WARNING: $Message" -ForegroundColor Yellow
}

function Write-Error {
    param([string]$Message)
    Write-Host "✗ ERROR: $Message" -ForegroundColor Red
}

# Define target folders
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

# Track results
$Results = @()

Write-Info "=========================================="
Write-Info "GitHub Repository Automation Script"
Write-Info "=========================================="
Write-Info "Parent Path: $ParentPath"
Write-Info "Dry Run Mode: $DryRun"
Write-Info "Skip Push: $SkipPush"
Write-Info ""

# Validate parent folder exists
if (-not (Test-Path $ParentPath -PathType Container)) {
    Write-Error "Parent path does not exist: $ParentPath"
    exit 1
}

# Check prerequisites
Write-Info "Checking prerequisites..."

# Check if git is installed
try {
    $gitVersion = git --version 2>$null
    if ($LASTEXITCODE -eq 0) {
        Write-Success "Git installed: $gitVersion"
    } else {
        throw "Git not found"
    }
} catch {
    Write-Error "Git is not installed. Please install Git from https://git-scm.com/"
    exit 1
}

# Check if GitHub CLI is installed
try {
    $ghVersion = gh --version 2>$null
    if ($LASTEXITCODE -eq 0) {
        Write-Success "GitHub CLI installed: $ghVersion"
    } else {
        throw "GitHub CLI not found"
    }
} catch {
    Write-Error "GitHub CLI is not installed. Please install from https://cli.github.com/"
    Write-Info "After installation, run: gh auth login"
    exit 1
}

# Verify GitHub authentication
try {
    gh auth status 2>&1 | Out-Null
    if ($LASTEXITCODE -eq 0) {
        Write-Success "GitHub authentication verified"
    } else {
        throw "Not authenticated"
    }
} catch {
    Write-Error "GitHub authentication failed. Please run: gh auth login"
    exit 1
}

Write-Info ""
Write-Info "=========================================="
Write-Info "Processing Folders"
Write-Info "=========================================="
Write-Info ""

# Process each target folder
foreach ($folder in $TargetFolders) {
    $folderPath = Join-Path $ParentPath $folder
    
    # Check if folder exists
    if (-not (Test-Path $folderPath -PathType Container)) {
        Write-Warning "Folder does not exist: $folder"
        $Results += @{
            Folder = $folder
            Status = "SKIPPED"
            Reason = "Folder not found"
            RepoUrl = "N/A"
        }
        continue
    }

    Write-Info "Processing: $folder"
    
    # Check if folder is empty
    $folderItems = @(Get-ChildItem -Path $folderPath -Force -Exclude ".git" | 
                     Where-Object { $_.Name -ne ".git" })
    
    if ($folderItems.Count -eq 0) {
        Write-Warning "  └─ Folder is empty, skipping"
        $Results += @{
            Folder = $folder
            Status = "SKIPPED"
            Reason = "Empty folder"
            RepoUrl = "N/A"
        }
        continue
    }

    # Check for nested folders (e.g., folder-name/folder-name structure)
    $nestedPath = $null
    $subfolders = @(Get-ChildItem -Path $folderPath -Directory -Force)
    if ($subfolders.Count -eq 1 -and $subfolders[0].Name -eq $folder) {
        $nestedPath = Join-Path $folderPath $folder
        if (Test-Path $nestedPath -PathType Container) {
            Write-Info "  └─ Detected nested folder structure, using: $folder/$folder"
            $folderPath = $nestedPath
        }
    }

    # Check if .git already exists
    $gitPath = Join-Path $folderPath ".git"
    $gitExists = Test-Path $gitPath -PathType Container
    
    if ($gitExists) {
        Write-Info "  └─ Git repository already exists"
    } else {
        Write-Info "  └─ Initializing git repository"
        if (-not $DryRun) {
            Push-Location $folderPath
            git init | Out-Null
            git config user.name "GitHub Automation" | Out-Null
            git config user.email "automation@github.com" | Out-Null
            Pop-Location
        }
    }

    # Check for existing commits (avoid re-adding if already committed)
    $hasCommits = $false
    if ($gitExists) {
        Push-Location $folderPath
        $commitCount = @(git rev-list --count HEAD 2>$null)
        if ($commitCount -gt 0) {
            $hasCommits = $true
            Write-Info "  └─ Repository has existing commits"
        }
        Pop-Location
    }

    # Add files and commit
    if (-not $hasCommits) {
        Write-Info "  └─ Adding files and creating initial commit"
        if (-not $DryRun) {
            Push-Location $folderPath
            git add -A 2>$null
            
            # Check if there are changes to commit
            $hasChanges = git status --porcelain | Measure-Object | Select-Object -ExpandProperty Count
            if ($hasChanges -gt 0) {
                git commit -m "Initial commit - automated repository setup" | Out-Null
            } else {
                Write-Info "     └─ No changes to commit"
            }
            Pop-Location
        }
    }

    # Create GitHub repository
    Write-Info "  └─ Creating GitHub repository"
    if (-not $DryRun) {
        $repoUrl = $null
        
        # Check if repo already exists
        $existingRepo = gh repo view "$folder" 2>$null
        if ($LASTEXITCODE -eq 0) {
            Write-Warning "     └─ Repository already exists on GitHub"
            $repoUrl = gh repo view "$folder" --json url --jq .url 2>$null
        } else {
            # Create new repository
            gh repo create "$folder" --public --source=$folderPath --remote=origin --push 2>&1 | Out-Null
            
            if ($LASTEXITCODE -eq 0) {
                Write-Success "     └─ Repository created successfully"
                $repoUrl = "https://github.com/$((gh auth status --show-token 2>&1 | grep -oP '(?<=Logged in to \S+ as )\S+' -or gh config get user 2>$null) || (gh repo view --json owner --jq .owner.login 2>$null))/$folder"
                # Better way to get the URL
                $repoUrl = gh repo view "$folder" --json url --jq .url 2>$null
            } else {
                Write-Error "     └─ Failed to create repository on GitHub"
                $Results += @{
                    Folder = $folder
                    Status = "FAILED"
                    Reason = "GitHub repo creation failed"
                    RepoUrl = "N/A"
                }
                continue
            }
        }
        
        # Make repository public (ensure it's public)
        if ($repoUrl) {
            Write-Info "  └─ Ensuring repository is public"
            $currentVisibility = gh repo view "$folder" --json isPrivate --jq .isPrivate 2>$null
            if ($currentVisibility -eq "true") {
                gh repo edit "$folder" --visibility public 2>$null
                Write-Success "     └─ Repository set to public"
            } else {
                Write-Success "     └─ Repository is already public"
            }
        }
        
        # Push to GitHub
        if (-not $SkipPush) {
            Write-Info "  └─ Pushing to GitHub"
            Push-Location $folderPath
            git remote add origin "https://github.com/$((gh auth status 2>&1 | grep -oP 'as \K\w+') || (gh config get user 2>$null))/$folder" -e 2>$null
            git remote set-url origin "https://github.com/$((gh auth status 2>&1 | grep -oP 'as \K\w+') || (gh config get user 2>$null))/$folder" 2>$null
            git push -u origin main 2>$null -or git push -u origin master 2>$null
            Pop-Location
        }
        
        $Results += @{
            Folder = $folder
            Status = "SUCCESS"
            Reason = ""
            RepoUrl = $repoUrl
        }
        Write-Success "  ✓ Completed: $folder"
    } else {
        Write-Info "  └─ [DRY RUN] Would create repository"
        $Results += @{
            Folder = $folder
            Status = "DRY_RUN"
            Reason = "Dry run mode"
            RepoUrl = "N/A"
        }
    }
    
    Write-Info ""
}

# Summary Report
Write-Info "=========================================="
Write-Info "Summary Report"
Write-Info "=========================================="
Write-Info ""

$successCount = ($Results | Where-Object { $_.Status -eq "SUCCESS" }).Count
$skippedCount = ($Results | Where-Object { $_.Status -eq "SKIPPED" }).Count
$failedCount = ($Results | Where-Object { $_.Status -eq "FAILED" }).Count
$dryRunCount = ($Results | Where-Object { $_.Status -eq "DRY_RUN" }).Count

Write-Host "Status Summary:"
Write-Host "  - Success:  $successCount" -ForegroundColor Green
Write-Host "  - Skipped:  $skippedCount" -ForegroundColor Yellow
Write-Host "  - Failed:   $failedCount" -ForegroundColor Red
Write-Host "  - Dry Run:  $dryRunCount" -ForegroundColor Blue
Write-Host ""

Write-Host "GitHub Repository Links:"
Write-Host "=================================="
foreach ($result in $Results | Where-Object { $_.Status -eq "SUCCESS" }) {
    Write-Host "$($result.Folder):" -ForegroundColor Green
    Write-Host "  $($result.RepoUrl)"
}

Write-Host ""

if ($DryRun) {
    Write-Warning "Script ran in DRY RUN mode. No changes were made."
    Write-Info "Run without -DryRun flag to execute actual changes."
} else {
    Write-Success "GitHub automation completed!"
}

exit 0
