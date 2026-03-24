# Quick Reference & Cheat Sheet

## 🚀 Quick Start (60 seconds)

### Option 1: GUI Launcher (Easiest)
```batch
run-github-automation.bat
```
Then select option from menu

### Option 2: Direct PowerShell (Dry Run First)
```powershell
cd c:\Study
.\github-repos-automation.ps1 -DryRun    # Preview changes
.\github-repos-automation.ps1             # Execute
```

## ✅ Pre-Flight Checklist

- [ ] Windows PowerShell or PowerShell Core installed
- [ ] Git installed (https://git-scm.com/download/win)
- [ ] GitHub CLI installed (https://cli.github.com/)
- [ ] Authenticated with GitHub (`gh auth login`)
- [ ] All 11 target folders present in `c:\Study`
- [ ] Internet connection active

## 📋 What Gets Created

| Folder | Repository | URL |
|--------|-----------|-----|
| 4-starter-packs | 4-starter-packs | `https://github.com/username/4-starter-packs` |
| blockchain-full-package | blockchain-full-package | `https://github.com/username/blockchain-full-package` |
| build-your-own-x-master | build-your-own-x-master | `https://github.com/username/build-your-own-x-master` |
| developer-roadmap-master | developer-roadmap-master | `https://github.com/username/developer-roadmap-master` |
| galaxy-portfolio-main | galaxy-portfolio-main | `https://github.com/username/galaxy-portfolio-main` |
| java-full-package | java-full-package | `https://github.com/username/java-full-package` |
| openai-cookbook-main | openai-cookbook-main | `https://github.com/username/openai-cookbook-main` |
| Portfolio-Sixth-main | Portfolio-Sixth-main | `https://github.com/username/Portfolio-Sixth-main` |
| public-apis-master | public-apis-master | `https://github.com/username/public-apis-master` |
| SpacePortfolio-main | SpacePortfolio-main | `https://github.com/username/SpacePortfolio-main` |
| system-design-primer-master | system-design-primer-master | `https://github.com/username/system-design-primer-master` |

## 🔧 Common Commands

### GitHub Setup
```powershell
# First time setup
gh auth login

# Check status
gh auth status

# Verify user
gh api user --jq .login
```

### Manual Git Operations
```powershell
# Check if repo initialized
cd <folder>
git status

# View commit history
git log --oneline

# Check remote
git remote -v

# Force push (risky!)
git push -f origin main
```

### GitHub CLI Shortcuts
```powershell
# List your repos
gh repo list

# View a specific repo
gh repo view <repo-name>

# Make private
gh repo edit <repo-name> --visibility private

# Make public
gh repo edit <repo-name> --visibility public

# Delete repo (dangerous!)
gh repo delete <repo-name>
```

## 🎯 Execution Modes

### Dry Run (Safe Preview)
```powershell
.\github-repos-automation.ps1 -DryRun
```
Preview what will happen without making changes

### Execute (Full Automation)
```powershell
.\github-repos-automation.ps1
```
Create repos, push code, and set to public

### Skip Push (Local Git Only)
```powershell
.\github-repos-automation.ps1 -SkipPush
```
Initialize Git and commit locally, don't push to GitHub

### Custom Path
```powershell
.\github-repos-automation.ps1 -ParentPath "C:\Other\Path"
```

## ⚠️ Warnings & Cautions

| Action | Risk | Solution |
|--------|------|----------|
| Running without -DryRun | Changes made immediately | Always test -DryRun first |
| Existing .git folders | Skipped if present | Remove .git if re-init needed |
| Empty folders | Skipped silently | Expected behavior |
| Large files | Long upload time | Push during off-peak |
| Large repos | GitHub API limits | Process in batches |

## 🆘 Troubleshooting Quick Fixes

### "Git command not found"
```powershell
# Reinstall and add to PATH
[Environment]::SetEnvironmentVariable("Path", $env:Path + ";C:\Program Files\Git\cmd", "User")
# Restart PowerShell
```

### "GitHub CLI not authenticated"
```powershell
gh auth login
# Select: GitHub.com
# Select: HTTPS
# Authenticate in browser
# Choose: Paste authentication token (or do login)
```

### "Repository already exists"
```powershell
# Either:
# 1. Use existing repo (script skips creation)
# 2. Delete and recreate
gh repo delete <repo-name> --confirm
# Then run script again
```

### "Permission denied" / "Access forbidden"
```powershell
gh auth logout
gh auth login
# Reauthenticate with new credentials
```

### "Execution policy error"
```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

### "SSL certificate problem"
```powershell
# Try with HTTP instead of HTTPS
git config --global url."https://".insteadOf git://
```

### Script Hangs
```powershell
# Kill the PowerShell process and retry
# Check: gh auth status
# Check: internet connection
# Try: Clear the PowerShell cache
```

## 📊 Expected Output Sample

```
ℹ️  INFO: ==========================================
✓ SUCCESS: Git installed: git version 2.43.0.windows.1
✓ SUCCESS: GitHub CLI installed: gh version 2.47.0

ℹ️  INFO: Processing: 4-starter-packs
ℹ️  INFO:   └─ Initializing git repository
ℹ️  INFO:   └─ Adding files and creating initial commit
✓ SUCCESS:   ✓ Completed: 4-starter-packs

... (11 total folders) ...

Status Summary:
  - Success:  11
  - Skipped:  0
  - Failed:   0

✓ SUCCESS: GitHub automation completed!
```

## 🔐 Security Best Practices

```powershell
# DON'T commit sensitive data - create .gitignore first
echo "secrets.txt" > .gitignore
echo "*.env" >> .gitignore
git add .gitignore
git commit -m "Add gitignore"

# Review .git folder permissions
ls -Attributes .git

# Check git configuration
git config --list

# Use SSH instead of HTTPS (optional, more secure)
gh auth login --with-token  # If using SSH
```

## 📈 Advanced Usage

### Batch Process Multiple Parents
```powershell
$paths = @("C:\Path1", "C:\Path2", "C:\Path3")
foreach ($path in $paths) {
    .\github-repos-automation.ps1 -ParentPath $path
}
```

### Log Output to File
```powershell
.\github-repos-automation.ps1 | Tee-Object -FilePath automation.log
```

### Schedule as Scheduled Task
```powershell
# Create trigger
$trigger = New-ScheduledTaskTrigger -AtLogOn

# Create action
$action = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-NoProfile -File C:\Study\github-repos-automation.ps1"

# Register task
Register-ScheduledTask -TaskName "GitHub-Repos-Automation" -Trigger $trigger -Action $action -RunLevel Highest
```

## 📞 Support Resources

| Issue | Resource |
|-------|----------|
| Git problems | https://git-scm.com/doc |
| GitHub CLI help | `gh help` or https://cli.github.com/manual |
| GitHub API docs | https://docs.github.com/en/rest |
| PowerShell help | `Get-Help` or https://learn.microsoft.com/powershell |

## 🎓 Learning Resources

- **Git Basics**: https://git-scm.com/book/en/v2
- **GitHub Guides**: https://guides.github.com
- **GitHub API**: https://docs.github.com/en/rest
- **PowerShell**: https://learn.microsoft.com/en-us/powershell/

## 📝 Files Included

| File | Purpose |
|------|---------|
| `github-repos-automation.ps1` | Main automation script |
| `run-github-automation.bat` | Easy GUI launcher |
| `GITHUB-AUTOMATION-GUIDE.md` | Detailed documentation |
| `QUICK-REFERENCE.md` | This file |
| `README-DEPLOYMENT.md` | Original deployment guide |

## ✨ Pro Tips

💡 **Tip 1**: Always run with `-DryRun` first
```powershell
.\github-repos-automation.ps1 -DryRun
```

💡 **Tip 2**: Keep your GitHub token safe
```powershell
gh auth token | Set-Clipboard  # Copy token securely
```

💡 **Tip 3**: Use SSH for repeated pushes
```powershell
gh ssh-key add ~/.ssh/id_ed25519.pub
```

💡 **Tip 4**: Add useful .gitignore early
```powershell
# PowerShell example
".DS_Store", "*.log", "node_modules/" | 
    Out-File .gitignore
```

💡 **Tip 5**: Write good commit messages
```powershell
git commit -m "feat: Add new feature" -m "Detailed description of changes"
```

---

**Last Updated**: 2026-03-23
**Status**: Ready to Use ✓
