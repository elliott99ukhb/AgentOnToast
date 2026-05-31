---
name: toast
description: Manages AgentOnToast desktop notification settings. Use this skill when the user asks to enable, disable, mute, silence, or configure desktop notifications for Copilot CLI or Claude Code, or mentions specific categories like "permission notifications", "waiting alerts", "tool failure toasts", etc.
---

AgentOnToast sends native macOS notifications for AI agent CLI hook events (GitHub Copilot CLI and Claude Code). Which notifications fire is controlled by a config file:

- Copilot CLI (per-repo): `.github/hooks/on-toast.config.json`
- Claude Code (global): `~/.claude/agent-on-toast/on-toast.config.json`

Edit whichever one applies to the tool the user is asking about (in a Copilot CLI session, that's the repo's `.github/hooks/on-toast.config.json`).

## Config format

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

Set any category to `false` to silence it. Any category omitted from the file defaults to **enabled**.

## Category reference

| Key | When it fires |
|---|---|
| `sessionStart` | A session begins |
| `sessionEnd` | A session ends (body includes the reason) |
| `turnComplete` | The agent finishes a turn — the main "done" alert |
| `subagentDone` | A subagent finishes (Claude Code) |
| `needsApproval` | The agent needs approval to use a tool |
| `waitingForInput` | The agent is idle, waiting for you (Claude Code) |
| `promptSent` | You submitted a prompt (noisiest — often disabled) |
| `toolFailed` | A tool call failed |
| `error` | An error occurred (Copilot CLI) |

## Instructions

- To **show current settings**: read the relevant `on-toast.config.json` and summarise which categories are on and off.
- To **change a setting**: edit the file and update the relevant boolean. Confirm what changed.
- To **silence all notifications**: set every value to `false`. To **restore defaults**: set all to `true`.
- If the config file does not exist, it can be created with all values set to `true`.
- Always confirm the change back to the user in plain language (e.g. "Permission notifications are now disabled.").
