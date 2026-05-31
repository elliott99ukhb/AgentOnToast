---
title: Configuration
description: Customise which notification categories fire, for Copilot CLI and Claude Code.
---

AgentOnToast is controlled by a single `on-toast.config.json` keyed by tool-agnostic **categories**. The same category set applies to both tools.

## Config file location

- **Copilot CLI** (per-repo): `.github/hooks/on-toast.config.json`
- **Claude Code** (global): `~/.claude/agent-on-toast/on-toast.config.json`

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

Set any category to `false` to silence it. Any category not listed defaults to **enabled**.

## Using the `/toast` skill

In a Copilot CLI session, the bundled `/toast` skill manages the config conversationally:

```
/toast disable permission notifications
```
```
/toast silence everything except errors
```
```
/toast show me which notifications are enabled
```

Copilot will read and update `on-toast.config.json` for you.

## Reducing noise

- `promptSent` fires on every prompt you submit — the most common one to set to `false`.
- `needsApproval` and `waitingForInput` are the most useful "come back" alerts; keep these on.
- **Copilot `/yolo` mode:** `needsApproval` still fires in yolo. Ask Copilot to `/toast disable permission notifications` before a yolo session and re-enable after.

## Customising notification text

To change the wording, edit the `case` blocks in `on-toast.sh` — titles and bodies are set there.

## Removing a hook entirely

- **Copilot:** remove the event's entry from `.github/hooks/copilot-on-toast.json`.
- **Claude Code:** remove that event's AgentOnToast entry from your `settings.json` `hooks` block.
