# Changelog

All notable changes to CopilotOnToast (macOS) will be documented here.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).

---

## [1.0.0-mac] - 2026-05-31

macOS port of [melodiouscoders/CopilotOnToast](https://github.com/melodiouscoders/CopilotOnToast) `v1.0.1`.

### Added

- `copilot-on-toast.sh` — POSIX-friendly Bash hook script that fires native macOS notifications via `osascript`, parsing the hook payload with the built-in `plutil`. **No dependencies** beyond what ships with macOS.
- `install.sh` — `curl | bash` installer with `--force` and `--path` options, replacing `install.ps1`.

### Changed

- `copilot-on-toast.json` — each hook now invokes `copilot-on-toast.sh` (the `bash` command) instead of the Linux `notify-send` stub. The Windows `powershell` entries and the no-op `preToolUse` hook were removed.
- `/toast` skill (`SKILL.md`) reworded for macOS; configuration logic is unchanged.
- Documentation (README, docs site, contributing, issue/PR templates, CI) rewritten for macOS.

### Removed

- `copilot-on-toast.ps1` — the Windows PowerShell hook script (replaced by `copilot-on-toast.sh`).
- `install.ps1` — the Windows installer (replaced by `install.sh`).
- `copilot-icon.png` from the hooks — macOS native notifications cannot display a custom icon.

### Unchanged

- The seven notification events, their titles and bodies, and message truncation behaviour are identical to upstream.
- `copilot-on-toast.config.json` — same per-event enable/disable toggles.
