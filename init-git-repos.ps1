# GitHub Repos Automation - Simple and Robust
# Initializes local Git repos and prepares for GitHub push

param(
    [string]$ParentPath = "c:\Study",
    [string]$GitHubUsername = "nidhishsrinivasan05-tech",
    [switch]$DryRun = $false
)

Write-Host ""
Write-Host "========================================="
Write-Host "GitHub Repos Local Git Preparation"
Write-Host "========================================="
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

# Validate
if (-not (Test-Path $ParentPath)) {
    Write-Host "ERROR: Parent path not found: $ParentPath" -ForegroundColor Red
    exit 1
}

if ($null -eq (Get-Command git -ErrorAction SilentlyContinue)) {
    Write-Host "ERROR: Git not installed" -ForegroundColor Red
    exit 1
}

Write-Host "Parent: $ParentPath" -ForegroundColor Cyan
Write-Host "Target folders: $($TargetFolders.Count)" -ForegroundColor Cyan
Write-Host "Username: $GitHubUsername" -ForegroundColor Cyan
Write-Host "Dry Run: $DryRun" -ForegroundColor Cyan
Write-Host ""

$success = 0
$skip = 0
$fail = 0
$repos = @()

foreach ($folder in $TargetFolders) {
    $path = Join-Path $ParentPath $folder
    
    # Check exists
    if (-not (Test-Path $path)) {
        Write-Host "[-] $folder - NOT FOUND" -ForegroundColor Yellow
        $skip++
        continue
    }
    
    # Get content count (excluding .git)
    $content = @(Get-ChildItem $path -Force -Exclude ".git" -ErrorAction SilentlyContinue)
    if ($content.Count -eq 0) {
        Write-Host "[-] $folder - EMPTY" -ForegroundColor Yellow
        $skip++
        continue
    }
    
    Write-Host "[*] $folder ..." -ForegroundColor Cyan -NoNewline
    
    if ($DryRun) {
        Write-Host " [DRY RUN]" -ForegroundColor Blue
        $success++
        $repos += $folder
        continue
    }
    
    # Check for nested structure
    $actualPath = $path
    $subFolders = @(Get-ChildItem $path -Directory -Force)
    if ($subFolders.Count -eq 1 -and $subFolders[0].Name -eq $folder) {
        $nestedPath = Join-Path $path $folder
        if (Test-Path $nestedPath) {
            $actualPath = $nestedPath
        }
    }
    
    # Initialize git
    $gitPath = Join-Path $actualPath ".git"
    $isNewRepo = $false
    
    if (-not (Test-Path $gitPath)) {
        try {
            Push-Location $actualPath
            git init *>$null
            git config user.name "GitHub Automation" *>$null
            git config user.email "automation@github.local" *>$null
            $isNewRepo = $true
        } catch {
            Write-Host " ERROR" -ForegroundColor Red
            Pop-Location
            $fail++
            continue
        }
    }
    
    # Add and commit
    try {
        $status = git status --porcelain 2>$null
        if ($status) {
            git add -A *>$null
            git commit -m "Initial commit - automated setup" *>$null
        }
        
        # Set remote
        $remoteUrl = "https://github.com/$GitHubUsername/$folder.git"
        $existing = git config --get remote.origin.url 2>$null
        if ([string]::IsNullOrEmpty($existing)) {
            git remote add origin $remoteUrl *>$null
        } else {
            git remote set-url origin $remoteUrl *>$null
        }
        
        Pop-Location
        Write-Host " OK" -ForegroundColor Green
        $success++
        $repos += $folder
        
    } catch {
        Write-Host " FAILED" -ForegroundColor Red
        Pop-Location
        $fail++
    }
}

Write-Host ""
Write-Host "========================================="
Write-Host "Summary"
Write-Host "========================================="
Write-Host "Success: $success" -ForegroundColor Green
Write-Host "Skipped: $skip" -ForegroundColor Yellow
Write-Host "Failed:  $fail" -ForegroundColor Red
Write-Host ""

if ($success -gt 0) {
    Write-Host "NEXT STEPS:" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "1. Create repositories on GitHub:" -ForegroundColor White
    Write-Host "   Visit: https://github.com/new" -ForegroundColor Green
    Write-Host ""
    Write-Host "2. For each repository created, push with:" -ForegroundColor White
    Write-Host "   cd <folder>" -ForegroundColor Green
    Write-Host "   git push -u origin master" -ForegroundColor Green
    Write-Host ""
    Write-Host "3. Or use GitHub CLI after installing:" -ForegroundColor White
    Write-Host "   winget install GitHub.cli" -ForegroundColor Green
    Write-Host "   gh auth login" -ForegroundColor Green
    Write-Host ""
    Write-Host "Initialized repositories:" -ForegroundColor Cyan
    foreach ($repo in $repos) {
        Write-Host "  - https://github.com/$GitHubUsername/$repo" -ForegroundColor Green
    }
}

Write-Host ""
exit 0
