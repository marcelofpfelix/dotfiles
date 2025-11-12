################################################################################
#                                 FILE INFO
# Library for managing script status reporting
# Used for monitoring script execution status across multiple scripts
################################################################################

# Status file location
STATUS_FILE="${STATUS_FILE:-$HOME/script-status.ini}"

# Update status file for monitoring
# Usage: update_status <exit_code> <message> [script_name]
# Example: update_status 0 "OK" "daily"
update_status() {
    local exit_code="$1"
    local message="$2"
    local script_name="$(basename "$0")"  # "${3:-${SCRIPT_NAME:-$filename}}"
    local status_line="${script_name}: ${exit_code} ${message}"
    local current_date="# $(date +%Y%m%d)"

    # Use flock for thread-safe file operations
    # Applies an exclusive lock on file descriptor 200
    (
        flock -x 200

        # Create file if it doesn't exist
        touch "$STATUS_FILE"

        # Update or add date line at the top
        if grep -q "^# [0-9]\{8\}$" "$STATUS_FILE" 2>/dev/null; then
            sed -i "1s|^# [0-9]\{8\}$|${current_date}|" "$STATUS_FILE"
        else
            sed -i "1i${current_date}" "$STATUS_FILE"
        fi

        # Update existing line or append new one
        if grep -q "^${script_name}:" "$STATUS_FILE" 2>/dev/null; then
            sed -i "s|^${script_name}:.*|${status_line}|" "$STATUS_FILE"
        else
            echo "$status_line" >> "$STATUS_FILE"
        fi
    ) 200>"${STATUS_FILE}.lock"
}
