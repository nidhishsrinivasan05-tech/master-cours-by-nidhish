#Requires -Version 5.1
<#
.SYNOPSIS
Automated GitHub repository creation and deployment script for multiple folders.
#>

param(
    [Parameter(Mandatory = $false)]
    [string]$ParentPath = "C:\Study",
    [Parameter(Mandatory = $false)]
    [switch]$SkipExisting = $true
)

$FOLDERS_TO_PROCESS = @(
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

$Colors = @{
    Success = "Green"
    Warning = "Yellow"
    Error   = "Red"
    Info    = "Cyan"
    Default = "White"
}

$Results = @()

function Write-ColorOutput {
    param(
        [string]$Message,
        [string]$Color = "Default"
    )
    Write-Host $Message -ForegroundColor $Color
}

function Test-PathExists {
    param([string]$Path)
    return Test-Path -Path $Path -PathType Container
}

function Test-GitRepository {
    param([string]$Path)
    return Test-Path -Path (Join-Path $Path ".git") -PathType Container
}

function Test-FolderEmpty {
    param([string]$Path)
    $items = @(Get-ChildItem -Path $Path -Recurse -ErrorAction SilentlyContinue | Where-Object { -not $_.PSIsContainer })
    return $items.Count -eq 0
}

function Test-HasZipFiles {
    param([string]$Path)
    $zipFiles = @(Get-ChildItem -Path $Path -Filter "*.zip" -Recurse -ErrorAction SilentlyContinue)
    return $zipFiles.Count -gt 0
}

function Initialize-GitRepo {
    param(
        [string]$Path,
        [bool]$WhatIf = $false
    )
    
    try {
        $folderName = Split-Path -Leaf $Path
        
        if (Test-GitRepository -Path $Path) {
            Write-ColorOutput "✓ Git repository already exists in $folderName" -Color $Colors.Info
            return $true
        }
        
        Write-ColorOutput "📁 Initializing Git in $folderName..." -Color $Colors.Info
        
        if (-not $WhatIf) {
            Push-Location $Path
            git init 2>&1 | Out-Null
            git add . 2>&1 | Out-Null
            git commit -m "Initial commit: $folderName" 2>&1 | Out-Null
            Pop-Location
        }
        
        Write-ColorOutput "✓ Git initialized and files committed in $folderName" -Color $Colors.Success
        return $true
    }
    catch {
        Write-ColorOutput "✗ Failed to initialize Git in $Path : $_" -Color $Colors.Error
        return $false
    }
}

function New-GitHubRepository {
    param(
        [string]$RepoName,
        [bool]$WhatIf = $false
    )
    
    try {
        Write-ColorOutput "🌐 Creating GitHub repository: $RepoName..." -Color $Colors.Info
        
        if (-not $WhatIf) {
            $ghAvailable = gh --version 2>$null
            if (-not $ghAvailable) {
                throw "GitHub CLI (gh) is not installed"
            }
            
            gh repo create $RepoName --public --source=. --remote=origin --push 2>&1 | Out-Null
        }
        
        Write-ColorOutput "✓ GitHub repository created: $RepoName" -Color $Colors.Success
        return $true
    }
    catch {
        Write-ColorOutput "✗ Failed to create GitHub repository $RepoName : $_" -Color $Colors.Error
        return $false
    }
}

function Push-ToGitHub {
    param(
        [string]$Path,
        [string]$RepoName,
        [bool]$WhatIf = $false
    )
    
    try {
        Write-ColorOutput "🚀 Pushing to GitHub: $RepoName..." -Color $Colors.Info
        
        if (-not $WhatIf) {
            Push-Location $Path
            git push -u origin main 2>&1 | Out-Null
            Pop-Location
        }
        
        Write-ColorOutput "✓ Successfully pushed $RepoName to GitHub" -Color $Colors.Success
        return $true
    }
    catch {
        try {
            if (-not $WhatIf) {
                Push-Location $Path
                git push -u origin master 2>&1 | Out-Null
                Pop-Location
            }
            Write-ColorOutput "✓ Successfully pushed $RepoName to GitHub (master branch)" -Color $Colors.Success
            return $true
        }
        catch {
            Write-ColorOutput "✗ Failed to push to GitHub $RepoName : $_" -Color $Colors.Error
            return $false
        }
    }
}

function Get-GitHubRepoUrl {
    param([string]$RepoName)
    try {
        $user = gh api user --jq '.login' 2>$null
        if ($user) {
            return "https://github.com/$user/$RepoName"
        }
        return "https://github.com/{username}/$RepoName"
    }
    catch {
        return "https://github.com/{username}/$RepoName"
    }
}

# MAIN LOGIC
Write-Host "`n"
Write-ColorOutput "╔════════════════════════════════════════════════════════════════╗" -Color $Colors.Info
Write-ColorOutput "║     GitHub Repository Creation and Deployment Automation       ║" -Color $Colors.Info
Write-ColorOutput "╚════════════════════════════════════════════════════════════════╝" -Color $Colors.Info
Write-Host ""

if (-not (Test-PathExists -Path $ParentPath)) {
    Write-ColorOutput "✗ Parent path does not exist: $ParentPath" -Color $Colors.Error
    exit 1
}

Write-ColorOutput "Parent directory: $ParentPath" -Color $Colors.Info
Write-ColorOutput "Processing folders: $($FOLDERS_TO_PROCESS.Count)" -Color $Colors.Info
Write-Host ""

Write-ColorOutput "Checking prerequisites..." -Color $Colors.Info
$gitAvailable = git --version 2>$null
if (-not $gitAvailable) {
    Write-ColorOutput "✗ Git is not installed" -Color $Colors.Error
    exit 1
}
Write-ColorOutput "✓ Git is installed" -Color $Colors.Success

$ghAvailable = gh --version 2>$null
if (-not $ghAvailable) {
    Write-ColorOutput "✗ GitHub CLI is not installed" -Color $Colors.Error
    exit 1
}
Write-ColorOutput "✓ GitHub CLI is installed" -Color $Colors.Success

$ghAuth = gh auth status 2>&1
if ($LASTEXITCODE -ne 0) {
    Write-ColorOutput "✗ Not authenticated with GitHub CLI" -Color $Colors.Error
    exit 1
}
Write-ColorOutput "✓ GitHub authenticated" -Color $Colors.Success
Write-Host ""

# Process each folder
foreach ($folder in $FOLDERS_TO_PROCESS) {
    $folderPath = Join-Path $ParentPath $folder
    
    Write-ColorOutput "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -Color $Colors.Info
    Write-ColorOutput "Processing: $folder" -Color $Colors.Info
    Write-ColorOutput "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -Color $Colors.Info
    
    $result = @{
        Folder    = $folder
        Status    = "Pending"
        GitHubUrl = ""
        Error     = ""
    }
    
    if (-not (Test-PathExists -Path $folderPath)) {
        Write-ColorOutput "⊘ Folder does not exist, skipping" -Color $Colors.Warning
        $result.Status = "Skipped"
        $result.Error = "Folder not found"
        $Results += $result
        continue
    }
    
    if (Test-FolderEmpty -Path $folderPath) {
        Write-ColorOutput "⊘ Folder is empty, skipping" -Color $Colors.Warning
        $result.Status = "Skipped"
        $result.Error = "Empty folder"
        $Results += $result
        continue
    }
    
    if (Test-HasZipFiles -Path $folderPath) {
        Write-ColorOutput "⚠ WARNING: Folder contains .zip files - proceeding with caution" -Color $Colors.Warning
        $result.Error = "Contains zip files (proceeded anyway)"
    }
    
    if (Test-GitRepository -Path $folderPath) {
        Write-ColorOutput "⊘ Git repository already exists" -Color $Colors.Warning
        if ($SkipExisting) {
            Write-ColorOutput "Skipping (use -SkipExisting:`$false to override)" -Color $Colors.Info
            $result.Status = "Skipped"
            $result.Error = "Already has .git"
            $Results += $result
            continue
        }
    }
    
    if (-not (Initialize-GitRepo -Path $folderPath -WhatIf $PSBoundParameters.ContainsKey('WhatIf'))) {
        $result.Status = "Failed"
        $result.Error = "Git initialization failed"
        $Results += $result
        continue
    }
    
    if (-not (New-GitHubRepository -RepoName $folder -WhatIf $PSBoundParameters.ContainsKey('WhatIf'))) {
        $result.Status = "Failed"
        $result.Error = "GitHub repo creation failed"
        $Results += $result
        continue
    }
    
    if (-not (Push-ToGitHub -Path $folderPath -RepoName $folder -WhatIf $PSBoundParameters.ContainsKey('WhatIf'))) {
        $result.Status = "Failed"
        $result.Error = "Push to GitHub failed"
        $Results += $result
        continue
    }
    
    $githubUrl = Get-GitHubRepoUrl -RepoName $folder
    
    $result.Status = "Success"
    $result.GitHubUrl = $githubUrl
    $Results += $result
    
    Write-ColorOutput "✓ Completed: $githubUrl" -Color $Colors.Success
    Write-Host ""
}

# SUMMARY REPORT
Write-Host ""
Write-ColorOutput "╔════════════════════════════════════════════════════════════════╗" -Color $Colors.Info
Write-ColorOutput "║                      SUMMARY REPORT                           ║" -Color $Colors.Info
Write-ColorOutput "╚════════════════════════════════════════════════════════════════╝" -Color $Colors.Info
Write-Host ""

$successCount = @($Results | Where-Object { $_.Status -eq "Success" }).Count
$skippedCount = @($Results | Where-Object { $_.Status -eq "Skipped" }).Count
$failedCount = @($Results | Where-Object { $_.Status -eq "Failed" }).Count

Write-ColorOutput "Total Processed: $($Results.Count)" -Color $Colors.Info
Write-ColorOutput "✓ Successful: $successCount" -Color $Colors.Success
Write-ColorOutput "⊘ Skipped: $skippedCount" -Color $Colors.Warning
Write-ColorOutput "✗ Failed: $failedCount" -Color $Colors.Error

Write-Host ""
Write-ColorOutput "GitHub Repository Links:" -Color $Colors.Info
Write-ColorOutput "───────────────────────────────────────────────────────────────" -Color $Colors.Info

foreach ($result in $Results) {
    if ($result.Status -eq "Success") {
        Write-ColorOutput "$($result.Folder): $($result.GitHubUrl)" -Color $Colors.Success
    }
    elseif ($result.Status -eq "Skipped") {
        Write-ColorOutput "$($result.Folder): [SKIPPED] - $($result.Error)" -Color $Colors.Warning
    }
    else {
        Write-ColorOutput "$($result.Folder): [FAILED] - $($result.Error)" -Color $Colors.Error
    }
}

Write-Host ""
Write-ColorOutput "Operation completed!" -Color $Colors.Info
Write-Host ""

$logPath = Join-Path $ParentPath "deployment-results.txt"
$Results | Format-Table -AutoSize | Out-File -FilePath $logPath
Write-ColorOutput "Results saved to: $logPath" -Color $Colors.Info
