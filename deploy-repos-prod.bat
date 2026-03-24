@echo off
REM GitHub Repository Automation - Production Mode
REM This file will execute the PowerShell deployment

powershell -NoProfile -ExecutionPolicy Bypass -Command ^
  "$folders = @('4-starter-packs','blockchain-full-package','build-your-own-x-master','developer-roadmap-master','galaxy-portfolio-main','java-full-package','openai-cookbook-main','Portfolio-Sixth-main','public-apis-master','SpacePortfolio-main','system-design-primer-master'); " ^
  "$parentPath = 'C:\Study'; " ^
  "$results = @(); " ^
  "Write-Host ''; Write-Host '╔════════════════════════════════════════════════════════════════╗' -ForegroundColor Cyan; " ^
  "Write-Host '║  GitHub Repository Creation and Deployment Automation               ║' -ForegroundColor Cyan; " ^
  "Write-Host '╚════════════════════════════════════════════════════════════════╝' -ForegroundColor Cyan; " ^
  "Write-Host ''; Write-Host 'Parent directory: ' + $parentPath -ForegroundColor Cyan; Write-Host 'Processing folders: ' + $folders.Count -ForegroundColor Cyan; Write-Host ''; " ^
  "Write-Host 'Checking prerequisites...' -ForegroundColor Cyan; " ^
  "if ( !(git --version 2>$null) ) { Write-Host '✗ Git not installed' -ForegroundColor Red; exit 1 } Write-Host '✓ Git installed' -ForegroundColor Green; " ^
  "if ( !(gh --version 2>$null) ) { Write-Host '✗ GitHub CLI not installed' -ForegroundColor Red; exit 1 } Write-Host '✓ GitHub CLI installed' -ForegroundColor Green; " ^
  "gh auth status 2>$null; if ($LASTEXITCODE -ne 0) { Write-Host '✗ GitHub not authenticated' -ForegroundColor Red; exit 1 } Write-Host '✓ Authenticated' -ForegroundColor Green; Write-Host ''; " ^
  "foreach ($folder in $folders) { $folderPath = Join-Path $parentPath $folder; Write-Host '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━' -ForegroundColor Cyan; Write-Host 'Processing: ' + $folder -ForegroundColor Cyan; Write-Host '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━' -ForegroundColor Cyan; " ^
  "$result = @{ Folder = $folder; Status = 'Pending'; Url = ''; Notes = '' }; " ^
  "if ( !(Test-Path -Path $folderPath -PathType Container) ) { Write-Host '⊘ Folder not found' -ForegroundColor Yellow; $result.Status = 'Skipped'; $result.Notes = 'Not found'; $results += $result; continue } " ^
  "$items = @(Get-ChildItem -Path $folderPath -Recurse -ErrorAction SilentlyContinue | Where-Object { -not $_.PSIsContainer }); " ^
  "if ($items.Count -eq 0) { Write-Host '⊘ Empty folder' -ForegroundColor Yellow; $result.Status = 'Skipped'; $result.Notes = 'Empty'; $results += $result; continue } " ^
  "if (Test-Path -Path (Join-Path $folderPath '.git') -PathType Container) { Write-Host '⊘ .git already exists' -ForegroundColor Yellow; $result.Status = 'Skipped'; $result.Notes = 'Has .git'; $results += $result; continue } " ^
  "Write-Host '📁 Initializing Git...' -ForegroundColor Cyan; Push-Location $folderPath; git init 2>$null | Out-Null; git add . 2>$null | Out-Null; git commit -m ('Initial commit: ' + $folder) 2>$null | Out-Null; Pop-Location; Write-Host '📝 Files committed' -ForegroundColor Green; " ^
  "Write-Host '🌐 Creating GitHub repository...' -ForegroundColor Cyan; gh repo create $folder --public --source=. --remote=origin --push 2>&1 | Out-Null; if ($LASTEXITCODE -eq 0) { Write-Host '✓ Repository created' -ForegroundColor Green } else { Write-Host '✗ Failed' -ForegroundColor Red; $result.Status = 'Failed'; $result.Notes = 'Creation failed'; $results += $result; continue } " ^
  "$user = gh api user --jq '.login' 2>$null; if ($user) { $url = ('https://github.com/' + $user + '/' + $folder) } else { $url = 'https://github.com/{username}/' + $folder }; " ^
  "$result.Status = 'Success'; $result.Url = $url; $results += $result; " ^
  "Write-Host ('✓ Complete: ' + $url) -ForegroundColor Green; Write-Host ''; } " ^
  "Write-Host ''; Write-Host '╔════════════════════════════════════════════════════════════════╗' -ForegroundColor Cyan; " ^
  "Write-Host '║                      DEPLOYMENT COMPLETE                         ║' -ForegroundColor Cyan; " ^
  "Write-Host '╚════════════════════════════════════════════════════════════════╝' -ForegroundColor Cyan; " ^
  "Write-Host ''; " ^
  "$successCount = ($results | Where-Object { $_.Status -eq 'Success' }).Count; " ^
  "$skippedCount = ($results | Where-Object { $_.Status -eq 'Skipped' }).Count; " ^
  "$failedCount = ($results | Where-Object { $_.Status -eq 'Failed' }).Count; " ^
  "Write-Host ('Total: ' + $results.Count) -ForegroundColor Cyan; " ^
  "Write-Host ('✓ Success: ' + $successCount) -ForegroundColor Green; " ^
  "Write-Host ('⊘ Skipped: ' + $skippedCount) -ForegroundColor Yellow; " ^
  "Write-Host ('✗ Failed: ' + $failedCount) -ForegroundColor Red; " ^
  "Write-Host ''; Write-Host 'GitHub Repository Links:' -ForegroundColor Cyan; Write-Host '───────────────────────────────────────────────────────────────' -ForegroundColor Cyan; " ^
  "foreach ($result in $results) { if ($result.Status -eq 'Success') { Write-Host ($result.Folder + ': ' + $result.Url) -ForegroundColor Green } elseif ($result.Status -eq 'Skipped') { Write-Host ($result.Folder + ': [SKIPPED]') -ForegroundColor Yellow } else { Write-Host ($result.Folder + ': [FAILED]') -ForegroundColor Red } } " ^
  "Write-Host ''; Write-Host 'Done!' -ForegroundColor Green; Write-Host ''; "

pause
