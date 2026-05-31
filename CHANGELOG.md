# Changelog

All notable changes to AgentOnToast will be documented here.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).

---

## [2.0.0] - 2026-05-31

Renamed **CopilotOnToast (macOS)** → **AgentOnToast** and unified Copilot CLI and Claude Code support behind one engine.

### Added

- **Claude Code support.** Hooks for `SessionStart`, `SessionEnd`, `Stop`, `SubagentStop`, `UserPromptSubmit`, `Notification` (`permission_prompt` + `idle_prompt`), and `PostToolUseFailure`.
- `on-toast.sh` — one shared engine that detects the calling tool (Copilot sets `COPILOT_HOOK_EVENT`; Claude Code passes `hook_event_name` on stdin) and normalises events to shared categories. Banners are prefixed with the tool name (`Copilot - …` / `Claude - …`).
- `claude-hooks.json` — the Claude Code `hooks` block (for manual installs / reference).
- New `waitingForInput` and `subagentDone` categories (Claude Code).
- `install.sh` now installs **both** tools by default: Claude Code globally (merged into `~/.claude/settings.json`, preserving existing settings and writing a `.bak`) and Copilot CLI per-repo. New flags: `--copilot-only`, `--claude-only`, `--project`.

### Changed

- Engine renamed `copilot-on-toast.sh` → `on-toast.sh`; config renamed `copilot-on-toast.config.json` → `on-toast.config.json` with tool-agnostic category keys.
- `copilot-on-toast.json` now invokes `on-toast.sh`.
- README, docs, CI, and the `/toast` skill updated for both tools.

### Notes

- The Claude `settings.json` merge is idempotent and never removes your own hooks; it refuses to modify a `settings.json` that isn't valid JSON.

---

## [1.0.0-mac] - 2026-05-31

Initial macOS port of [melodiouscoders/CopilotOnToast](https://github.com/melodiouscoders/CopilotOnToast) `v1.0.1` — replaced the Windows PowerShell + BurntToast engine with a zero-dependency shell script using `osascript` + `plutil`, and a `curl | bash` installer. Covered the seven Copilot CLI hook events.
