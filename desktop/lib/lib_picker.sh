#!/usr/bin/env bash

picker_choose() {
    local prompt="${1:-Select}"
    local backend="${PICKER_BACKEND:-auto}"
    case "$backend" in
        walker) walker --dmenu -p "$prompt" ;;
        terminal|term) gum filter --placeholder "$prompt" ;;
        auto)
            if [[ -n "${WAYLAND_DISPLAY:-}" ]] && command -v walker >/dev/null 2>&1; then
                walker --dmenu -p "$prompt"
            elif command -v gum >/dev/null 2>&1; then
                gum filter --placeholder "$prompt"
            elif command -v fzf >/dev/null 2>&1; then
                fzf --prompt "$prompt> "
            else
                printf "picker: install walker, gum, or fzf\n" >&2
                return 1
            fi
            ;;
        *) printf "picker: unknown PICKER_BACKEND=%s\n" "$backend" >&2; return 2 ;;
    esac
}

picker_input() {
    local prompt="${1:-Input}"
    local backend="${PICKER_BACKEND:-auto}"
    case "$backend" in
        walker) printf "" | walker --dmenu -p "$prompt" ;;
        terminal|term) gum input --placeholder "$prompt" ;;
        auto)
            if [[ -n "${WAYLAND_DISPLAY:-}" ]] && command -v walker >/dev/null 2>&1; then
                printf "" | walker --dmenu -p "$prompt"
            elif command -v gum >/dev/null 2>&1; then
                gum input --placeholder "$prompt"
            else
                printf "%s: " "$prompt" >&2
                IFS= read -r input
                printf "%s\n" "$input"
            fi
            ;;
        *) printf "picker: unknown PICKER_BACKEND=%s\n" "$backend" >&2; return 2 ;;
    esac
}

picker_open_url() {
    if command -v chrome-wayland >/dev/null 2>&1; then
        chrome-wayland "$1"
    elif command -v xdg-open >/dev/null 2>&1; then
        xdg-open "$1"
    else
        printf "%s\n" "$1"
    fi
}


picker_status() {
    local missing=0 picker_ok=0 opener_ok=0 cmd
    printf 'backend %s\n' "${PICKER_BACKEND:-auto}"
    if [ -n "${WAYLAND_DISPLAY:-}" ]; then
        printf 'wayland yes\n'
    else
        printf 'wayland no\n'
    fi

    for cmd in walker gum fzf; do
        if command -v "$cmd" >/dev/null 2>&1; then
            printf 'ok   %s\n' "$cmd"
            picker_ok=1
        else
            printf 'warn %s\n' "$cmd"
        fi
    done
    [ "$picker_ok" -eq 1 ] || { printf 'missing picker backend\n' >&2; missing=1; }

    for cmd in chrome-wayland xdg-open; do
        if command -v "$cmd" >/dev/null 2>&1; then
            printf 'ok   %s\n' "$cmd"
            opener_ok=1
        else
            printf 'warn %s\n' "$cmd"
        fi
    done
    [ "$opener_ok" -eq 1 ] || { printf 'missing url opener\n' >&2; missing=1; }

    return "$missing"
}
