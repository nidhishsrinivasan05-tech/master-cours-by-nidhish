# GitHub Repos Automation Suite

Complete solution for automating the creation of separate GitHub repositories from multiple local folders on Windows.

## 📦 What You're Getting

| File | Purpose |
|------|---------|
| **github-repos-automation.ps1** | Main PowerShell automation script (core tool) |
| **run-github-automation.bat** | Easy GUI launcher for Windows (start here!) |
| **validate-system.ps1** | System validation & diagnostics |
| **GITHUB-AUTOMATION-GUIDE.md** | Detailed setup and usage documentation |
| **QUICK-REFERENCE.md** | Cheat sheet and common commands |
| **README.md** | This file |

## 🚀 Quick Start (3 Steps)

### Step 1️⃣: Validate Your System
```powershell
cd c:\Study
.\validate-system.ps1
```
This checks that Git, GitHub CLI, and authentication are properly configured.

### Step 2️⃣: Preview Changes (Dry Run)
```powershell
.\github-repos-automation.ps1 -DryRun
```
This shows what will happen without making any changes.

### Step 3️⃣: Execute Automation
```powershell
.\github-repos-automation.ps1
```
This creates repositories, pushes code, and makes everything public.

---

## 🎯 What Gets Done

For each of your 11 folders:
- ✓ Initializes Git repository
- ✓ Commits all files with initial commit
- ✓ Creates GitHub repository
- ✓ Pushes code to GitHub
- ✓ Sets repository to public
- ✓ Provides direct GitHub link

**Target Folders:**
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

---

## 📋 Requirements

> **Note**: If you don't have these installed, the validation script will tell you exactly what to install.

- **Windows 10 or Windows 11**
- **PowerShell 5.1** or **PowerShell Core 7.x+**
- **Git** (https://git-scm.com/download/win)
- **GitHub CLI** (https://cli.github.com/)
- **GitHub Account** (https://github.com)
- **Internet Connection**

### Setup in 2 Minutes

1. **Install Git:**
   ```
   https://git-scm.com/download/win
   ```

2. **Install GitHub CLI:**
   ```
   https://cli.github.com/
   ```

3. **Authenticate:**
   ```powershell
   gh auth login
   ```
   Follow the prompts and authenticate with your browser.

4. **Verify:**
   ```powershell
   gh auth status
   ```

---

## 💡 Usage Examples

### Easy Way (Recommended)
```batch
run-github-automation.bat
```
Then select your option from the menu.

### PowerShell Way (Advanced)

**Dry run first:**
```powershell
.\github-repos-automation.ps1 -DryRun
```

**Execute:**
```powershell
.\github-repos-automation.ps1
```

**Custom parent folder:**
```powershell
.\github-repos-automation.ps1 -ParentPath "C:\Another\Path"
```

**Skip GitHub push (local Git only):**
```powershell
.\github-repos-automation.ps1 -SkipPush
```

---

## ⚠️ Safety Features

✓ **Dry run mode** - Preview all changes before executing
✓ **Skips existing repos** - Won't reinitialize if .git exists
✓ **Skips empty folders** - Ignores empty directories
✓ **Warns on conflicts** - Shows warnings for potential issues
✓ **Detailed logging** - Color-coded output shows exactly what's happening

---

## 🔍 Troubleshooting

### "Git is not installed"
```powershell
# Install Git:
# 1. Visit: https://git-scm.com/download/win
# 2. Run installer
# 3. Restart PowerShell
```

### "GitHub CLI is not installed"
```powershell
# Install GitHub CLI:
# 1. Visit: https://cli.github.com/
# 2. Run installer
# 3. Restart PowerShell
```

### "GitHub authentication failed"
```powershell
gh auth logout
gh auth login
# Follow prompts to authenticate
```

### "Cannot run scripts" (Execution Policy)
```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
# Then run the script again
```

### "Repository already exists"
Option 1: Use the existing repository (script skips creation)
Option 2: Delete and recreate:
```powershell
gh repo delete <repo-name> --confirm
# Then run script again
```

---

## 📊 What You'll Get

After running, you'll have:

```
GitHub Profile: github.com/yourUsername
├── 4-starter-packs/
├── blockchain-full-package/
├── build-your-own-x-master/
├── developer-roadmap-master/
├── galaxy-portfolio-main/
├── java-full-package/
├── openai-cookbook-main/
├── Portfolio-Sixth-main/
├── public-apis-master/
├── SpacePortfolio-main/
└── system-design-primer-master/
```

Plus direct HTTP links to each repo:
```
https://github.com/yourUsername/4-starter-packs
https://github.com/yourUsername/blockchain-full-package
... etc
```

---

## 🎓 Next Steps After Automation

1. **Visit your repositories:**
   - Go to https://github.com/yourUsername?tab=repositories
   - All 11 repos should be visible

2. **Customize each repository:**
   - Add descriptions via GitHub web interface
   - Add topics/tags for discoverability
   - Upload logos and screenshots
   - Write comprehensive README files

3. **Optional enhancements:**
   - Add collaborators or teams
   - Set up branch protection rules
   - Enable GitHub Actions for CI/CD
   - Configure webhooks or integrations
   - Enable GitHub Pages for documentation

---

## 📚 Full Documentation

For detailed information, see:

- **[GITHUB-AUTOMATION-GUIDE.md](GITHUB-AUTOMATION-GUIDE.md)** - Complete setup and detailed usage
- **[QUICK-REFERENCE.md](QUICK-REFERENCE.md)** - Commands, tips, and troubleshooting

---

## 🔐 Security Notes

⚠️ **Important:**
- Never commit secrets (API keys, passwords, tokens)
- Use `.gitignore` to exclude sensitive files before first commit
- Personal access tokens are stored securely by GitHub CLI
- Always verify repository permissions before adding collaborators
- Keep your local `.git` folder permissions restricted

---

## 🆘 Getting Help

| Issue | Solution |
|-------|----------|
| Script errors | Run `.\validate-system.ps1` first |
| Git errors | Check https://git-scm.com/doc |
| GitHub CLI issues | Run `gh help` |
| Authentication | Run `gh auth login` |
| PowerShell issues | See execution policy section |

---

## 📝 System Requirements Check

Run this before starting:
```powershell
.\validate-system.ps1
```

This will verify:
- ✓ Windows OS (version)
- ✓ PowerShell (version)
- ✓ Git installation
- ✓ GitHub CLI installation
- ✓ GitHub authentication
- ✓ Network connectivity
- ✓ Target folders
- ✓ Disk space

---

## 🌟 Features Breakdown

### Smart Initialization
- Detects existing .git folders
- Skips re-initialization
- Handles nested folder structures
- Only commits if changes detected

### GitHub Integration
- Uses GitHub CLI for reliable API access
- Creates repositories with proper naming
- Automatically sets public visibility
- Provides direct HTTP links to each repo

### Safety & Warnings
- Dry run mode for preview
- Lists all affected folders
- Warns before destructive actions
- Detailed error messages
- Color-coded output for clarity

### Windows Native
- PowerShell (native Windows shell)
- Batch file launcher for convenience
- No additional dependencies needed
- Works on Windows 10 and 11

---

## 🚦 Execution Flow

```
Start
  ↓
[Check prerequisites]
  ├─ Git installed?
  ├─ GitHub CLI installed?
  └─ GitHub authenticated?
  ↓
[Process each folder]
  ├─ Folder exists?
  ├─ Is empty?
  ├─ Initialize Git?
  ├─ Add files?
  ├─ Create commit?
  ├─ Create GitHub repo?
  └─ Push to GitHub?
  ↓
[Report results]
  ├─ Success count
  ├─ Skip count
  ├─ Failure count
  └─ GitHub links
  ↓
Done
```

---

## 📞 Support

1. **Check Prerequisites:**
   ```powershell
   .\validate-system.ps1
   ```

2. **Review Documentation:**
   - [QUICK-REFERENCE.md](QUICK-REFERENCE.md)
   - [GITHUB-AUTOMATION-GUIDE.md](GITHUB-AUTOMATION-GUIDE.md)

3. **Manual Commands:**
   ```powershell
   # List your repos
   gh repo list
   
   # Check specific repo
   gh repo view <folder-name>
   ```

---

## 📄 Files Overview

```
c:\Study\
├── github-repos-automation.ps1    ← Main script (PowerShell)
├── run-github-automation.bat      ← Easy launcher (Batch)
├── validate-system.ps1             ← System checker (PowerShell)
├── README.md                        ← This file
├── GITHUB-AUTOMATION-GUIDE.md      ← Detailed guide
└── QUICK-REFERENCE.md              ← Cheat sheet

Target Folders (11 repos):
├── 4-starter-packs/
├── blockchain-full-package/
├── build-your-own-x-master/
├── developer-roadmap-master/
├── galaxy-portfolio-main/
├── java-full-package/
├── openai-cookbook-main/
├── Portfolio-Sixth-main/
├── public-apis-master/
├── SpacePortfolio-main/
└── system-design-primer-master/
```

---

## ✅ Ready to Start?

### Option 1: GUI (Easiest)
```batch
run-github-automation.bat
```

### Option 2: PowerShell (Recommended First Time)
```powershell
cd c:\Study
.\validate-system.ps1     # Check system
.\github-repos-automation.ps1 -DryRun  # Preview
.\github-repos-automation.ps1          # Execute
```

---

## 📞 Questions?

Everything you need is in the documentation:
1. **Quick Reference**: [QUICK-REFERENCE.md](QUICK-REFERENCE.md)
2. **Full Guide**: [GITHUB-AUTOMATION-GUIDE.md](GITHUB-AUTOMATION-GUIDE.md)
3. **System Check**: `.\validate-system.ps1`

---

**Version**: 1.0  
**Last Updated**: 2026-03-23  
**Status**: ✓ Ready to Use  
**Platform**: Windows 10/11 PowerShell

---

**🎉 You're all set! Start with `validate-system.ps1` to make sure everything is configured correctly.**
