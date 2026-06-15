################################################################################
#                                 FILE INFO
# Library for managing script status reporting
# Used for monitoring script execution status across multiple scripts
################################################################################

# Status file location
STATUS_FILE="${STATUS_FILE:-$HOME/script-status.ini}"
SCRIPT_METRICS_DIR="${PROM_TEXTFILE_DIR:-${SCRIPT_METRICS_DIR:-${XDG_STATE_HOME:-$HOME/.local/state}/script-metrics}}"
SCRIPT_METRICS_PREFIX="${SCRIPT_METRICS_PREFIX:-local_script}"

status_metric_name() {
    local name="$1"
    name="${name//[^a-zA-Z0-9_]/_}"
    [[ "$name" =~ ^[a-zA-Z_:] ]] || name="_${name}"
    printf '%s\n' "$name"
}

status_label_value() {
    local value="$1"
    value="${value//\\/\\\\}"
    value="${value//\"/\\\"}"
    value="${value//$'\n'/ }"
    printf '%s\n' "$value"
}

status_metric_file() {
    local script_name
    script_name="$(status_metric_name "$1")"
    printf '%s/%s.prom\n' "$SCRIPT_METRICS_DIR" "$script_name"
}

prometheus_check_metric() {
    local script_name="$1"
    local metric_suffix="$2"
    local value="$3"
    local extra_labels="${4:-}"
    local metric_prefix metric_name metric_script labels

    metric_prefix="$(status_metric_name "$SCRIPT_METRICS_PREFIX")"
    metric_name="$(status_metric_name "${metric_prefix}_${metric_suffix}")"
    metric_script="$(status_label_value "$script_name")"
    labels="script=\"${metric_script}\""
    [ -n "$extra_labels" ] && labels="${labels},${extra_labels}"
    printf '%s{%s} %s\n' "$metric_name" "$labels" "$value"
}

# Update status file for monitoring
# Usage: update_status <exit_code> <message> [script_name]
# Example: update_status 0 "OK" "daily"
update_status() {
    local exit_code="$1"
    local message="$2"
    local script_name="${3:-${SCRIPT_NAME:-$(basename "$0")}}"
    local status_line="${script_name}: ${exit_code} ${message}"
    local current_date="# $(date +%Y%m%d)"

    _update_status_file() {
        local tmp_file="${STATUS_FILE}.$$"
        mkdir -p "$(dirname "$STATUS_FILE")"
        touch "$STATUS_FILE"
        {
            printf '%s\n' "$current_date"
            awk -v script_name="$script_name" -v status_line="$status_line" '
                BEGIN { found = 0 }
                NR == 1 && $0 ~ /^# [0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]$/ { next }
                index($0, script_name ":") == 1 {
                    if (!found) {
                        print status_line
                        found = 1
                    }
                    next
                }
                { print }
                END {
                    if (!found) {
                        print status_line
                    }
                }
            ' "$STATUS_FILE"
        } > "$tmp_file"
        mv "$tmp_file" "$STATUS_FILE"
    }

    if command -v flock >/dev/null 2>&1; then
        (
            flock -x 200
            _update_status_file
        ) 200>"${STATUS_FILE}.lock"
    else
        _update_status_file
    fi

    write_prometheus_status "$script_name" "$exit_code" "$message" || true
}

# Write Prometheus textfile-collector compatible metrics.
# Usage: write_prometheus_status <script_name> <exit_code> [message] [extra_metric_lines...]
write_prometheus_status() {
    local script_name="$1"
    local exit_code="$2"
    local message="${3:-}"
    shift 3 || true

    local metric_script metric_message metric_prefix metric_file metric_tmp now ok
    metric_script="$(status_label_value "$script_name")"
    metric_message="$(status_label_value "$message")"
    metric_prefix="$(status_metric_name "$SCRIPT_METRICS_PREFIX")"
    metric_file="$(status_metric_file "$script_name")"
    metric_tmp="${metric_file}.$$"
    now="$(date +%s)"
    ok=0
    [[ "$exit_code" == "0" ]] && ok=1

    mkdir -p "$SCRIPT_METRICS_DIR"
    {
        printf '# HELP %s_status Last script status code: 0 ok, 1 warning, 2 critical or command-specific failure.\n' "$metric_prefix"
        printf '# TYPE %s_status gauge\n' "$metric_prefix"
        printf '%s_status{script="%s"} %s\n' "$metric_prefix" "$metric_script" "$exit_code"
        printf '# HELP %s_ok Last script success state, 1 for ok and 0 for non-ok.\n' "$metric_prefix"
        printf '# TYPE %s_ok gauge\n' "$metric_prefix"
        printf '%s_ok{script="%s"} %s\n' "$metric_prefix" "$metric_script" "$ok"
        printf '# HELP %s_last_run_timestamp_seconds Unix timestamp of the last script run.\n' "$metric_prefix"
        printf '# TYPE %s_last_run_timestamp_seconds gauge\n' "$metric_prefix"
        printf '%s_last_run_timestamp_seconds{script="%s"} %s\n' "$metric_prefix" "$metric_script" "$now"
        if [ -n "$message" ]; then
            printf '# HELP %s_status_info Last script status message as an info-style metric.\n' "$metric_prefix"
            printf '# TYPE %s_status_info gauge\n' "$metric_prefix"
            printf '%s_status_info{script="%s",message="%s"} 1\n' "$metric_prefix" "$metric_script" "$metric_message"
        fi
        printf '%s\n' "$@"
    } > "$metric_tmp"
    mv "$metric_tmp" "$metric_file"
}

# Report one check result to the local status file, notifier, and Prometheus file.
# Usage: report_check_status <script_name> <exit_code> [message] [extra_metric_lines...]
report_check_status() {
    local script_name="$1"
    local exit_code="$2"
    local message="${3:-}"
    shift 3 || true

    update_status "$exit_code" "${message:-status=$exit_code}" "$script_name" || true
    notify_on_failure "$script_name" "$exit_code" || true
    write_prometheus_status "$script_name" "$exit_code" "$message" "$@" || true
}

# Directory for tracking last exit codes per script
TBAR_STATUS_DIR="${TBAR_STATUS_DIR:-/tmp/tbar-status}"

# Notify via telegram on state change to critical (exit code > 1)
# Usage: notify_on_failure <script_name> <exit_code>
# Example: notify_on_failure "check-docker" 2
notify_on_failure() {
    local script_name="$1"
    local exit_code="$2"
    local state_file="${TBAR_STATUS_DIR}/${script_name}"
    local prev_code=0

    mkdir -p "$TBAR_STATUS_DIR"

    if [[ -f "$state_file" ]]; then
        prev_code=$(<"$state_file")
    fi

    echo "$exit_code" > "$state_file"

    # Only notify on state change
    if [[ "$exit_code" == "$prev_code" ]]; then
        return 0
    fi

    # Notify on transition to critical (exit code > 1)
    if (( exit_code > 1 )); then
        telemsg "[ALERT] ${script_name} is failing (exit code: ${exit_code})" 2>/dev/null || true
    fi

    # Notify on recovery (from critical back to ok)
    # if (( prev_code > 1 && exit_code == 0 )); then
    #     telemsg "[OK] ${script_name} recovered" 2>/dev/null || true
    # fi
}
