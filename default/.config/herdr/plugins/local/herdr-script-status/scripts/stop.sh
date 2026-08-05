#!/bin/sh
set -eu

state_dir="${HERDR_PLUGIN_STATE_DIR:?HERDR_PLUGIN_STATE_DIR is required}"
pid_file="$state_dir/status-loop.pid"

[ -f "$pid_file" ] || exit 0
pid=$(sed -n '1p' "$pid_file")
rm -f "$pid_file"

case "$pid" in
    ''|*[!0-9]*) exit 0 ;;
esac

kill "$pid" 2>/dev/null || true
