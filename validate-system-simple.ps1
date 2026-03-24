# GitHub Automation - Simple System Validation
param(
    [string]$ParentPath = "c:\Study"
)

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  GitHub Automation System Validation" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

$allPass = $true

# Check PowerShell
Write-Host ""
Write-Host "1. PowerShell" -ForegroundColor Cyan
$psVersion = $PSVersionTable.PSVersion.ToString()
Write-Host "[+] PowerShell v$psVersion" -ForegroundColor Green

# Check Git
Write-Host ""
Write-Host "2. Git Installation" -ForegroundColor Cyan
$gitAvailable = $null -ne (Get-Command git -ErrorAction SilentlyContinue)
if ($gitAvailable) {
    Write-Host "[+] Git is installed" -ForegroundColor Green
} else {
    Write-Host "[-] Git is NOT installed" -ForegroundColor Red
    Write-Host "    Install from: https://git-scm.com/download/win" -ForegroundColor Yellow
    $allPass = $false
}

# Check GitHub CLI
Write-Host ""
Write-Host "3. GitHub CLI Installation" -ForegroundColor Cyan
$ghAvailable = $null -ne (Get-Command gh -ErrorAction SilentlyContinue)
if ($ghAvailable) {
    Write-Host "[+] GitHub CLI is installed" -ForegroundColor Green
} else {
    Write-Host "[-] GitHub CLI is NOT installed" -ForegroundColor Red
    Write-Host "    Install from: https://cli.github.com/" -ForegroundColor Yellow
    $allPass = $false
}

# Check GitHub Authentication
Write-Host ""
Write-Host "4. GitHub Authentication" -ForegroundColor Cyan
if ($ghAvailable) {
    $authStatus = gh auth status 2>&1
    if ($LASTEXITCODE -eq 0) {
        $user = gh api user --jq .login 2>$null
        Write-Host "[+] Authenticated as: $user" -ForegroundColor Green
    } else {
        Write-Host "[!] GitHub CLI not authenticated" -ForegroundColor Yellow
        Write-Host "    Run: gh auth login" -ForegroundColor Yellow
    }
} else {
    Write-Host "[!] GitHub CLI not found - skipping auth check" -ForegroundColor Yellow
}

# Check parent folder
Write-Host ""
Write-Host "5. Parent Folder" -ForegroundColor Cyan
$parentExists = Test-Path -Path $ParentPath -PathType Container
if ($parentExists) {
    Write-Host "[+] Parent folder exists: $ParentPath" -ForegroundColor Green
    
    # Check target folders
    Write-Host ""
    Write-Host "Target Folders Status:" -ForegroundColor Cyan
    $folders = @(
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
    
    $foundCount = 0
    foreach ($folder in $folders) {
        $folderPath = Join-Path $ParentPath $folder
        $folderExists = Test-Path -Path $folderPath -PathType Container
        
        if ($folderExists) {
            $items = @(Get-ChildItem -Path $folderPath -Force -Exclude ".git" | Where-Object { $_.Name -ne ".git" })
            $hasGit = Test-Path -Path (Join-Path $folderPath ".git") -PathType Container
            
            if ($hasGit) {
                Write-Host "[+] $folder (GIT: YES)" -ForegroundColor Cyan
            } else {
                Write-Host "[+] $folder (GIT: NO, Files: $($items.Count))" -ForegroundColor Green
            }
            $foundCount++
        } else {
            Write-Host "[-] $folder (NOT FOUND)" -ForegroundColor Yellow
        }
    }
    
    Write-Host ""
    Write-Host "Summary: Found $foundCount/11 folders" -ForegroundColor Cyan
} else {
    Write-Host "[-] Parent folder not found: $ParentPath" -ForegroundColor Red
    $allPass = $false
}

# Final status
Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
if ($allPass) {
    Write-Host "STATUS: Ready to proceed!" -ForegroundColor Green
} else {
    Write-Host "STATUS: Some issues need fixing" -ForegroundColor Yellow
}
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

exit 0
