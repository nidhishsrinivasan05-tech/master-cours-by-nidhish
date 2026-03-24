# GitHub Automation - System Validation & Diagnostics
# Run this to verify your system is ready

param(
    [string]$ParentPath = "c:\Study",
    [switch]$Verbose = $false
)

function Write-Header {
    param([string]$Text)
    Write-Host ""
    Write-Host "═════════════════════════════════════════" -ForegroundColor Cyan
    Write-Host "  $Text" -ForegroundColor Cyan
    Write-Host "═════════════════════════════════════════" -ForegroundColor Cyan
}

function Write-Check {
    param([string]$Text, [bool]$Pass, [string]$Details = "")
    $symbol = if ($Pass) { "[+]" } else { "[-]" }
    $color = if ($Pass) { "Green" } else { "Red" }
    Write-Host "$symbol $Text" -ForegroundColor $color
    if ($Details) {
        Write-Host "  -> $Details" -ForegroundColor Gray
    }
}

function Write-Warning {
    param([string]$Text, [string]$Details = "")
    Write-Host "[!] $Text" -ForegroundColor Yellow
    if ($Details) {
        Write-Host "  -> $Details" -ForegroundColor Gray
    }
}

function Get-CommandVersion {
    param([string]$Command)
    try {
        $version = & $Command --version 2>&1
        return $version.Split([Environment]::NewLine)[0]
    } catch {
        return "Not found"
    }
}

# Main validation
Clear-Host
Write-Header "GitHub Automation System Validation"

$allPass = $true
$warnings = @()

# 1. Operating System Check
Write-Header "1. Operating System"
$osInfo = Get-CimInstance Win32_OperatingSystem
$osVersion = $osInfo.Caption + " " + $osInfo.Version
Write-Check "Windows OS" $true $osVersion

# 2. PowerShell Check
Write-Header "2. PowerShell Environment"
$psVersion = $PSVersionTable.PSVersion.ToString()
$psEdition = if ($PSVersionTable.PSEdition) { $PSVersionTable.PSEdition } else { "Desktop" }
Write-Check "PowerShell Available" $true "$psEdition Edition v$psVersion"

if ($psVersion -lt "5.0") {
    Write-Warning "PowerShell version is older than 5.0" "Consider upgrading to PowerShell 7+ for better performance"
    $warnings += "Old PowerShell version"
}

# 3. Execution Policy Check
Write-Header "3. Execution Policy"
$execPolicy = Get-ExecutionPolicy
$canRunScripts = $execPolicy -in @("Unrestricted", "RemoteSigned", "ByPass")
Write-Check "Script Execution Allowed" $canRunScripts "Policy: $execPolicy"

if (-not $canRunScripts) {
    Write-Host "To fix this, run: Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser" -ForegroundColor Yellow
    $allPass = $false
}

# 4. Git Installation
Write-Header "4. Git Installation"
$gitAvailable = $null -ne (Get-Command git -ErrorAction SilentlyContinue)
if ($gitAvailable) {
    $gitVersion = Get-CommandVersion "git"
    Write-Check "Git Installed" $true $gitVersion
    
    # Git configuration check
    try {
        $gitUser = git config --global user.name
        $gitEmail = git config --global user.email
        if ($gitUser -and $gitEmail) {
            Write-Check "Git Configured" $true "User: $gitUser"
        } else {
            $userStatus = if ($gitUser) { $gitUser } else { "NOT SET" }
            $emailStatus = if ($gitEmail) { $gitEmail } else { "NOT SET" }
            Write-Warning "Git not fully configured" "Name: $userStatus | Email: $emailStatus"
            $warnings += "Incomplete git configuration"
        }
    } catch {
        Write-Check "Git Configuration" $false "Could not read config"
        $allPass = $false
    }
} else {
    Write-Check "Git Installed" $false "Install from https://git-scm.com/download/win"
    $allPass = $false
}

# 5. GitHub CLI Installation
Write-Header "5. GitHub CLI Installation"
$ghAvailable = $null -ne (Get-Command gh -ErrorAction SilentlyContinue)
if ($ghAvailable) {
    $ghVersion = Get-CommandVersion "gh"
    Write-Check "GitHub CLI Installed" $true $ghVersion
    
    # GitHub authentication check
    try {
        $authStatus = gh auth status 2>&1
        if ($LASTEXITCODE -eq 0) {
            $user = gh api user --jq .login 2>$null
            Write-Check "GitHub Authenticated" $true "User: $user"
        } else {
            Write-Warning "GitHub CLI not authenticated" "Run: gh auth login"
            $warnings += "GitHub not authenticated"
        }
    } catch {
        Write-Check "GitHub Auth Check" $false "Could not verify authentication"
        $warnings += "Could not verify GitHub authentication"
    }
} else {
    Write-Check "GitHub CLI Installed" $false "Install from https://cli.github.com/"
    $allPass = $false
}

# 6. Network Connectivity
Write-Header "6. Network Connectivity"
try {
    $github = Test-Connection github.com -Count 1 -Quiet
    Write-Check "GitHub.com Reachable" $github
} catch {
    Write-Check "GitHub.com Reachable" $false "Network test failed"
}

# 7. Parent Folder Check
Write-Header "7. Target Parent Folder"
$parentExists = Test-Path -Path $ParentPath -PathType Container
Write-Check "Parent Folder Exists" $parentExists "Path: $ParentPath"

if ($parentExists) {
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
    
    Write-Host ""
    $foundCount = 0
    $emptyCount = 0
    $gitCount = 0
    
    foreach ($folder in $folders) {
        $folderPath = Join-Path $ParentPath $folder
        $folderExists = Test-Path -Path $folderPath -PathType Container
        
        if ($folderExists) {
            $foundCount++
            $items = @(Get-ChildItem -Path $folderPath -Force -Exclude ".git" | Where-Object { $_.Name -ne ".git" })
            $isEmpty = $items.Count -eq 0
            $hasGit = Test-Path -Path (Join-Path $folderPath ".git") -PathType Container
            
            if ($hasGit) {
                $gitCount++
                Write-Check "$folder" $true "Git: YES | Files: $($items.Count)"
            } elseif ($isEmpty) {
                Write-Check "$folder" $false "Empty folder"
                $emptyCount++
            } else {
                Write-Check "$folder" $true "Git: NO | Files: $($items.Count)"
            }
        } else {
            Write-Check "$folder" $false "Folder not found"
        }
    }
    
    Write-Host ""
    Write-Host "Summary:" -ForegroundColor Cyan
    Write-Host "  Found: $foundCount/11 folders" -ForegroundColor Green
    Write-Host "  Already Git: $gitCount folders" -ForegroundColor Cyan
    Write-Host "  Empty: $emptyCount folders" -ForegroundColor Yellow
} else {
    Write-Host "Create the parent folder or use -ParentPath parameter" -ForegroundColor Yellow
    $allPass = $false
}

# 8. Script Files Check
Write-Header "8. Required Script Files"
$scriptPath = Split-Path -Parent $MyInvocation.MyCommand.Path
$scriptExists = Test-Path -Path (Join-Path $scriptPath "github-repos-automation.ps1") -PathType Leaf
Write-Check "Main Script Present" $scriptExists "Location: $scriptPath"

# 9. Disk Space Check
Write-Header "9. Disk Space"
if ($parentExists) {
    $drive = Get-PSDrive (Split-Path -Qualifier $ParentPath).TrimEnd(":")
    $freeGB = [math]::Round($drive.Free / 1GB, 2)
    $totalGB = [math]::Round($drive.Used / 1GB + $drive.Free / 1GB, 2)
    
    $spaceSufficient = $drive.Free -gt 1GB  # At least 1GB free
    Write-Check "Disk Space" $spaceSufficient "$freeGB GB free of $($totalGB) GB total"
    
    if (-not $spaceSufficient) {
        $warnings += "Low disk space"
    }
}

# Final Summary
Write-Header "Validation Summary"

if ($allPass) {
    Write-Host ""
    Write-Host "✓ All critical requirements met!" -ForegroundColor Green
    Write-Host ""
    Write-Host "You can now run the main script:" -ForegroundColor Green
    Write-Host "    .\github-repos-automation.ps1 -DryRun" -ForegroundColor Cyan
    Write-Host ""
    $exitCode = 0
} else {
    Write-Host ""
    Write-Host "✗ Some critical issues need to be fixed" -ForegroundColor Red
    Write-Host ""
    Write-Host "Please address the issues marked with ✗ above" -ForegroundColor Red
    Write-Host ""
    $exitCode = 1
}

if ($warnings.Count -gt 0) {
    Write-Host ""
    Write-Host "Warnings (non-critical):" -ForegroundColor Yellow
    foreach ($warning in $warnings) {
        Write-Host "  ⚠ $warning" -ForegroundColor Yellow
    }
}

Write-Host ""
Write-Host "═════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "Validation Date: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')" -ForegroundColor Gray
Write-Host "═════════════════════════════════════════" -ForegroundColor Cyan
Write-Host ""

exit $exitCode
