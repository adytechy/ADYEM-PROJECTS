# Simple Git & GitHub Tutorial for Windows by Ady Techy

## ⚙️ 1. Install Git on Windows
- Download Git from: [https://git-scm.com/downloads](https://git-scm.com/downloads)
- Install with default settings (click "Next" until "Finish").
- Open **Git Bash** from Start Menu.

---

## 🔐 2. Set Up Git & SSH Key

### 📌 Step 1: Set your name and email (only once)
```bash
git config --global user.name "Your Name"
git config --global user.email "you@example.com"
```

### 📌 Step 2: Create SSH Key
```bash
ssh-keygen -t ed25519 -C "you@example.com"
```
- Just press `Enter` through all prompts.
- Your key is saved at: `~/.ssh/id_ed25519.pub`

### 📌 Step 3: Copy and add the SSH key to GitHub
```bash
cat ~/.ssh/id_ed25519.pub
```
- Copy the output.
- Go to GitHub → Settings → SSH and GPG Keys → New SSH Key → Paste and save.

---

## 🐙 3. Connect GitHub Repo

### 📌 Clone a Repo
```bash
git clone git@github.com:yourusername/your-repo.git
cd your-repo
```

---

## 🌿 4. Create and Switch Branches

### 📌 Check current branch
```bash
git branch
```

### 📌 Create a new branch and switch to it
```bash
git checkout -b feature-branch
```

---

## ✍️ 5. Make Changes and Commit

### 📌 Make a file or edit something
Example:
```bash
echo "Hello World" > hello.txt
```

### 📌 Stage and commit
```bash
git add .
git commit -m "Add hello.txt file"
```

---

## 🚀 6. Push Changes to GitHub

### 📌 Push to current branch
```bash
git push origin feature-branch
```

---

## 📀 7. Switch Between Branches

```bash
git checkout main        # switch to main
git checkout feature-xyz # switch to another
```

---

## ♻️ 8. Undo or Revert Changes

### 🔄 Discard local file changes (before staging)
```bash
git checkout -- filename.txt
```

### 🔄 Unstage a file (after `git add` but before commit)
```bash
git reset HEAD filename.txt
```

### 🔄 Undo the last commit (but keep the changes)
```bash
git reset --soft HEAD~1
```

### 🔄 Undo the last commit and remove changes
```bash
git reset --hard HEAD~1
```

> ⚠️ Be careful with `--hard`, it deletes changes.

### 🔄 See commit history
```bash
git log --oneline
```

### 🔄 Go back to a specific version
```bash
git checkout <commit-id>
```

To return to the latest version (main branch):
```bash
git checkout main
```

---

## ✅ Final Tip: See Git Status Anytime
```bash
git status
```

---

### OPTIONAL: Set VS Code as Git Editor (nice touch)
```bash
git config --global core.editor "code --wait"