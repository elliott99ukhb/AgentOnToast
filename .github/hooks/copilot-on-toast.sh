#!/usr/bin/env bash
# copilot-on-toast.sh
# Fires a native macOS notification when Copilot CLI hooks are triggered.
# Copilot CLI passes hook data as JSON via stdin.
# The hook event name is passed via the COPILOT_HOOK_EVENT env var.
#
# Dependencies: none beyond what ships with macOS.
#   - JSON is parsed with `plutil` (built in)
#   - Notifications are shown with `osascript` (built in)

# Read the JSON payload from stdin once.
payload="$(cat)"

# Resolve the directory this script lives in so we can find the config file
# regardless of the caller's working directory.
script_dir="$(cd "$(dirname "$0")" && pwd)"

# Extract a value from the JSON payload by key path (e.g. "error.message").
# Prints the raw value, or nothing if the key is absent / payload isn't JSON.
json_get() {
    printf '%s' "$payload" | plutil -extract "$1" raw -o - - 2>/dev/null
}

# Truncate a string to a max length, appending "..." when it overflows.
#   $1 = string, $2 = max length, $3 = chars to keep before the ellipsis
truncate_str() {
    local s="$1" max="$2" keep="$3"
    if [ "${#s}" -gt "$max" ]; then
        printf '%s...' "${s:0:$keep}"
    else
        printf '%s' "$s"
    fi
}

event="$COPILOT_HOOK_EVENT"

# Honour the config file: if this event is explicitly set to false, stay silent.
# Any event not listed defaults to enabled.
config_path="$script_dir/copilot-on-toast.config.json"
if [ -f "$config_path" ]; then
    enabled="$(plutil -extract "notifications.$event" raw -o - "$config_path" 2>/dev/null)"
    if [ "$enabled" = "false" ]; then
        exit 0
    fi
fi

# Build the notification title and message for the event.
case "$event" in
    sessionStart)
        title="Copilot - Started"
        message="Session started."
        ;;
    sessionEnd)
        reason="$(json_get reason)"
        [ -n "$reason" ] || reason="complete"
        title="Copilot - Done"
        message="Session ended: $reason"
        ;;
    agentStop)
        title="Copilot - Turn Complete"
        message="Agent finished responding."
        ;;
    permissionRequest)
        tool_name="$(json_get toolName)"
        [ -n "$tool_name" ] || tool_name="unknown"
        title="Copilot - Action Needed"
        message="Awaiting approval for: $tool_name"
        ;;
    errorOccurred)
        error_detail="$(json_get error.message)"
        [ -n "$error_detail" ] || error_detail="$(json_get error)"
        [ -n "$error_detail" ] || error_detail="An error occurred"
        title="Copilot - Error"
        message="$(truncate_str "$error_detail" 80 77)"
        ;;
    userPromptSubmitted)
        prompt="$(json_get prompt)"
        title="Copilot - Prompt Sent"
        message="$(truncate_str "$prompt" 60 57)"
        ;;
    postToolUseFailure)
        tool_name="$(json_get toolName)"
        [ -n "$tool_name" ] || tool_name="unknown"
        title="Copilot - Tool Failed"
        message="Tool failed: $tool_name"
        ;;
    *)
        # Unhandled event types are ignored and do not trigger a notification.
        exit 0
        ;;
esac

# Fire the notification. Title and message are passed as AppleScript arguments
# (not interpolated into the source) so quotes, backslashes, $(...) etc. in a
# prompt or error message can never break or inject into the script.
if command -v osascript >/dev/null 2>&1; then
    osascript -e 'on run argv
        display notification (item 2 of argv) with title (item 1 of argv)
    end run' "$title" "$message" >/dev/null 2>&1 || true
else
    # Fallback when osascript is unavailable (e.g. running outside macOS).
    printf '[%s] %s\n' "$title" "$message"
fi

# Never fail the hook because of a notification hiccup — Copilot CLI should
# carry on regardless of whether the banner rendered.
exit 0
