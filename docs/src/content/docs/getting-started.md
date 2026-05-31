---
title: Getting Started
description: Install AgentOnToast and get native macOS notifications for GitHub Copilot CLI and Claude Code in minutes.
---

AgentOnToast hooks into [GitHub Copilot CLI](https://docs.github.com/en/copilot/how-tos/use-copilot-agents/use-copilot-cli) and [Claude Code](https://docs.claude.com/en/docs/claude-code) to pop native macOS notifications for every key agent event — from one shared, dependency-free engine.

## Requirements

| Requirement | Notes |
|---|---|
| **macOS** | Notifications use the built-in Notification Center (`osascript`) |
| **[Copilot CLI](https://docs.github.com/en/copilot/how-tos/set-up/install-copilot-cli)** and/or **[Claude Code](https://docs.claude.com/en/docs/claude-code)** | Install for whichever tool(s) you use |

There is **nothing else to install** — the engine relies only on `osascript` and `plutil`, both bundled with macOS.

## Quick install

```bash
curl -fsSL https://raw.githubusercontent.com/elliott99ukhb/AgentOnToast/macos/install.sh | bash
```

By default this sets up **both** tools:

- **Claude Code — globally** (`~/.claude/settings.json`): notifications in every project, installed once. Existing settings are preserved (a `.bak` is written first).
- **Copilot CLI — for the current repo** (`.github/hooks/`): that's how Copilot CLI discovers hooks. Skipped if you aren't inside a git repo.

## Install options

```bash
curl -fsSL https://raw.githubusercontent.com/elliott99ukhb/AgentOnToast/macos/install.sh -o install.sh
bash install.sh [--copilot-only|--claude-only] [--project] [--force] [--path <repo-root>]
rm install.sh
```

| Option | Description |
|---|---|
| `--copilot-only` | Only install Copilot CLI hooks (per-repo) |
| `--claude-only` | Only install Claude Code hooks |
| `--project` | Install Claude hooks into the repo (`.claude/`) instead of globally |
| `--force` | Overwrite an existing `on-toast.config.json` |
| `--path <dir>` | Target a specific repo root instead of the current git repo |

## Verify it's working

Start a session — you should see a **"Copilot - Started"** or **"Claude - Started"** notification. You can also fire one by hand:

```bash
# Copilot mode
echo '{}' | COPILOT_HOOK_EVENT=agentStop bash .github/hooks/on-toast.sh
# Claude mode
echo '{"hook_event_name":"Stop"}' | bash ~/.claude/agent-on-toast/on-toast.sh
```

If you see nothing, open **System Settings → Notifications** and allow notifications for your terminal app (Terminal, iTerm, VS Code, …) — that's the process that delivers them. macOS prompts for this the first time a notification fires.

## Uninstall

**Copilot (per repo):**

```bash
rm .github/hooks/on-toast.sh .github/hooks/copilot-on-toast.json \
   .github/hooks/on-toast.config.json .github/skills/toast/SKILL.md
```

**Claude (global):** remove the `hooks` entries referencing `agent-on-toast/on-toast.sh` from `~/.claude/settings.json` (or restore `~/.claude/settings.json.bak`), then `rm -rf ~/.claude/agent-on-toast`.
