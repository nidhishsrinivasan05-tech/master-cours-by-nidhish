# GitHub Repos Automation - Setup & Usage Guide

## Overview
This PowerShell script automates the creation of separate GitHub repositories for multiple local folders. It handles Git initialization, file commits, GitHub repository creation, and pushes all in one workflow.

## Prerequisites

### 1. **Git Installation**
- Download and install from: https://git-scm.com/download/win
- Verify installation:
  ```powershell
  git --version
  ```

### 2. **GitHub CLI Installation**
- Download and install from: https://cli.github.com/
- Verify installation:
  ```powershell
  gh --version
  ```

### 3. **GitHub Authentication**
After installing GitHub CLI, authenticate with your GitHub account:
```powershell
gh auth login
```

Follow the prompts:
- Select "GitHub.com" (default)
- Select "HTTPS" (recommended)
- Authenticate with browser when prompted
- Save your selection

Verify authentication:
```powershell
gh auth status
```

### 4. **Git Global Configuration (Optional but Recommended)**
```powershell
git config --global user.name "Your Name"
git config --global user.email "your.email@github.com"
```

## Script Features

✓ **Checks prerequisites** - Verifies Git and GitHub CLI are installed and authenticated
✓ **Skips existing repos** - Won't reinitialize folders with existing .git directories
✓ **Skips empty folders** - Ignores empty directories
✓ **Handles nested structures** - Works with folder/folder nested layouts
✓ **Smart commits** - Only commits if there are changes
✓ **Auto-makes repositories public** - Ensures all repos are public
✓ **Dry run mode** - Preview changes without making them
✓ **Detailed logging** - Color-coded console output with progress tracking

## Usage

### Basic Usage (Dry Run First - Recommended!)
```powershell
# Navigate to your study folder
cd c:\Study

# Run in dry run mode first to preview changes
.\github-repos-automation.ps1 -DryRun
```

### Execute the Script
```powershell
# Run the actual automation
.\github-repos-automation.ps1
```

### Advanced Options

```powershell
# Custom parent path
.\github-repos-automation.ps1 -ParentPath "C:\Your\Custom\Path"

# Dry run to preview changes
.\github-repos-automation.ps1 -DryRun

# Skip pushing to GitHub (initialize local git only)
.\github-repos-automation.ps1 -SkipPush

# Force re-initialization (use with caution)
.\github-repos-automation.ps1 -Force
```

## Target Folders

The script will process these folders:

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

## Step-by-Step Execution

### Step 1: Prepare Your Environment
```powershell
# Open PowerShell as Administrator (recommended)
# Navigate to the script location
cd c:\Study

# Verify prerequisites
git --version
gh --version
gh auth status
```

### Step 2: Preview Changes (Dry Run)
```powershell
.\github-repos-automation.ps1 -DryRun
```

Review the output to ensure:
- All target folders are found
- No folders are incorrectly identified as empty
- GitHub authentication is confirmed

### Step 3: Execute
```powershell
.\github-repos-automation.ps1
```

### Step 4: Verify Results
The script will output a summary report with links to created repositories.

## Sample Output

```
ℹ️  INFO: ==========================================
ℹ️  INFO: GitHub Repository Automation Script
ℹ️  INFO: ==========================================
✓ SUCCESS: Git installed: git version 2.43.0.windows.1
✓ SUCCESS: GitHub CLI installed: gh version 2.47.0 (2024-03-10)
✓ SUCCESS: GitHub authentication verified

ℹ️  INFO: ==========================================
ℹ️  INFO: Processing Folders
ℹ️  INFO: ==========================================

ℹ️  INFO: Processing: 4-starter-packs
ℹ️  INFO:   └─ Initializing git repository
ℹ️  INFO:   └─ Adding files and creating initial commit
ℹ️  INFO:   └─ Creating GitHub repository
✓ SUCCESS:   ✓ Completed: 4-starter-packs

...

ℹ️  INFO: ==========================================
ℹ️  INFO: Summary Report
ℹ️  INFO: ==========================================

Status Summary:
  - Success:  11
  - Skipped:  0
  - Failed:   0
  - Dry Run:  0

GitHub Repository Links:
==================================
4-starter-packs:
  https://github.com/yourusername/4-starter-packs
...
```

## Troubleshooting

### "Git is not installed"
- Install Git from: https://git-scm.com/download/win
- Restart PowerShell after installation

### "GitHub CLI is not installed"
- Install from: https://cli.github.com/
- Restart PowerShell after installation

### "GitHub authentication failed"
```powershell
gh auth login
```

### "Repository already exists" warning
- The script detects existing repositories and skips creation
- To re-push, ensure you have an upstream remote configured:
  ```powershell
  cd <folder-path>
  git remote -v
  git push -u origin main
  ```

### Execution Policy Error
If you get an execution policy error:
```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```
Then run the script again.

### "Remote rejected" error
- Ensure you're authenticated: `gh auth status`
- Check repository doesn't already exist: `gh repo view <folder-name>`
- Verify your GitHub account has permission to create repositories

## What the Script Does for Each Folder

For each target folder, the script:

1. **Validates** the folder exists and isn't empty
2. **Checks** if Git is already initialized
3. **Initializes Git** if needed (`git init`)
4. **Adds all files** (`git add -A`)
5. **Creates initial commit** if it's a new repo
6. **Creates a GitHub repository** using the folder name
7. **Sets it to public** visibility
8. **Pushes** to GitHub with main/master branch

## Important Notes

⚠️ **Backup First**: Ensure you have backups of your folders before running
⚠️ **Network Access**: Requires internet connection for GitHub operations
⚠️ **GitHub Limits**: GitHub has API rate limits (60 requests/hour unauthenticated, 5000/hour authenticated)
⚠️ **Destructive Actions**: While the script is safe, it commits all local files. Review before running on production folders.

## Security Notes

- GitHub CLI stores credentials securely in your system credential manager
- SSH support available with: `gh auth login --web` followed by SSH key setup
- Personal Access Tokens: Can be used instead of password authentication
- Never commit secrets or sensitive data - add to `.gitignore` first

## Next Steps After Running

1. **Review your repositories**: Visit https://github.com/your-username?tab=repositories
2. **Add descriptions**: Edit README and repository settings
3. **Add collaborators**: If needed, invite team members to specific repos
4. **Configure branch protection**: Set up rules for main/master branches
5. **Enable discussions**: Turn on GitHub Discussions if desired

## Customization

### Modifying Target Folders
Edit the `$TargetFolders` array in the script:
```powershell
$TargetFolders = @(
    "folder-name-1",
    "folder-name-2",
    # Add more folders here
)
```

### Custom Commit Message
Modify the commit message in this line:
```powershell
git commit -m "Initial commit - automated repository setup"
```

### Change Git Author
Modify in the script:
```powershell
git config user.name "Your Name"
git config user.email "your.email@github.com"
```

## Support & Help

- **Git Documentation**: https://git-scm.com/doc
- **GitHub CLI Documentation**: https://cli.github.com/manual
- **GitHub Help**: https://docs.github.com
- **Issues with Script**: Review error messages and check prerequisites

## Version Information

- **Script Version**: 1.0
- **Created**: 2026-03-23
- **Tested on**: PowerShell 5.1+ / PowerShell Core 7.x
- **Windows**: Windows 10, Windows 11

---

**Ready to automate? Start with:**
```powershell
cd c:\Study
.\github-repos-automation.ps1 -DryRun
```
