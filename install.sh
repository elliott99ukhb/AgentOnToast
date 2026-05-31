#!/usr/bin/env bash
# install.sh — installs AgentOnToast: native macOS notifications for
# GitHub Copilot CLI and/or Claude Code, from one shared engine.
#
# Quick install (sets up Claude Code globally + Copilot for the current repo):
#   curl -fsSL https://raw.githubusercontent.com/elliott99ukhb/AgentOnToast/macos/install.sh | bash
#
# With options (download first):
#   curl -fsSL https://raw.githubusercontent.com/elliott99ukhb/AgentOnToast/macos/install.sh -o install.sh
#   bash install.sh [--copilot-only|--claude-only] [--project] [--force] [--path <repo-root>]
#   rm install.sh

set -euo pipefail

REF='macos'
BASE_URL="https://raw.githubusercontent.com/elliott99ukhb/AgentOnToast/${REF}"
HOOKS_BASE="${BASE_URL}/.github/hooks"
SKILL_BASE="${BASE_URL}/.github/skills/toast"

DO_COPILOT=1
DO_CLAUDE=1
CLAUDE_SCOPE="global"   # or "project"
FORCE=0
TARGET_PATH=''

if [ -t 1 ]; then
    C_CYAN=$'\033[36m'; C_GREEN=$'\033[32m'; C_YELLOW=$'\033[33m'
    C_RED=$'\033[31m'; C_RESET=$'\033[0m'
else
    C_CYAN=''; C_GREEN=''; C_YELLOW=''; C_RED=''; C_RESET=''
fi

while [ $# -gt 0 ]; do
    case "$1" in
        --copilot-only) DO_CLAUDE=0; shift ;;
        --claude-only)  DO_COPILOT=0; shift ;;
        --project)      CLAUDE_SCOPE="project"; shift ;;
        -f|--force)     FORCE=1; shift ;;
        -p|--path)      TARGET_PATH="${2:-}"; shift 2 ;;
        --path=*)       TARGET_PATH="${1#*=}"; shift ;;
        -h|--help)
            cat <<'EOF'
AgentOnToast installer (macOS)

By default installs BOTH:
  - Claude Code notifications, globally (~/.claude/settings.json) — every project
  - Copilot CLI notifications, into the current repo (.github/hooks/)

Options:
  --copilot-only     Only install the Copilot CLI hooks (per-repo)
  --claude-only      Only install the Claude Code hooks
  --project          Install Claude hooks into the repo (.claude/) instead of globally
  -f, --force        Overwrite an existing config file
  -p, --path <dir>   Repo root to target (defaults to the current git repo)
  -h, --help         Show this help
EOF
            exit 0 ;;
        *) echo "${C_RED}Unknown option: $1${C_RESET}" >&2; exit 1 ;;
    esac
done

echo ""
echo "${C_CYAN}  AgentOnToast Installer (macOS)${C_RESET}"
echo "${C_CYAN}  ==============================${C_RESET}"
echo ""

[ "$(uname -s)" = "Darwin" ] || echo "${C_YELLOW}  WARNING: targets macOS; notifications use 'osascript'.${C_RESET}"

download() {
    if command -v curl >/dev/null 2>&1; then curl -fsSL "$1" -o "$2"
    elif command -v wget >/dev/null 2>&1; then wget -qO "$2" "$1"
    else echo "${C_RED}  ERROR: neither curl nor wget available.${C_RESET}" >&2; exit 1; fi
}

# fetch <url> <dest> <preserve>  — preserve=1 skips if the file already exists
fetch() {
    local url="$1" dest="$2" preserve="${3:-0}" label; label="$(basename "$dest")"
    if [ "$preserve" = 1 ] && [ -e "$dest" ] && [ "$FORCE" -ne 1 ]; then
        echo "${C_YELLOW}  SKIP (exists)     : ${label}  (use --force to overwrite)${C_RESET}"; return
    fi
    download "$url" "$dest"
    echo "${C_GREEN}  Installed         : ${dest}${C_RESET}"
}

# Resolve repo root (needed for Copilot and for --project Claude installs)
repo_root=""
if [ -n "$TARGET_PATH" ]; then
    [ -d "$TARGET_PATH" ] || { echo "${C_RED}  ERROR: path not found: $TARGET_PATH${C_RESET}" >&2; exit 1; }
    repo_root="$(cd "$TARGET_PATH" && pwd)"
else
    repo_root="$(git rev-parse --show-toplevel 2>/dev/null || true)"
fi

# ----------------------------------------------------------------- Copilot CLI
if [ "$DO_COPILOT" = 1 ]; then
    echo "${C_CYAN}  GitHub Copilot CLI (per-repo)${C_RESET}"
    if [ -z "$repo_root" ]; then
        echo "${C_YELLOW}  Not inside a git repo — skipping Copilot hooks."
        echo "  Run inside a repo, or use --path <repo-root>.${C_RESET}"
    else
        hooks_dir="$repo_root/.github/hooks"
        skill_dir="$repo_root/.github/skills/toast"
        mkdir -p "$hooks_dir" "$skill_dir"
        fetch "$HOOKS_BASE/on-toast.sh"           "$hooks_dir/on-toast.sh"
        fetch "$HOOKS_BASE/copilot-on-toast.json" "$hooks_dir/copilot-on-toast.json"
        fetch "$HOOKS_BASE/on-toast.config.json"  "$hooks_dir/on-toast.config.json" 1
        fetch "$SKILL_BASE/SKILL.md"              "$skill_dir/SKILL.md" 1
        chmod +x "$hooks_dir/on-toast.sh" 2>/dev/null || true
        echo "  Target: $hooks_dir"
    fi
    echo ""
fi

# ------------------------------------------------------------------ Claude Code
if [ "$DO_CLAUDE" = 1 ]; then
    echo "${C_CYAN}  Claude Code (${CLAUDE_SCOPE})${C_RESET}"
    if [ "$CLAUDE_SCOPE" = "global" ]; then
        eng_dir="$HOME/.claude/agent-on-toast"
        settings="$HOME/.claude/settings.json"
        # shellcheck disable=SC2016  # literal $HOME on purpose — the hook shell expands it at runtime
        cmd_path='$HOME/.claude/agent-on-toast/on-toast.sh'
    else
        [ -n "$repo_root" ] || { echo "${C_RED}  ERROR: --project needs a git repo (or --path).${C_RESET}" >&2; exit 1; }
        eng_dir="$repo_root/.claude/agent-on-toast"
        settings="$repo_root/.claude/settings.json"
        # shellcheck disable=SC2016  # literal $CLAUDE_PROJECT_DIR on purpose — expanded by the hook shell at runtime
        cmd_path='$CLAUDE_PROJECT_DIR/.claude/agent-on-toast/on-toast.sh'
    fi

    mkdir -p "$eng_dir" "$(dirname "$settings")"
    fetch "$HOOKS_BASE/on-toast.sh"          "$eng_dir/on-toast.sh"
    fetch "$HOOKS_BASE/on-toast.config.json" "$eng_dir/on-toast.config.json" 1
    chmod +x "$eng_dir/on-toast.sh" 2>/dev/null || true

    # Merge our hooks into settings.json without disturbing anything else.
    if [ -f "$settings" ]; then cp "$settings" "${settings}.bak"; echo "  Backed up         : ${settings}.bak"; fi
    SETTINGS_PATH="$settings" ENGINE_CMD="bash \"$cmd_path\"" python3 - <<'PY'
import json, os, sys
path = os.environ["SETTINGS_PATH"]
cmd  = os.environ["ENGINE_CMD"]
events = ["SessionStart","SessionEnd","Stop","SubagentStop",
          "UserPromptSubmit","Notification","PostToolUseFailure"]
data = {}
if os.path.exists(path) and os.path.getsize(path) > 0:
    try:
        with open(path) as f: data = json.load(f)
    except Exception as e:
        sys.stderr.write("ERROR: %s is not valid JSON (%s); leaving it untouched.\n" % (path, e))
        sys.exit(3)
hooks = data.setdefault("hooks", {})
for ev in events:
    groups = hooks.get(ev, [])
    # Drop any prior AgentOnToast entries so re-running is idempotent.
    groups = [g for g in groups
              if not any("on-toast.sh" in h.get("command","")
                         for h in g.get("hooks", []))]
    groups.append({"hooks": [{"type": "command", "command": cmd}]})
    hooks[ev] = groups
with open(path, "w") as f:
    json.dump(data, f, indent=2); f.write("\n")
print("  Merged hooks into : %s (%d events)" % (path, len(events)))
PY
    echo "  Engine: $eng_dir"
    echo ""
fi

# ----------------------------------------------------------------------- finish
if command -v osascript >/dev/null 2>&1; then
    echo "${C_GREEN}  Notifications     : native macOS (osascript) — no dependencies needed${C_RESET}"
else
    echo "${C_YELLOW}  osascript not found — notifications fall back to console output.${C_RESET}"
fi
echo ""
echo "${C_GREEN}  Done!${C_RESET} Restart your CLI(s) — hooks load at session start."
echo "  Toggle categories in on-toast.config.json (or ask /toast in a Copilot session)."
echo ""
