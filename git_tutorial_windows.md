# 🧠 Simple Git & GitHub Tutorial for Windows

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

### 📌 Option 1: Clone a Repo (if already created on GitHub)
```bash
git clone git@github.com:yourusername/your-repo.git
cd your-repo
```

### 📌 Option 2: Start a new Git project and connect

To start tracking your project with Git:

```bash
git init
```

---

## 📂 4. Check Status and Track Files

```bash
git status       # Show changed/untracked files
git add .        # Add all files to staging area
git add file.txt # Add a specific file
```

---

## 💾 5. Commit Changes

```bash
git commit -m "Your commit message here"
```

---

## 🔄 6. Change Default Branch to `main`

Git used to create a `master` branch by default. To switch it to `main`:

```bash
git branch -m master main
```

To check the branch:

```bash
git branch
```

---

## 🌐 7. Add Remote and Push to GitHub

1. **Create a new repo on GitHub** (but **don’t** initialize it with README/license).
2. **Link your local repo to GitHub**:

```bash
git remote add origin https://github.com/your-username/your-repo-name.git
```

If you mistakenly added the wrong remote:

```bash
git remote -v
git remote remove origin
```

3. **Push your code**:

```bash
git push -u origin main
```

---

## 🌳 8. Branching

```bash
git branch new-feature     # Create new branch
git checkout new-feature   # Switch to it
```

Or use:

```bash
git switch -c new-feature
```

---

## 🚀 9. Merge a Branch into Main

```bash
git checkout main
git merge new-feature
```

---

## 🔁 10. Undo & Revert

### Discard changes in a file:

```bash
git restore file.txt
```

### Discard all changes:

```bash
git restore .
```

### Unstage a file (remove from staging area):

```bash
git restore --staged file.txt
```

### Revert a commit:

```bash
git revert <commit-id>
```

### Reset to a previous commit (⚠️ destructive):

```bash
git reset --hard <commit-id>
```

---

## 🔍 11. View History

```bash
git log                  # Full history
git log --oneline --graph  # Summary graph
```

---

## 🙌 12. You're Ready!

Now you know how to:
- ✅ Use Git for version control
- ✅ Work with branches
- ✅ Push to GitHub
- ✅ Undo mistakes safely

Happy coding! 🚀
