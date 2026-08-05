#!/bin/sh
set -eu

plugin_id="${HERDR_PLUGIN_ID:-local.script-status}"
config_dir="${HERDR_PLUGIN_CONFIG_DIR:?HERDR_PLUGIN_CONFIG_DIR is required}"
state_dir="${HERDR_PLUGIN_STATE_DIR:?HERDR_PLUGIN_STATE_DIR is required}"
root="${HERDR_PLUGIN_ROOT:?HERDR_PLUGIN_ROOT is required}"

mkdir -p "$config_dir/workspace.d" "$state_dir"

if [ ! -f "$config_dir/workspace.d/clock" ]; then
    cp "$root/examples/workspace.d/clock" "$config_dir/workspace.d/clock"
    chmod 700 "$config_dir/workspace.d/clock"
fi

for name in gpg docker vpn claw cpu mem; do
    if [ ! -f "$config_dir/workspace.d/$name" ]; then
        cp "$root/examples/workspace.d/$name" "$config_dir/workspace.d/$name"
        chmod 700 "$config_dir/workspace.d/$name"
    fi
done

if [ "${1:-}" = restart ]; then
    sh "$root/scripts/stop.sh" || true
fi

pid_file="$state_dir/status-loop.pid"
if [ -f "$pid_file" ]; then
    pid=$(sed -n '1p' "$pid_file")
    case "$pid" in
        ''|*[!0-9]*) ;;
        *)
            if kill -0 "$pid" 2>/dev/null; then
                exit 0
            fi
            ;;
    esac
fi

(
    exec "$root/scripts/status-loop.sh"
) >/dev/null 2>"$state_dir/status-loop.log" &

printf '%s\n' "$!" >"$pid_file"
printf '%s\n' "$plugin_id started"
