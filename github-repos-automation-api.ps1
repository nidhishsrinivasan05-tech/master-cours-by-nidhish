# GitHub Automation - API-based Repository Creation & Push
# Uses GitHub REST API instead of CLI

param(
    [string]$Token = "",
    [string]$Username = "nidhishsrinivasan05-tech",
    [string]$ParentPath = "c:\Study",
    [switch]$DryRun = $false
)

Write-Host ""
Write-Host "=========================================="
Write-Host "GitHub Automation - API Method"
Write-Host "=========================================="
Write-Host ""

# Function to create repository via API
function New-GitHubRepository {
    param(
        [string]$RepoName,
        [string]$Token,
        [string]$Username
    )
    
    $headers = @{
        "Authorization" = "token $Token"
        "Accept" = "application/vnd.github.v3+json"
    }
    
    $body = @{
        name = $RepoName
        description = "$RepoName repository"
        private = $false
        auto_init = $false
    } | ConvertTo-Json
    
    $uri = "https://api.github.com/user/repos"
    
    try {
        $response = Invoke-RestMethod -Uri $uri -Method POST -Headers $headers -Body $body -ErrorAction Stop
        return $response
    } catch {
        if ($_.Exception.Message -like "*422*" -or $_.Exception.Response.StatusCode -eq 422) {
            Write-Host "  [INFO] Repository already exists" -ForegroundColor Gray
            return $null
        }
        Write-Host "  [ERROR] API Error: $($_.Exception.Message)" -ForegroundColor Red
        return $null
    }
}

# Check prerequisites
if ([string]::IsNullOrEmpty($Token)) {
    Write-Host "GitHub Personal Access Token required!" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Get your token:" -ForegroundColor Cyan
    Write-Host "  1. Visit: https://github.com/settings/tokens" -ForegroundColor Green
    Write-Host "  2. Click 'Generate new token (classic)'" -ForegroundColor Green
    Write-Host "  3. Select: 'repo' scope (full control)" -ForegroundColor Green
    Write-Host "  4. Copy token and paste below" -ForegroundColor Green
    Write-Host ""
    $Token = Read-Host "Paste your GitHub Personal Access Token (or press Ctrl+C to cancel)"
}

if ([string]::IsNullOrEmpty($Token)) {
    Write-Host "Token is required. Exiting." -ForegroundColor Red
    exit 1
}

Write-Host "Token received (length: $($Token.Length) chars)" -ForegroundColor Green
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

Write-Host "Username: $Username" -ForegroundColor Cyan
Write-Host "Folders: $($TargetFolders.Count)" -ForegroundColor Cyan
Write-Host "Dry Run: $DryRun" -ForegroundColor Cyan
Write-Host ""

$success = 0
$skip = 0
$fail = 0

# Step 1: Create repositories on GitHub
Write-Host "=========================================="
Write-Host "Step 1: Creating repositories on GitHub"
Write-Host "=========================================="
Write-Host ""

foreach ($folder in $TargetFolders) {
    $path = Join-Path $ParentPath $folder
    
    if (-not (Test-Path $path)) {
        Write-Host "[-] $folder - Folder not found" -ForegroundColor Yellow
        $skip++
        continue
    }
    
    $content = @(Get-ChildItem $path -Force -Exclude ".git")
    if ($content.Count -eq 0) {
        Write-Host "[-] $folder - Empty folder" -ForegroundColor Yellow
        $skip++
        continue
    }
    
    Write-Host "[*] $folder ..." -ForegroundColor Cyan -NoNewline
    
    if ($DryRun) {
        Write-Host " [DRY RUN]" -ForegroundColor Blue
        $success++
        continue
    }
    
    # Create repo via API
    $result = New-GitHubRepository -RepoName $folder -Token $Token -Username $Username
    if ($result) {
        Write-Host " Created" -ForegroundColor Green
        $success++
    } else {
        Write-Host " Exists or Failed" -ForegroundColor Yellow
        $success++
    }
}

Write-Host ""
Write-Host "=========================================="
Write-Host "Step 2: Pushing code to GitHub"
Write-Host "=========================================="
Write-Host ""

# Configure git credential helper
Write-Host "Configuring Git credential helper..." -ForegroundColor Gray

# Create a temporary credential script
$credScript = @"
@echo off
echo username=nidhishsrinivasan05-tech
echo password=$Token
"@

$credScriptPath = Join-Path $env:TEMP "git-credential-helper.bat"
Set-Content -Path $credScriptPath -Value $credScript -Force

# Configure git to use it
git config --global credential.helper "!`$credScriptPath"

Write-Host "Git configured" -ForegroundColor Green
Write-Host ""

# Push all repos
$pushSuccess = 0
$pushFail = 0

foreach ($folder in $TargetFolders) {
    $path = Join-Path $ParentPath $folder
    
    if (-not (Test-Path $path)) { continue }
    if ((Get-ChildItem $path -Force -Exclude ".git" | Measure-Object).Count -eq 0) { continue }
    
    Write-Host "[*] Pushing $folder ..." -ForegroundColor Cyan -NoNewline
    
    if ($DryRun) {
        Write-Host " [DRY RUN]" -ForegroundColor Blue
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
    
    Push-Location $actualPath
    
    # Set remote URL with credentials
    $remoteUrl = "https://$Username`:$Token@github.com/$Username/$folder.git"
    $existing = git config --get remote.origin.url 2>$null
    
    if ([string]::IsNullOrEmpty($existing)) {
        git remote add origin $remoteUrl 2>$null
    } else {
        git remote set-url origin $remoteUrl 2>$null
    }
    
    # Try to push
    $currentBranch = git rev-parse --abbrev-ref HEAD 2>$null
    if ([string]::IsNullOrEmpty($currentBranch)) { $currentBranch = "main" }
    
    $pushResult = git push -u origin $currentBranch 2>&1
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host " OK" -ForegroundColor Green
        $pushSuccess++
    } else {
        Write-Host " FAILED" -ForegroundColor Red
        $pushFail++
    }
    
    Pop-Location
}

# Cleanup credential script
Remove-Item -Path $credScriptPath -Force -ErrorAction SilentlyContinue

Write-Host ""
Write-Host "=========================================="
Write-Host "Summary"
Write-Host "=========================================="
Write-Host "Repos Created: $success" -ForegroundColor Green
Write-Host "Code Pushed: $pushSuccess" -ForegroundColor Green
Write-Host "Push Failed: $pushFail" -ForegroundColor $(if ($pushFail -gt 0) { "Red" } else { "Green" })
Write-Host ""

if ($DryRun) {
    Write-Host "Dry run completed. No changes were made." -ForegroundColor Blue
} else {
    Write-Host "GitHub automation complete!" -ForegroundColor Green
    Write-Host ""
    Write-Host "Your repositories:" -ForegroundColor Cyan
    foreach ($folder in $TargetFolders) {
        Write-Host "  https://github.com/$Username/$folder" -ForegroundColor Green
    }
}

Write-Host ""
exit 0
