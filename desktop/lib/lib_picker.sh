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
