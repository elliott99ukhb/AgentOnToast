#!/usr/bin/env bash
# install.sh
# Installs CopilotOnToast (macOS) hooks into a repository's .github/hooks directory.
#
# Usage (simple):
#   curl -fsSL https://raw.githubusercontent.com/elliott99ukhb/CopilotOnToast/macos/install.sh | bash
#
# Usage (with options — download first, then run):
#   curl -fsSL https://raw.githubusercontent.com/elliott99ukhb/CopilotOnToast/macos/install.sh -o install.sh
#   bash install.sh [--force] [--path <repo-root>]
#   rm install.sh

set -euo pipefail

REF='macos'
BASE_URL="https://raw.githubusercontent.com/elliott99ukhb/CopilotOnToast/${REF}"
HOOK_FILES=(copilot-on-toast.json copilot-on-toast.sh copilot-on-toast.config.json)
SKILL_FILES=(SKILL.md)

FORCE=0
TARGET_PATH=''

# ---- colours (only when stdout is a terminal) -------------------------------
if [ -t 1 ]; then
    C_CYAN=$'\033[36m'; C_GREEN=$'\033[32m'; C_YELLOW=$'\033[33m'
    C_RED=$'\033[31m'; C_RESET=$'\033[0m'
else
    C_CYAN=''; C_GREEN=''; C_YELLOW=''; C_RED=''; C_RESET=''
fi

# ---- argument parsing -------------------------------------------------------
while [ $# -gt 0 ]; do
    case "$1" in
        -f|--force) FORCE=1; shift ;;
        -p|--path)  TARGET_PATH="${2:-}"; shift 2 ;;
        --path=*)   TARGET_PATH="${1#*=}"; shift ;;
        -h|--help)
            cat <<'EOF'
CopilotOnToast (macOS) installer

Options:
  -f, --force          Overwrite existing hook files
  -p, --path <dir>     Target a specific repository root instead of the current git repo
  -h, --help           Show this help
EOF
            exit 0 ;;
        *) echo "${C_RED}Unknown option: $1${C_RESET}" >&2; exit 1 ;;
    esac
done

echo ""
echo "${C_CYAN}  CopilotOnToast Installer (macOS)${C_RESET}"
echo "${C_CYAN}  ================================${C_RESET}"
echo ""

# ---- sanity checks ----------------------------------------------------------
if [ "$(uname -s)" != "Darwin" ]; then
    echo "${C_YELLOW}  WARNING: This installer targets macOS. Notifications use 'osascript'.${C_RESET}"
fi

# ---- resolve target repository root -----------------------------------------
if [ -n "$TARGET_PATH" ]; then
    if [ ! -d "$TARGET_PATH" ]; then
        echo "${C_RED}  ERROR: Path not found: $TARGET_PATH${C_RESET}" >&2
        exit 1
    fi
    repo_root="$(cd "$TARGET_PATH" && pwd)"
else
    if ! repo_root="$(git rev-parse --show-toplevel 2>/dev/null)"; then
        echo "${C_RED}  ERROR: Not inside a git repository.${C_RESET}" >&2
        echo "${C_RED}  Run this from your repo root, or use --path <repo-root>.${C_RESET}" >&2
        exit 1
    fi
fi

hooks_dir="$repo_root/.github/hooks"
skill_dir="$repo_root/.github/skills/toast"
echo "  Target directory : $hooks_dir"

mkdir -p "$hooks_dir"
mkdir -p "$skill_dir"

# ---- download helper --------------------------------------------------------
download() {
    # $1 = url, $2 = destination
    if command -v curl >/dev/null 2>&1; then
        curl -fsSL "$1" -o "$2"
    elif command -v wget >/dev/null 2>&1; then
        wget -qO "$2" "$1"
    else
        echo "${C_RED}  ERROR: Neither curl nor wget is available.${C_RESET}" >&2
        exit 1
    fi
}

install_files() {
    # $1 = url subpath, $2 = destination dir, $3 = label prefix, then file list
    local subpath="$1" dest_dir="$2" label="$3"; shift 3
    local file dest
    for file in "$@"; do
        dest="$dest_dir/$file"
        if [ -e "$dest" ] && [ "$FORCE" -ne 1 ]; then
            echo "${C_YELLOW}  SKIP (exists)     : ${label}${file}  (use --force to overwrite)${C_RESET}"
            continue
        fi
        echo "  Downloading       : ${label}${file}"
        download "${BASE_URL}/${subpath}/${file}" "$dest"
        echo "${C_GREEN}  Installed         : ${dest}${C_RESET}"
    done
}

install_files ".github/hooks"        "$hooks_dir" ""             "${HOOK_FILES[@]}"
install_files ".github/skills/toast" "$skill_dir" "skills/toast/" "${SKILL_FILES[@]}"

# The hook script must be executable.
chmod +x "$hooks_dir/copilot-on-toast.sh" 2>/dev/null || true

echo ""
if command -v osascript >/dev/null 2>&1; then
    echo "${C_GREEN}  Notifications     : native macOS (osascript) — no dependencies needed${C_RESET}"
else
    echo "${C_YELLOW}  osascript not found — notifications fall back to console output.${C_RESET}"
fi

echo ""
echo "${C_GREEN}  Done! CopilotOnToast hooks and skill are installed.${C_RESET}"
echo "  See .github/hooks/copilot-on-toast.config.json to configure notifications."
echo "  Use /toast in a Copilot CLI session to manage notifications conversationally."
echo "  Restart Copilot CLI — hooks are loaded at session start."
echo ""
