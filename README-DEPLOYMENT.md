# GitHub Repository Automation Guide

## Overview

The `deploy-repos.ps1` script automates the creation of separate GitHub repositories for your specified folders and pushes all content to GitHub.

## Prerequisites

Before running the script, ensure you have:

### 1. Git for Windows
- Download: https://git-scm.com/download/win
- Verify installation: Open PowerShell and run:
  ```powershell
  git --version
  ```

### 2. GitHub CLI
- Download: https://cli.github.com/
- Verify installation: Open PowerShell and run:
  ```powershell
  gh --version
  ```

### 3. GitHub Authentication
- Authenticate with GitHub CLI:
  ```powershell
  gh auth login
  ```
- Follow the prompts and select:
  - GitHub.com (not GitHub Enterprise)
  - HTTPS (recommended)
  - Paste authentication token when prompted

Verify authentication:
```powershell
gh auth status
```

## Folders Processed

The script will create repositories for these folders:

1. 4-starter-packs
2. blockchain-full-package
3. build-your-own-x-master
4. developer-roadmap-master
5. galaxy-portfolio-main
6. java-full-package
7. openai-cookbook-main
8. Portfolio-Sixth-main
9. public-apis-master
10. SpacePortfolio-main
11. system-design-primer-master

## Usage

### Basic Usage (Production)
```powershell
cd C:\Study
.\deploy-repos.ps1
```

### Simulation Mode (Recommended First Run)
Test without making changes:
```powershell
.\deploy-repos.ps1 -Whatif
```

### Advanced Options

**Skip folders that already have .git (default behavior):**
```powershell
.\deploy-repos.ps1 -SkipExisting
```

**Process all folders, even if they have .git:**
```powershell
.\deploy-repos.ps1 -SkipExisting:$false
```

**Specify a different parent directory:**
```powershell
.\deploy-repos.ps1 -ParentPath "C:\YourPath"
```

## What the Script Does

For each folder:

1. ✓ **Validates** the folder exists and is not empty
2. ⚠ **Warns** if .zip files are present
3. ⊘ **Skips** folders that already have .git (unless `-SkipExisting:$false`)
4. 📁 **Initializes** a local Git repository
5. 📝 **Commits** all files with message "Initial commit: [folder-name]"
6. 🌐 **Creates** a new public GitHub repository
7. 🚀 **Pushes** code to GitHub (main or master branch)
8. 📋 **Reports** results with GitHub links

## Expected Output

```
╔════════════════════════════════════════════════════════════════╗
║     GitHub Repository Creation and Deployment Automation       ║
╚════════════════════════════════════════════════════════════════╝

Parent directory: C:\Study
Processing folders: 11

✓ Git is installed
✓ GitHub CLI is installed
✓ GitHub authenticated

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Processing: 4-starter-packs
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📁 Initializing Git in 4-starter-packs...
...
✓ Completed: https://github.com/username/4-starter-packs
```

## Results

After completion, check:
- **deployment-results.txt** - Detailed results saved to C:\Study\deployment-results.txt
- All created repositories will be **public** by default
- Each repository will have all files from the original folder committed

## GitHub Links After Creation

All repositories will be available at:
```
https://github.com/[your-username]/[folder-name]
```

For example:
- https://github.com/your-username/4-starter-packs
- https://github.com/your-username/blockchain-full-package
- etc.

## Troubleshooting

### "GitHub CLI is not installed"
```powershell
# Install GitHub CLI
# Go to https://cli.github.com/ and follow installation instructions
# Then run:
gh auth login
```

### "Not authenticated with GitHub CLI"
```powershell
# Authenticate again
gh auth login
```

### "Git is not installed"
```powershell
# Install Git for Windows
# Go to https://git-scm.com/download/win
# Then verify:
git --version
```

### "Repository [name] already exists on GitHub"
Either:
1. Delete the repository from GitHub manually, or
2. The script will skip it if .git folder exists locally

### Access Denied Errors
- Verify GitHub CLI authentication: `gh auth status`
- Check that your GitHub account has permission to create repositories
- Check your GitHub token scopes include `repo` and `public_repo`

## Safety Features

✓ **Pre-execution simulation mode** - Use `-Whatif` to preview actions  
✓ **Skips existing repositories** - Won't overwrite .git folders  
✓ **Skips empty folders** - Only processes folders with content  
✓ **Skips zip files warning** - Alerts you if zip files are present  
✓ **Detailed logging** - All results saved to deployment-results.txt  
✓ **Rollback friendly** - Can delete repos individually from GitHub if needed

## Next Steps

1. **First run**: Execute with `-Whatif` flag to preview
2. **Review output**: Check the simulation results
3. **Production run**: Run without `-Whatif` flag
4. **Verify**: Check your GitHub account for new repositories
5. **Share links**: Use the GitHub links from the summary report

## Support

For GitHub CLI help:
```powershell
gh repo create --help
gh auth --help
```

For Git help:
```powershell
git status
git log
```
