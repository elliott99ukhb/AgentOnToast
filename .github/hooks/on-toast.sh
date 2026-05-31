#!/usr/bin/env bash
# on-toast.sh — shared notification engine for AgentOnToast.
# Fires a native macOS notification for agent CLI hook events.
#
# Works with BOTH tools from one script:
#   - GitHub Copilot CLI sets COPILOT_HOOK_EVENT and pipes Copilot's JSON on stdin.
#   - Claude Code pipes JSON on stdin that contains a "hook_event_name" field.
#
# Each tool's event is normalised to a shared category, gated by the config
# file, then shown as a "<Tool> - <Suffix>" banner. No dependencies beyond
# what ships with macOS (osascript + plutil).

payload="$(cat)"
script_dir="$(cd "$(dirname "$0")" && pwd)"

# Extract a value from the stdin JSON by key path (e.g. "error.message").
json_get() {
    printf '%s' "$payload" | plutil -extract "$1" raw -o - - 2>/dev/null
}

# Truncate to a max length, appending "..." when it overflows.
#   $1 = string, $2 = max length, $3 = chars to keep before the ellipsis
truncate_str() {
    local s="$1" max="$2" keep="$3"
    if [ "${#s}" -gt "$max" ]; then printf '%s...' "${s:0:$keep}"; else printf '%s' "$s"; fi
}

tool=""
category=""

# --- Detect the calling tool and normalise its event to a shared category ----
if [ -n "${COPILOT_HOOK_EVENT:-}" ]; then
    tool="Copilot"
    case "$COPILOT_HOOK_EVENT" in
        sessionStart)        category="sessionStart" ;;
        sessionEnd)          category="sessionEnd" ;;
        agentStop)           category="turnComplete" ;;
        permissionRequest)   category="needsApproval" ;;
        userPromptSubmitted) category="promptSent" ;;
        errorOccurred)       category="error" ;;
        postToolUseFailure)  category="toolFailed" ;;
        *) exit 0 ;;
    esac
else
    tool="Claude"
    case "$(json_get hook_event_name)" in
        SessionStart)        category="sessionStart" ;;
        SessionEnd)          category="sessionEnd" ;;
        Stop)                category="turnComplete" ;;
        SubagentStop)        category="subagentDone" ;;
        UserPromptSubmit)    category="promptSent" ;;
        PostToolUseFailure)  category="toolFailed" ;;
        PermissionRequest)   category="needsApproval" ;;
        Notification)
            case "$(json_get notification_type)" in
                permission_prompt) category="needsApproval" ;;
                idle_prompt)       category="waitingForInput" ;;
                *) exit 0 ;;  # ignore auth / system notifications
            esac
            ;;
        *) exit 0 ;;
    esac
fi

# --- Config gate: silence a category by setting it to false ------------------
config_path="$script_dir/on-toast.config.json"
if [ -f "$config_path" ]; then
    enabled="$(plutil -extract "notifications.$category" raw -o - "$config_path" 2>/dev/null)"
    [ "$enabled" = "false" ] && exit 0
fi

# --- Build the message for the category (pulling tool-specific fields) --------
case "$category" in
    sessionStart)
        title_suffix="Started"; message="Session started." ;;
    sessionEnd)
        reason="$(json_get reason)"; [ -n "$reason" ] || reason="complete"
        title_suffix="Done"; message="Session ended: $reason" ;;
    turnComplete)
        title_suffix="Turn Complete"; message="Agent finished responding." ;;
    subagentDone)
        title_suffix="Subagent Done"; message="A subagent finished." ;;
    needsApproval)
        tool_name="$(json_get toolName)"; [ -n "$tool_name" ] || tool_name="$(json_get tool_name)"
        if [ -n "$tool_name" ]; then
            title_suffix="Action Needed"; message="Awaiting approval for: $tool_name"
        else
            msg="$(json_get message)"; [ -n "$msg" ] || msg="Approval required"
            title_suffix="Action Needed"; message="$(truncate_str "$msg" 80 77)"
        fi ;;
    waitingForInput)
        msg="$(json_get message)"; [ -n "$msg" ] || msg="Waiting for your input."
        title_suffix="Waiting"; message="$(truncate_str "$msg" 80 77)" ;;
    promptSent)
        prompt="$(json_get prompt)"
        title_suffix="Prompt Sent"; message="$(truncate_str "$prompt" 60 57)" ;;
    toolFailed)
        tool_name="$(json_get toolName)"; [ -n "$tool_name" ] || tool_name="$(json_get tool_name)"
        [ -n "$tool_name" ] || tool_name="unknown"
        title_suffix="Tool Failed"; message="Tool failed: $tool_name" ;;
    error)
        err="$(json_get error.message)"; [ -n "$err" ] || err="$(json_get error)"
        [ -n "$err" ] || err="$(json_get tool_error)"; [ -n "$err" ] || err="An error occurred"
        title_suffix="Error"; message="$(truncate_str "$err" 80 77)" ;;
    *) exit 0 ;;
esac

title="$tool - $title_suffix"

# --- Fire the notification ---------------------------------------------------
# Title and message are passed as AppleScript arguments (not interpolated into
# the source) so quotes/backslashes/$()/; in a prompt or error can't inject.
if command -v osascript >/dev/null 2>&1; then
    osascript -e 'on run argv
        display notification (item 2 of argv) with title (item 1 of argv)
    end run' "$title" "$message" >/dev/null 2>&1 || true
else
    printf '[%s] %s\n' "$title" "$message"
fi

# Never fail the hook because of a notification hiccup.
exit 0
