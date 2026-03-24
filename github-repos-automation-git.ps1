# GitHub Repos Automation - Git-based Automation
# Uses Git directly (no GitHub CLI required)

param(
    [string]$ParentPath = "c:\Study",
    [string]$GitHubUsername = "",
    [switch]$DryRun = $false
)

Write-Host ""
Write-Host "========================================"
Write-Host "GitHub Repository Automation - Git CLI"
Write-Host "========================================"
Write-Host ""

if ([string]::IsNullOrEmpty($GitHubUsername)) {
    Write-Host "GitHub username not provided." -ForegroundColor Yellow
    Write-Host "This is needed to create and push repositories." -ForegroundColor Yellow
    Write-Host ""
    $GitHubUsername = Read-Host "Enter your GitHub username"
}

if ([string]::IsNullOrEmpty($GitHubUsername)) {
    Write-Host "GitHub username is required. Exiting." -ForegroundColor Red
    exit 1
}

Write-Host "Using GitHub username: $GitHubUsername" -ForegroundColor Green
Write-Host ""

# Target folders
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

# Validate parent folder
if (-not (Test-Path $ParentPath -PathType Container)) {
    Write-Host "ERROR: Parent path does not exist: $ParentPath" -ForegroundColor Red
    exit 1
}

# Check Git
if ($null -eq (Get-Command git -ErrorAction SilentlyContinue)) {
    Write-Host "ERROR: Git is not installed." -ForegroundColor Red
    Write-Host "Install from: https://git-scm.com/download/win" -ForegroundColor Yellow
    exit 1
}

Write-Host "Validating prerequisites..."
Write-Host ""

# Set git config if needed
$globalUser = git config --global user.name
$globalEmail = git config --global user.email

if ([string]::IsNullOrEmpty($globalUser) -or [string]::IsNullOrEmpty($globalEmail)) {
    Write-Host "Git configuration incomplete. Setting defaults..."
    if ([string]::IsNullOrEmpty($globalUser)) {
        git config --global user.name "GitHub Automation"
    }
    if ([string]::IsNullOrEmpty($globalEmail)) {
        git config --global user.email "automation@github.local"
    }
    Write-Host "Git configuration updated." -ForegroundColor Green
}

Write-Host ""
Write-Host "========================================"
Write-Host "Processing Folders"
Write-Host "========================================"
Write-Host ""

$successCount = 0
$skipCount = 0
$failCount = 0

foreach ($folder in $TargetFolders) {
    $folderPath = Join-Path $ParentPath $folder
    
    Write-Host "Processing: $folder" -ForegroundColor Cyan
    
    # Check folder exists
    if (-not (Test-Path $folderPath -PathType Container)) {
        Write-Host "  [SKIP] Folder not found" -ForegroundColor Yellow
        $skipCount++
        continue
    }
    
    # Check if empty
    $items = @(Get-ChildItem -Path $folderPath -Force -Exclude ".git" | Where-Object { $_.Name -ne ".git" })
    if ($items.Count -eq 0) {
        Write-Host "  [SKIP] Empty folder" -ForegroundColor Yellow
        $skipCount++
        continue
    }
    
    # Check for nested structure
    $subfolders = @(Get-ChildItem -Path $folderPath -Directory -Force)
    if ($subfolders.Count -eq 1 -and $subfolders[0].Name -eq $folder) {
        $nestedPath = Join-Path $folderPath $folder
        if (Test-Path $nestedPath -PathType Container) {
            Write-Host "  [INFO] Using nested folder" -ForegroundColor Gray
            $folderPath = $nestedPath
        }
    }
    
    if ($DryRun) {
        Write-Host "  [DRY RUN] Would initialize and push" -ForegroundColor Blue
        $successCount++
        continue
    }
    
    # Initialize git if needed
    $gitPath = Join-Path $folderPath ".git"
    if (-not (Test-Path $gitPath -PathType Container)) {
        Write-Host "  [INFO] Initializing git repository..." -ForegroundColor Gray
        Push-Location $folderPath
        git init | Out-Null
        git config user.name "GitHub Automation" | Out-Null
        git config user.email "automation@github.local" | Out-Null
        Pop-Location
    } else {
        Write-Host "  [INFO] Git repository already initialized" -ForegroundColor Gray
    }
    
    # Add files and commit
    Push-Location $folderPath
    
    $status = git status --porcelain 2>$null
    if ($status) {
        Write-Host "  [INFO] Adding files and committing..." -ForegroundColor Gray
        git add -A 2>$null
        git commit -m "Initial commit - automated setup" | Out-Null
        
        if ($LASTEXITCODE -ne 0) {
            Write-Host "  [WARN] Commit failed or no changes" -ForegroundColor Yellow
        }
    } else {
        Write-Host "  [INFO] Repository up to date" -ForegroundColor Gray
    }
    
    # Set remote URL
    $remoteUrl = "https://github.com/$GitHubUsername/$folder.git"
    $existingRemote = git remote get-url origin 2>$null
    
    if ([string]::IsNullOrEmpty($existingRemote)) {
        Write-Host "  [INFO] Adding remote origin..." -ForegroundColor Gray
        git remote add origin $remoteUrl | Out-Null
    } else {
        Write-Host "  [INFO] Updating remote origin..." -ForegroundColor Gray
        git remote set-url origin $remoteUrl | Out-Null
    }
    
    # Try to push
    Write-Host "  [INFO] Pushing to GitHub..." -ForegroundColor Gray
    Write-Host "  [IMPORTANT] If prompted, enter your GitHub credentials" -ForegroundColor Yellow
    
    # Detect current branch
    $currentBranch = git rev-parse --abbrev-ref HEAD 2>$null
    if ([string]::IsNullOrEmpty($currentBranch)) {
        $currentBranch = "main"
    }
    
    # Attempt push
    $pushOutput = git push -u origin $currentBranch 2>&1
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "  [SUCCESS] Pushed to GitHub" -ForegroundColor Green
        Write-Host "  Repository: $remoteUrl" -ForegroundColor Cyan
        $successCount++
    } else {
        Write-Host "  [ERROR] Push failed" -ForegroundColor Red
        Write-Host "  $pushOutput" -ForegroundColor Red
        Write-Host "  Manual push: git push -u origin $currentBranch" -ForegroundColor Yellow
        $failCount++
    }
    
    Pop-Location
    Write-Host ""
}

# Summary
Write-Host "========================================"
Write-Host "Summary"
Write-Host "========================================"
Write-Host "Success: $successCount folders" -ForegroundColor Green
Write-Host "Skipped: $skipCount folders" -ForegroundColor Yellow
Write-Host "Failed:  $failCount folders" -ForegroundColor Red
Write-Host ""

if ($DryRun) {
    Write-Host "Dry run completed. No changes were made." -ForegroundColor Blue
    Write-Host "Run without -DryRun to execute." -ForegroundColor Blue
} elseif ($failCount -eq 0) {
    Write-Host "All folders processed successfully!" -ForegroundColor Green
} else {
    Write-Host "Some folders failed. Check errors above." -ForegroundColor Red
}

Write-Host ""
Write-Host "GitHub Repository Base URL:" -ForegroundColor Cyan
Write-Host "https://github.com/$GitHubUsername/" -ForegroundColor Green
Write-Host ""

exit 0
