#Requires -Version 5.1
<#
.SYNOPSIS
Automated GitHub repository creation and deployment script for multiple folders.

.DESCRIPTION
This script initializes Git repositories and creates corresponding GitHub repositories
for specified folders, then pushes all content and makes them public.

.PARAMETER ParentPath
The parent directory containing the folders to process.

.PARAMETER SkipExisting
If $true, skip folders that already have .git directory.

.EXAMPLE
.\deploy-repos.ps1 -ParentPath "C:\Study"
#>

param(
    [Parameter(Mandatory = $false)]
    [string]$ParentPath = "C:\Study",
    
    [Parameter(Mandatory = $false)]
    [switch]$SkipExisting = $true,
    
    [Parameter(Mandatory = $false)]
    [switch]$Whatif = $false
)

# Configuration
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

# Colors for output
$Colors = @{
    Success = "Green"
    Warning = "Yellow"
    Error   = "Red"
    Info    = "Cyan"
    Default = "White"
}

# Results tracking
$Results = @()

# ============================================================================
# HELPER FUNCTIONS
# ============================================================================

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
    $items = Get-ChildItem -Path $Path -Recurse -ErrorAction SilentlyContinue | Where-Object { -not $_.PSIsContainer }
    return $items.Count -eq 0
}

function Test-HasZipFiles {
    param([string]$Path)
    $zipFiles = Get-ChildItem -Path $Path -Filter "*.zip" -Recurse -ErrorAction SilentlyContinue
    return $zipFiles.Count -gt 0
}

function Confirm-Action {
    param(
        [string]$Message,
        [bool]$WhatIf = $false
    )
    
    if ($WhatIf) {
        Write-ColorOutput "[$Message - SIMULATION MODE]" -Color $Colors.Info
        return $true
    }
    
    $response = Read-Host "$Message (yes/no)"
    return $response -eq "yes"
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
            git init | Out-Null
            git add . | Out-Null
            git commit -m "Initial commit: $folderName" | Out-Null
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
            # Check if gh CLI is available
            $ghAvailable = gh --version 2>$null
            if (-not $ghAvailable) {
                throw "GitHub CLI (gh) is not installed or not in PATH. Please install it first."
            }
            
            # Create the repository
            gh repo create $RepoName `
                --public `
                --source=. `
                --remote=origin `
                --push `
                2>&1 | Out-Null
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
        # Try with master branch if main doesn't exist
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
    param(
        [string]$RepoName
    )
    
    try {
        # Get the authenticated user
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

# ============================================================================
# MAIN LOGIC
# ============================================================================

Write-Host "`n" 
Write-ColorOutput "╔════════════════════════════════════════════════════════════════╗" -Color $Colors.Info
Write-ColorOutput "║     GitHub Repository Creation and Deployment Automation       ║" -Color $Colors.Info
Write-ColorOutput "╚════════════════════════════════════════════════════════════════╝" -Color $Colors.Info
Write-Host ""

# Validate parent path
if (-not (Test-PathExists -Path $ParentPath)) {
    Write-ColorOutput "✗ Parent path does not exist: $ParentPath" -Color $Colors.Error
    exit 1
}

Write-ColorOutput "Parent directory: $ParentPath" -Color $Colors.Info
Write-ColorOutput "Processing folders: $($FOLDERS_TO_PROCESS.Count)" -Color $Colors.Info

if ($Whatif) {
    Write-ColorOutput "⚠ SIMULATION MODE: No actual changes will be made" -Color $Colors.Warning
}

Write-Host ""

# Check prerequisites
Write-ColorOutput "Checking prerequisites..." -Color $Colors.Info
$gitAvailable = git --version 2>$null
if (-not $gitAvailable) {
    Write-ColorOutput "✗ Git is not installed. Please install Git for Windows." -Color $Colors.Error
    exit 1
}
Write-ColorOutput "✓ Git is installed" -Color $Colors.Success

$ghAvailable = gh --version 2>$null
if (-not $ghAvailable) {
    Write-ColorOutput "✗ GitHub CLI is not installed. Please install it:" -Color $Colors.Error
    Write-ColorOutput "  Download: https://cli.github.com/" -Color $Colors.Error
    exit 1
}
Write-ColorOutput "✓ GitHub CLI is installed" -Color $Colors.Success

# Check GitHub authentication
$ghAuth = gh auth status 2>&1
if ($LASTEXITCODE -ne 0) {
    Write-ColorOutput "✗ Not authenticated with GitHub CLI. Please run: gh auth login" -Color $Colors.Error
    exit 1
}
Write-ColorOutput "✓ GitHub authenticated" -Color $Colors.Success

Write-Host ""

# Process each folder
$processedCount = 0
foreach ($folder in $FOLDERS_TO_PROCESS) {
    $folderPath = Join-Path $ParentPath $folder
    
    Write-ColorOutput "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -Color $Colors.Info
    Write-ColorOutput "Processing: $folder" -Color $Colors.Info
    Write-ColorOutput "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -Color $Colors.Info
    
    $result = @{
        Folder = $folder
        Status = "Pending"
        GitHubUrl = ""
        Error = ""
    }
    
    # Validation checks
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
    
    # Check for existing git repo
    if (Test-GitRepository -Path $folderPath) {
        Write-ColorOutput "⊘ Git repository already exists" -Color $Colors.Warning
        if ($SkipExisting) {
            Write-ColorOutput "Skipping (use -SkipExisting:$false to override)" -Color $Colors.Info
            $result.Status = "Skipped"
            $result.Error = "Already has .git"
            $Results += $result
            continue
        }
    }
    
    # Initialize Git repository
    if (-not (Initialize-GitRepo -Path $folderPath -WhatIf $Whatif)) {
        $result.Status = "Failed"
        $result.Error = "Git initialization failed"
        $Results += $result
        continue
    }
    
    # Create GitHub repository
    if (-not (New-GitHubRepository -RepoName $folder -WhatIf $Whatif)) {
        $result.Status = "Failed"
        $result.Error = "GitHub repo creation failed"
        $Results += $result
        continue
    }
    
    # Configure git remote and push
    if (-not $Whatif) {
        try {
            Push-Location $folderPath
            $remoteUrl = git config --get remote.origin.url 2>$null
            if (-not $remoteUrl) {
                $user = gh api user --jq '.login'
                $remoteUrl = "https://github.com/$user/$folder.git"
                git remote add origin $remoteUrl
            }
            Pop-Location
        }
        catch {
            Write-ColorOutput "⚠ Warning setting remote URL: $_" -Color $Colors.Warning
        }
    }
    
    # Push to GitHub
    if (-not (Push-ToGitHub -Path $folderPath -RepoName $folder -WhatIf $Whatif)) {
        $result.Status = "Failed"
        $result.Error = "Push to GitHub failed"
        $Results += $result
        continue
    }
    
    # Get GitHub URL
    $githubUrl = Get-GitHubRepoUrl -RepoName $folder
    
    $result.Status = "Success"
    $result.GitHubUrl = $githubUrl
    $Results += $result
    
    Write-ColorOutput "✓ Completed: $githubUrl" -Color $Colors.Success
    Write-Host ""
    $processedCount++
}

# ============================================================================
# SUMMARY REPORT
# ============================================================================

Write-Host ""
Write-ColorOutput "╔════════════════════════════════════════════════════════════════╗" -Color $Colors.Info
Write-ColorOutput "║                      SUMMARY REPORT                           ║" -Color $Colors.Info
Write-ColorOutput "╚════════════════════════════════════════════════════════════════╝" -Color $Colors.Info
Write-Host ""

$successCount = ($Results | Where-Object { $_.Status -eq "Success" }).Count
$skippedCount = ($Results | Where-Object { $_.Status -eq "Skipped" }).Count
$failedCount = ($Results | Where-Object { $_.Status -eq "Failed" }).Count

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

# Log results to file
$logPath = Join-Path $ParentPath "deployment-results.txt"
$Results | Format-Table -AutoSize | Out-File -FilePath $logPath
Write-ColorOutput "Results saved to: $logPath" -Color $Colors.Info
