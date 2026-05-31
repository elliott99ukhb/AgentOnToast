---
title: Getting Started
description: Install CopilotOnToast and get native macOS notifications for GitHub Copilot CLI in minutes.
---

CopilotOnToast hooks into [GitHub Copilot CLI](https://docs.github.com/en/copilot/how-tos/use-copilot-agents/use-copilot-cli) to pop native macOS notifications for every key agent event. This page will get you up and running in minutes.

## Requirements

| Requirement | Notes |
|---|---|
| **macOS** | Notifications use the built-in macOS Notification Center (`osascript`) |
| **[GitHub Copilot CLI](https://docs.github.com/en/copilot/how-tos/set-up/install-copilot-cli)** | Hooks require Copilot CLI v1.0+ |

There is **nothing else to install** — the hook script relies only on `osascript` and `plutil`, both of which ship with every macOS install.

## Quick install

Run this from the root of any repository where you want notifications:

```bash
curl -fsSL https://raw.githubusercontent.com/elliott99ukhb/CopilotOnToast/macos/install.sh | bash
```

This copies the hook files into `.github/hooks/` of your current directory. It will **not** overwrite files that already exist (use `--force` to override).

## Install options

Download the script first if you want to pass options:

```bash
curl -fsSL https://raw.githubusercontent.com/elliott99ukhb/CopilotOnToast/macos/install.sh -o install.sh
bash install.sh [--force] [--path <repo-root>]
rm install.sh
```

| Option | Description |
|---|---|
| `--force` | Overwrite existing hook files |
| `--path <dir>` | Target a specific repository root instead of the current git repo |

## Manual install

1. Copy `.github/hooks/copilot-on-toast.json`, `.github/hooks/copilot-on-toast.sh`, and `.github/hooks/copilot-on-toast.config.json` from this repo into the `.github/hooks/` directory of your repository.
2. Make the hook script executable: `chmod +x .github/hooks/copilot-on-toast.sh`
3. Restart Copilot CLI — hooks are loaded at session start.

## Verify it's working

Start a Copilot CLI session. You should see a **"Copilot - Started"** notification appear. You can also fire one by hand:

```bash
echo '{}' | COPILOT_HOOK_EVENT=agentStop bash .github/hooks/copilot-on-toast.sh
```

If you see nothing, check:

- **System Settings → Notifications** allows notifications for your terminal app (Terminal, iTerm, etc.) — that's the process that delivers them. macOS prompts for this the first time a notification fires.
- The hook script is executable: `ls -l .github/hooks/copilot-on-toast.sh`
- Hook files are present in `.github/hooks/`

## Uninstall

Remove the installed files:

```bash
rm .github/hooks/copilot-on-toast.json \
   .github/hooks/copilot-on-toast.sh \
   .github/hooks/copilot-on-toast.config.json
```

Remove the skill file if installed:

```bash
rm .github/skills/toast/SKILL.md
```
