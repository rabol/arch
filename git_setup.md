# SSH Key Setup for GitHub

## Step 1 — Generate a new SSH key

```bash
ssh-keygen -t ed25519 -C "your_email@example.com"
```

- Replace with your Git email
- Press Enter to accept default path
- Set a passphrase (recommended)

---

## Step 2 — Add the key to the SSH agent

```bash
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_ed25519
```

---

## Step 3 — Copy your public key

```bash
cat ~/.ssh/id_ed25519.pub
```

Copy the full output (starts with `ssh-ed25519`)

---

## Step 4 — Add it to your Git account

### GitHub
- Go to: https://github.com/settings/keys
- Click **New SSH key**
- Paste your key and save

---

## Step 5 — Test the connection

### GitHub
```bash
ssh -T git@github.com
```

You should see a success message.

## Step 6 - Local setup

```
git config --global user.name "Your Name"
git config --global user.email "your@email.com"
```
