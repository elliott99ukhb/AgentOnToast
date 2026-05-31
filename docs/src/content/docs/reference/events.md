---
title: Events Reference
description: How Copilot CLI and Claude Code hook events map to AgentOnToast notification categories.
---

AgentOnToast normalises each tool's hook events into shared **categories**. The engine prefixes every banner with the tool that fired it (`Copilot - …` or `Claude - …`), and `on-toast.config.json` toggles by category.

## Category mapping

| Category | Banner title | Body | Copilot CLI event | Claude Code event |
|---|---|---|---|---|
| `sessionStart` | *Started* | Session started. | `sessionStart` | `SessionStart` |
| `sessionEnd` | *Done* | Session ended: *{reason}* | `sessionEnd` | `SessionEnd` |
| `turnComplete` | *Turn Complete* | Agent finished responding. | `agentStop` | `Stop` |
| `subagentDone` | *Subagent Done* | A subagent finished. | — | `SubagentStop` |
| `needsApproval` | *Action Needed* | Awaiting approval for: *{tool}* | `permissionRequest` | `Notification` (`permission_prompt`) |
| `waitingForInput` | *Waiting* | *{message}* | — | `Notification` (`idle_prompt`) |
| `promptSent` | *Prompt Sent* | *{prompt preview}* | `userPromptSubmitted` | `UserPromptSubmit` |
| `toolFailed` | *Tool Failed* | Tool failed: *{tool}* | `postToolUseFailure` | `PostToolUseFailure` |
| `error` | *Error* | *{error message}* | `errorOccurred` | — |

## Notes

### `turnComplete`
The main "done" alert — fires when the agent finishes a turn and is waiting for you. If you keep only one category on, make it this.

### `needsApproval` / `waitingForInput`
The "come back to the terminal" alerts. For Claude Code these both come from the `Notification` event, distinguished by `notification_type` (`permission_prompt` vs `idle_prompt`). For Copilot, `needsApproval` fires even in `/yolo` mode.

### `promptSent`
Shows a preview of your submitted prompt. The noisiest category — most people disable it.

### Tool detection
If `COPILOT_HOOK_EVENT` is set, the engine treats the call as Copilot CLI; otherwise it reads `hook_event_name` from the stdin JSON (Claude Code). Events with no mapping (e.g. Claude's `PreCompact`, or `Notification` types other than permission/idle) are ignored.
