################################################################################
#                                 FILE INFO
# Small helpers for line-oriented key=value config files.
################################################################################

config_trim() {
    local value="$1"
    value="${value#"${value%%[![:space:]]*}"}"
    value="${value%"${value##*[![:space:]]}"}"
    printf '%s\n' "$value"
}

config_expand_path() {
    local path="${1:?path is required}"

    case "$path" in
        "~") printf '%s\n' "$HOME" ;;
        "~/"*) printf '%s/%s\n' "$HOME" "${path#~/}" ;;
        *) printf '%s\n' "$path" ;;
    esac
}

config_resolve_file() {
    local config_file="${1:?config file is required}"
    local config_dir="${2:?config dir is required}"

    case "$config_file" in
        */*|~*) config_expand_path "$config_file" ;;
        *.*) printf '%s/%s\n' "$config_dir" "$config_file" ;;
        *) printf '%s/%s.conf\n' "$config_dir" "$config_file" ;;
    esac
}

config_read_kv_file() {
    local config_file="${1:?config file is required}"
    local key_value_callback="${2:?key value callback is required}"
    local line key value

    while IFS= read -r line || [ -n "$line" ]; do
        line="${line%%#*}"
        line="$(config_trim "$line")"
        [ -z "$line" ] && continue

        case "$line" in
            repo\ *)
                "$key_value_callback" "" "$line"
                ;;
            *=*)
                key="$(config_trim "${line%%=*}")"
                value="$(config_trim "${line#*=}")"
                "$key_value_callback" "$key" "$value"
                ;;
            *)
                "$key_value_callback" "" "$line"
                ;;
        esac
    done < "$config_file"
}
