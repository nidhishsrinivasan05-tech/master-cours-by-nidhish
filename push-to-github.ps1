param(
    [string]$GitHubToken = $env:GITHUB_TOKEN,
    [string]$Username = "nidhishsrinivasan05-tech",
    [string]$ParentPath = "c:\Study",
    [switch]$DryRun = $false
)

Write-Host ""
Write-Host "GitHub Automation - Complete Solution"
Write-Host "======================================"
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

if (-not (Test-Path $ParentPath)) {
    Write-Host "ERROR: Parent path not found" -ForegroundColor Red
    exit 1
}

Write-Host "Setup:" -ForegroundColor Green
Write-Host "  Parent: $ParentPath"
Write-Host "  User: $Username"
Write-Host "  Repos: $($TargetFolders.Count)"
Write-Host ""

if ($DryRun) {
    Write-Host "Mode: DRY RUN (no changes)" -ForegroundColor Blue
} else {
    Write-Host "Mode: EXECUTE" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "Initializing local Git repositories..."
Write-Host ""

$count = 0
foreach ($folder in $TargetFolders) {
    $path = Join-Path $ParentPath $folder
    
    if (-not (Test-Path $path)) {
        Write-Host "[SKIP] $folder - not found"
        continue
    }
    
    $items = @(Get-ChildItem $path -Force -Exclude ".git")
    if ($items.Count -eq 0) {
        Write-Host "[SKIP] $folder - empty"
        continue
    }
    
    Write-Host "[OK] $folder" -ForegroundColor Green
    
    if ($DryRun) {
        $count++
        continue
    }
    
    # Work with actual path
    $actualPath = $path
    $subs = @(Get-ChildItem $path -Directory -Force)
    if ($subs.Count -eq 1 -and $subs[0].Name -eq $folder) {
        $nested = Join-Path $path $folder
        if (Test-Path $nested) {
            $actualPath = $nested
        }
    }
    
    # Initialize git if needed
    $gitPath = Join-Path $actualPath ".git"
    if (-not (Test-Path $gitPath)) {
        Push-Location $actualPath
        git init 2>&1 | Out-Null
        git config user.name "Automation" 2>&1 | Out-Null
        git config user.email "auto@local" 2>&1 | Out-Null
        git add -A 2>&1 | Out-Null
        git commit -m "Initial commit" 2>&1 | Out-Null
        Pop-Location
    }
    
    $count++
}

Write-Host ""
Write-Host "Result: $count repos ready"
Write-Host ""

if (-not [string]::IsNullOrEmpty($GitHubToken) -and -not $DryRun) {
    Write-Host "Pushing to GitHub..." -ForegroundColor Cyan
    Write-Host ""
    
    $pushed = 0
    foreach ($folder in $TargetFolders) {
        $path = Join-Path $ParentPath $folder
        if (-not (Test-Path $path)) { continue }
        
        $items = @(Get-ChildItem $path -Force -Exclude ".git")
        if ($items.Count -eq 0) { continue }
        
        $actualPath = $path
        $subs = @(Get-ChildItem $path -Directory -Force)
        if ($subs.Count -eq 1 -and $subs[0].Name -eq $folder) {
            $nested = Join-Path $path $folder
            if (Test-Path $nested) {
                $actualPath = $nested
            }
        }
        
        Write-Host "[PUSH] $folder" -NoNewline -ForegroundColor Cyan
        
        Push-Location $actualPath
        
        $url = "https://$Username`:$GitHubToken@github.com/$Username/$folder.git"
        git remote add origin $url 2>$null
        git remote set-url origin $url 2>$null
        
        $branch = git rev-parse --abbrev-ref HEAD 2>$null
        if ([string]::IsNullOrEmpty($branch)) { $branch = "main" }
        
        $result = git push -u origin $branch 2>&1
        
        if ($LASTEXITCODE -eq 0) {
            Write-Host " - OK" -ForegroundColor Green
            $pushed++
        } else {
            Write-Host " - FAILED" -ForegroundColor Red
        }
        
        Pop-Location
    }
    
    Write-Host ""
    Write-Host "Pushed: $pushed/$count repos"
}

Write-Host ""
Write-Host "GitHub URLs:"
foreach ($folder in $TargetFolders) {
    Write-Host "  https://github.com/$Username/$folder" -ForegroundColor Green
}

Write-Host ""
Write-Host "COMPLETE!"
Write-Host ""
exit 0
