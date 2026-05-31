# Contributing to AgentOnToast

Thank you for your interest in contributing! This document covers how to report issues, suggest improvements, and submit code changes.

> AgentOnToast (macOS notifications for Copilot CLI **and** Claude Code) began as a port of [melodiouscoders/CopilotOnToast](https://github.com/melodiouscoders/CopilotOnToast) (Windows).

---

## Reporting bugs

Before opening a new issue, please [search existing issues](https://github.com/elliott99ukhb/AgentOnToast/issues) to avoid duplicates.

When reporting a bug, include:

- Your macOS version (`sw_vers`)
- Your Bash version (`bash --version`)
- Your Copilot CLI version (`copilot --version`)
- Steps to reproduce the issue
- What you expected to happen vs what actually happened

For security vulnerabilities, see [SECURITY.md](SECURITY.md) — please do **not** use a public issue.

---

## Suggesting features

Open an issue with the `enhancement` label. Describe the feature, the problem it solves, and — if relevant — how you'd expect it to work.

---

## Submitting a pull request

1. **Fork** the repository and create a branch:

   ```bash
   git checkout -b my-feature
   ```

2. **Make your changes.** Keep commits focused and use clear commit messages.

3. **Test your changes** by running a Copilot CLI session and verifying that notifications fire correctly for the hooks you modified.

4. **Open a pull request.** Fill in the PR description with:
   - What changed and why
   - How you tested it
   - Any follow-up work or known limitations

---

## Development setup

### Prerequisites

- macOS (notifications use the built-in `osascript`)
- [GitHub Copilot CLI](https://docs.github.com/en/copilot/how-tos/set-up/install-copilot-cli) and/or [Claude Code](https://docs.claude.com/en/docs/claude-code)

No extra dependencies are required — the engine relies only on `osascript` and `plutil`, both bundled with macOS.

### Testing the engine locally

The shared engine handles both tools. Pipe a payload into it directly:

```bash
# Copilot mode — event via COPILOT_HOOK_EVENT, Copilot-shaped payload on stdin
echo '{"toolName":"bash"}' | COPILOT_HOOK_EVENT=permissionRequest bash .github/hooks/on-toast.sh

# Claude mode — event via hook_event_name on stdin
echo '{"hook_event_name":"Notification","notification_type":"idle_prompt","message":"waiting"}' \
  | bash .github/hooks/on-toast.sh
```

Or start a real Copilot CLI / Claude Code session with the hooks installed — they fire automatically.

---

## Code style

- Bash: follow the existing style in `on-toast.sh` — small focused helpers, quote all expansions, keep it `shellcheck`-clean.
- JSON: 2-space indentation, consistent with `copilot-on-toast.json`.
- Keep the engine self-contained — no dependencies beyond what ships with macOS (`osascript`, `plutil`).
