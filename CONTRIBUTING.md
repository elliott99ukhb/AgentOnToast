# Contributing to CopilotOnToast (macOS)

Thank you for your interest in contributing! This document covers how to report issues, suggest improvements, and submit code changes.

> This is the macOS port. For the original Windows project, see [melodiouscoders/CopilotOnToast](https://github.com/melodiouscoders/CopilotOnToast).

---

## Reporting bugs

Before opening a new issue, please [search existing issues](https://github.com/elliott99ukhb/CopilotOnToast/issues) to avoid duplicates.

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
- [GitHub Copilot CLI](https://docs.github.com/en/copilot/how-tos/set-up/install-copilot-cli)

No extra dependencies are required — the hook script relies only on `osascript` and `plutil`, both bundled with macOS.

### Testing hooks locally

You can test the notification script directly by piping a JSON payload into it:

```bash
# Test agentStop notification
echo '{}' | COPILOT_HOOK_EVENT=agentStop bash .github/hooks/copilot-on-toast.sh
```

```bash
# Test permissionRequest with a tool name
echo '{"toolName":"bash"}' | COPILOT_HOOK_EVENT=permissionRequest bash .github/hooks/copilot-on-toast.sh
```

Or start a real Copilot CLI session in this repository — the hooks in `.github/hooks/` will fire automatically.

---

## Code style

- Bash: follow the existing style in `copilot-on-toast.sh` — small focused helpers, quote all expansions, and keep the script `shellcheck`-clean.
- JSON: 2-space indentation, consistent with the existing `copilot-on-toast.json`.
- Keep the hook script self-contained — no dependencies beyond what ships with macOS (`osascript`, `plutil`).
