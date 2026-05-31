# AgentOnToast 🍞

> Native macOS notifications for your AI coding agents — get notified when the agent finishes, needs approval, is waiting for you, hits an error, and more. **Works with [GitHub Copilot CLI](https://docs.github.com/en/copilot/how-tos/use-copilot-agents/use-copilot-cli) and [Claude Code](https://docs.claude.com/en/docs/claude-code) from one install.**

Walk away from your terminal while your agent works. AgentOnToast pops a native macOS notification for every key event so you never miss a beat — and the banner tells you *which* agent (`Copilot - …` or `Claude - …`).

> **A note on lineage:** AgentOnToast began as a macOS port of [melodiouscoders/CopilotOnToast](https://github.com/melodiouscoders/CopilotOnToast) (Windows/PowerShell). It now uses one dependency-free shell engine — macOS's built-in `osascript` + `plutil` — and adds Claude Code support alongside Copilot CLI. See [Credits](#credits).

---

## How it works

A single engine, [`on-toast.sh`](.github/hooks/on-toast.sh), is registered as a hook for both tools and figures out who called it:

- **Copilot CLI** runs it via `.github/hooks/copilot-on-toast.json` and sets `COPILOT_HOOK_EVENT`.
- **Claude Code** runs it via your `settings.json` hooks; the event arrives as `hook_event_name` on stdin.

Each tool's event is normalised to a shared **category**, gated by `on-toast.config.json`, and shown as a `<Tool> - <Title>` banner. Zero dependencies beyond what ships with macOS.

## Notifications

| Category | Banner | Copilot event | Claude Code event |
|---|---|---|---|
| `sessionStart` | *Started* | `sessionStart` | `SessionStart` |
| `sessionEnd` | *Done — {reason}* | `sessionEnd` | `SessionEnd` |
| `turnComplete` | *Turn Complete* | `agentStop` | `Stop` |
| `subagentDone` | *Subagent Done* | — | `SubagentStop` |
| `needsApproval` | *Action Needed* | `permissionRequest` | `Notification` (`permission_prompt`) |
| `waitingForInput` | *Waiting* | — | `Notification` (`idle_prompt`) |
| `promptSent` | *Prompt Sent — {preview}* | `userPromptSubmitted` | `UserPromptSubmit` |
| `toolFailed` | *Tool Failed — {tool}* | `postToolUseFailure` | `PostToolUseFailure` |
| `error` | *Error — {message}* | `errorOccurred` | — |

---

## Requirements

| Requirement | Notes |
|---|---|
| macOS | Notifications use the built-in Notification Center (`osascript`) |
| [GitHub Copilot CLI](https://docs.github.com/en/copilot/how-tos/set-up/install-copilot-cli) and/or [Claude Code](https://docs.claude.com/en/docs/claude-code) | Install for whichever tool(s) you use |

Nothing else — the engine relies only on `osascript` and `plutil`, both bundled with macOS.

---

## Installation

### Quick install (one-liner)

```bash
curl -fsSL https://raw.githubusercontent.com/elliott99ukhb/AgentOnToast/macos/install.sh | bash
```

By default this sets up **both**:

- **Claude Code — globally** (`~/.claude/settings.json`): notifications in *every* project, installed once. Your existing settings are preserved (a `.bak` is written first).
- **Copilot CLI — for the current repo** (`.github/hooks/`): because that's how Copilot CLI discovers hooks. Skipped if you're not inside a git repo.

### Install options

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

### What gets installed where

```
Copilot CLI (per repo)         Claude Code (global, default)
.github/hooks/                 ~/.claude/agent-on-toast/
  on-toast.sh                    on-toast.sh
  on-toast.config.json           on-toast.config.json
  copilot-on-toast.json        ~/.claude/settings.json   (hooks block merged in)
.github/skills/toast/SKILL.md
```

### Manual install

**Copilot CLI:** copy `on-toast.sh`, `copilot-on-toast.json`, and `on-toast.config.json` into your repo's `.github/hooks/`, then `chmod +x .github/hooks/on-toast.sh`.

**Claude Code:** copy `on-toast.sh` + `on-toast.config.json` to `~/.claude/agent-on-toast/` (`chmod +x` the script), then add the [`claude-hooks.json`](.github/hooks/claude-hooks.json) `hooks` block to `~/.claude/settings.json`.

Restart the CLI(s) — hooks load at session start.

### Verify it's working

```bash
# Copilot mode
echo '{}' | COPILOT_HOOK_EVENT=agentStop bash .github/hooks/on-toast.sh
# Claude mode
echo '{"hook_event_name":"Stop"}' | bash ~/.claude/agent-on-toast/on-toast.sh
```

> **First-run note:** macOS asks for notification permission the first time a banner fires. If you see nothing, check **System Settings → Notifications** and allow notifications for your terminal app (Terminal, iTerm, VS Code, …) — that's the process that delivers them.

---

## Customisation

### Turning categories on/off

Edit `on-toast.config.json` (in `.github/hooks/` for Copilot, `~/.claude/agent-on-toast/` for Claude):

```json
{
  "notifications": {
    "sessionStart":    true,
    "sessionEnd":      true,
    "turnComplete":    true,
    "subagentDone":    true,
    "needsApproval":   true,
    "waitingForInput": true,
    "promptSent":      true,
    "toolFailed":      true,
    "error":           true
  }
}
```

Set any category to `false` to silence it across both tools. Any category not listed defaults to **enabled**.

> **Tip:** `promptSent` is the noisiest — many people set it to `false`. `waitingForInput` and `needsApproval` are the most useful "come back" alerts.

### Managing notifications via Copilot

In a Copilot CLI session, the bundled `/toast` skill edits the config conversationally:

```
/toast silence everything except errors
```

### Changing notification text

Edit the `case` blocks in `on-toast.sh` — titles and bodies are set there.

---

## Why no custom icon?

macOS native notifications (`osascript`) are delivered under the calling process — your terminal — and can't carry a custom app icon. AgentOnToast keeps **zero dependencies** rather than requiring something like `terminal-notifier` purely for branding. Titles, bodies, and Notification Center behaviour all work normally.

---

## Uninstall

**Copilot (per repo):**
```bash
rm .github/hooks/on-toast.sh .github/hooks/copilot-on-toast.json \
   .github/hooks/on-toast.config.json .github/skills/toast/SKILL.md
```

**Claude (global):** remove the `hooks` entries that reference `agent-on-toast/on-toast.sh` from `~/.claude/settings.json` (restore `~/.claude/settings.json.bak` if you kept it), then `rm -rf ~/.claude/agent-on-toast`.

---

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md). Security issues: [SECURITY.md](SECURITY.md).

## Credits

The original **CopilotOnToast** (Windows) was created by [melodiouscode](https://melodiouscode.net) — see [melodiouscoders/CopilotOnToast](https://github.com/melodiouscoders/CopilotOnToast). AgentOnToast is an independent fork that ports it to macOS and extends it to Claude Code, under the MIT licence. If you find it useful, consider supporting the original author:

- ☕ [Buy me a coffee](https://buymeacoffee.com/melodiouscode)
- ❤️ [Sponsor on GitHub](https://github.com/sponsors/melodiouscoders)

## License

[MIT](LICENSE) — original work © MelodiousCoders; macOS port & Claude Code support © 2026 elliott99ukhb.

---

> **AgentOnToast is an independent, community-created project and is not affiliated with, endorsed by, or an official product of GitHub, Microsoft, or Anthropic.** GitHub Copilot and Claude are trademarks of their respective owners.
