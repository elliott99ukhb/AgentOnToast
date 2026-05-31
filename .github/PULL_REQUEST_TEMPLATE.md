## What does this PR do?

<!-- A clear and concise description of the change and why it's needed. -->

## Related issue

<!-- Link to the issue this PR addresses, e.g. Closes #123 -->

## How has this been tested?

<!-- Describe how you verified the change works, and with which tool (Copilot CLI / Claude Code). e.g. "Started a Claude Code session and confirmed the Stop notification fires." -->

## Checklist

- [ ] I've tested the hook(s) I changed (Copilot CLI and/or Claude Code, or by piping a payload into `on-toast.sh`)
- [ ] The hooks JSON is valid (run `plutil -convert xml1 -o /dev/null .github/hooks/copilot-on-toast.json` — no errors)
- [ ] `shellcheck .github/hooks/on-toast.sh install.sh` is clean
- [ ] I've updated the README if the change affects user-facing behaviour
