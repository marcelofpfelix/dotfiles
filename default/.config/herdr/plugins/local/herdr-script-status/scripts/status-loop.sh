#!/bin/sh
set -eu

herdr="${HERDR_BIN_PATH:-herdr}"
config_dir="${HERDR_PLUGIN_CONFIG_DIR:?HERDR_PLUGIN_CONFIG_DIR is required}"
state_dir="${HERDR_PLUGIN_STATE_DIR:?HERDR_PLUGIN_STATE_DIR is required}"
interval="${HERDR_SCRIPT_STATUS_INTERVAL:-5}"
ttl_ms="${HERDR_SCRIPT_STATUS_TTL_MS:-15000}"
source_id="${HERDR_PLUGIN_ID:-local.script-status}"
scripts_dir="$config_dir/workspace.d"

case "$interval" in
    ''|*[!0-9]*) interval=5 ;;
esac

case "$ttl_ms" in
    ''|*[!0-9]*) ttl_ms=15000 ;;
esac

mkdir -p "$scripts_dir" "$state_dir"

token_name() {
    basename "$1" | sed 's/[^A-Za-z0-9_-]/_/g'
}

run_script() {
    script=$1
    if command -v timeout >/dev/null 2>&1; then
        timeout 3 "$script" 2>/dev/null || printf '?'
    else
        "$script" 2>/dev/null || printf '?'
    fi
}

while :; do
    if command -v jq >/dev/null 2>&1; then
        workspace_ids=$("$herdr" workspace list 2>/dev/null \
            | jq -r '.result.workspaces[]?.workspace_id')
    else
        workspace_ids=$("$herdr" workspace list 2>/dev/null \
            | tr '{' '\n' \
            | sed -n 's/.*"workspace_id":"\([^"]*\)".*/\1/p')
    fi

    for workspace_id in $workspace_ids; do
        for script in "$scripts_dir"/*; do
            [ -f "$script" ] && [ -x "$script" ] || continue
            token=$(token_name "$script")
            value=$(HERDR_SCRIPT_STATUS_WORKSPACE_ID="$workspace_id" run_script "$script" \
                | tr '\r\n' '  ' \
                | sed 's/[[:space:]][[:space:]]*/ /g; s/^ //; s/ $//' \
                | cut -c 1-96)

            [ -n "$value" ] || value='?'

            "$herdr" workspace report-metadata "$workspace_id" \
                --source "$source_id" \
                --token "$token=$value" \
                --ttl-ms "$ttl_ms" >/dev/null 2>&1 || true
        done
    done

    sleep "$interval"
done
