## What does this PR do?

<!-- A clear and concise description of the change and why it's needed. -->

## Related issue

<!-- Link to the issue this PR addresses, e.g. Closes #123 -->

## How has this been tested?

<!-- Describe how you verified the change works. e.g. "Started a Copilot CLI session and confirmed the agentStop notification fires correctly." -->

## Checklist

- [ ] I've tested the hook(s) I changed in a live Copilot CLI session
- [ ] The hooks JSON is valid (run `plutil -convert xml1 -o /dev/null .github/hooks/copilot-on-toast.json` — no errors)
- [ ] `shellcheck .github/hooks/copilot-on-toast.sh install.sh` is clean
- [ ] I've updated the README if the change affects user-facing behaviour
