# CopilotOnToast 🍞 — macOS

> Native desktop notifications for [GitHub Copilot CLI](https://docs.github.com/en/copilot/how-tos/use-copilot-agents/use-copilot-cli) — get notified when your agent finishes, needs approval, hits an error, and more.

Walk away from your terminal while Copilot works. CopilotOnToast pops a native **macOS** notification for every key agent event so you never miss a beat.

> **This is a macOS port** of the original Windows project, [melodiouscoders/CopilotOnToast](https://github.com/melodiouscoders/CopilotOnToast). It swaps PowerShell + BurntToast for a plain shell script that uses macOS's built-in `osascript` and `plutil` — **no dependencies to install**. See [Credits](#credits).

---

## Events

| Hook event            | Notification title       | Notification body                       |
| --------------------- | ------------------------ | --------------------------------------- |
| `sessionStart`        | Copilot - Started        | Session started.                        |
| `sessionEnd`          | Copilot - Done           | Session ended: *{reason}*               |
| `agentStop`           | Copilot - Turn Complete  | Agent finished responding.              |
| `permissionRequest`   | Copilot - Action Needed  | Awaiting approval for: *{tool}*         |
| `errorOccurred`       | Copilot - Error          | *{error message}*                       |
| `userPromptSubmitted` | Copilot - Prompt Sent    | *{prompt preview}*                      |
| `postToolUseFailure`  | Copilot - Tool Failed    | Tool failed: *{tool}*                   |

---

## Requirements

| Requirement | Notes |
|---|---|
| macOS | Notifications use the built-in macOS Notification Center (`osascript`) |
| [GitHub Copilot CLI](https://docs.github.com/en/copilot/how-tos/set-up/install-copilot-cli) | Hooks require Copilot CLI v1.0+ |

That's it. The notification script relies only on `osascript` and `plutil`, both of which ship with every macOS install — **there is nothing extra to install.**

---

## Installation

### Quick install (one-liner)

Run this from the root of any repository where you want notifications:

```bash
curl -fsSL https://raw.githubusercontent.com/elliott99ukhb/CopilotOnToast/macos/install.sh | bash
```

This copies the hook files into `.github/hooks/` of your current directory. It will **not** overwrite files that already exist (use `--force` to override — see below).

### Install options

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

### Manual install

1. Copy `.github/hooks/copilot-on-toast.json`, `.github/hooks/copilot-on-toast.sh`, and `.github/hooks/copilot-on-toast.config.json` from this repo into the `.github/hooks/` directory of your repository.
2. Make the hook script executable: `chmod +x .github/hooks/copilot-on-toast.sh`
3. Restart Copilot CLI — hooks are loaded at session start.

### Verify it's working

Start a Copilot CLI session — you should see a **"Copilot - Started"** notification. You can also test the script directly:

```bash
echo '{}' | COPILOT_HOOK_EVENT=agentStop bash .github/hooks/copilot-on-toast.sh
```

> **First-run note:** macOS asks for notification permission the first time a notification fires. If you see nothing, check **System Settings → Notifications** and make sure notifications are allowed for your terminal app (Terminal, iTerm, etc.) — that's the process that delivers them.

---

## Customisation

### Enabling and disabling notifications

Edit `.github/hooks/copilot-on-toast.config.json` to turn individual notifications on or off:

```json
{
  "notifications": {
    "sessionStart":        true,
    "sessionEnd":          true,
    "agentStop":           true,
    "permissionRequest":   true,
    "errorOccurred":       true,
    "userPromptSubmitted": true,
    "postToolUseFailure":  true
  }
}
```

Set any event to `false` to silence it. Any event not listed defaults to **enabled**.

> **Tip — yolo mode:** If you use `/yolo` and don't want permission notifications, set `"permissionRequest": false`.

### Changing notification text

To change the wording of a notification, edit `.github/hooks/copilot-on-toast.sh` — each event's title and body are set in the `case` block.

### Managing notifications via Copilot

This repo includes a Copilot CLI skill that lets you manage notification settings conversationally. In a Copilot CLI session, just ask naturally or use `/toast` directly:

```
/toast disable permission notifications
```
```
/toast silence everything except errors
```
```
/toast show me which notifications are enabled
```

Copilot will read and update `copilot-on-toast.config.json` for you.

> **Tip — `/yolo` mode:** Since yolo is a per-session toggle with no persistent state, the easiest workflow is to ask Copilot to disable permission notifications before starting a yolo session, and re-enable them afterward.

### Removing specific hook triggers

To stop a hook firing altogether (not just suppress the notification), remove its entry from `.github/hooks/copilot-on-toast.json`.

---

## Why no custom icon?

macOS's native notifications (`osascript`) are delivered under the identity of the calling process — your terminal app — and don't allow a custom app icon. This port deliberately keeps **zero dependencies** rather than requiring a tool like `terminal-notifier` just for branding. The title, body, and Notification Center behaviour all work exactly as you'd expect.

---

## Uninstall

Remove the installed files:

```bash
rm .github/hooks/copilot-on-toast.json \
   .github/hooks/copilot-on-toast.sh \
   .github/hooks/copilot-on-toast.config.json
rm .github/skills/toast/SKILL.md
```

---

## Contributing

Contributions are welcome! See [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

## Security

Please see [SECURITY.md](SECURITY.md) for how to report vulnerabilities responsibly.

## Credits

CopilotOnToast was created by [melodiouscode](https://melodiouscode.net) — see the original Windows project at **[melodiouscoders/CopilotOnToast](https://github.com/melodiouscoders/CopilotOnToast)**. This macOS port is an independent fork and adapts that work under the terms of the MIT licence.

If you find CopilotOnToast useful, consider supporting the original author:

- ☕ [Buy me a coffee](https://buymeacoffee.com/melodiouscode)
- ❤️ [Sponsor on GitHub](https://github.com/sponsors/melodiouscoders)

## License

[MIT](LICENSE) — original work © MelodiousCoders; macOS port © 2026 elliott99ukhb.

---

> **CopilotOnToast is an independent, community-created project and is not affiliated with, endorsed by, or an official product of GitHub or Microsoft.** The GitHub Copilot name and logo are trademarks of their respective owners.
