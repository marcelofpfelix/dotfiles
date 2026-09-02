#!/bin/sh
set -eu

test_dir="$(mktemp -d)"
trap 'rm -rf "$test_dir"' EXIT HUP INT TERM

repo_root="$(CDPATH='' cd -- "$(dirname "$0")/.." && pwd)"
zshrc="$repo_root/desktop/.zshrc_desktop"
helper_source="$test_dir/hermes-container-cli.zsh"
stub_bin="$test_dir/bin"
mkdir -p "$stub_bin"

sed -n '/^_hermes_container_cli() {/,/^}/p' "$zshrc" >"$helper_source"

actual="$(zsh -fc '
docker() {
    if [[ " $* " == *" inspect "* ]]; then
        print -r -- healthy
        return
    fi
    printf "%s|" "${HERDR_AGENT:-unset}"
    printf "<%s>" "$@"
    printf "\n"
}
source "$1"
cd "$2"
_hermes_container_cli work-hermes prompt "two words"
' test "$helper_source" "$repo_root")"

expected='hermes|<--context><colima><exec><-i><--workdir></Users/marcelof/gwt/marcelofpfelix/dotfiles/main><work-hermes><hermes><--in></Users/marcelof/gwt/marcelofpfelix/dotfiles/main><prompt><two words>'
[ "$actual" = "$expected" ] || {
    printf 'Hermes wrapper lost marker, cwd, profile, or arguments: %s\n' "$actual" >&2
    exit 1
}

data_alias="$(zsh -fc '
docker() {
    if [[ " $* " == *" inspect "* ]]; then print -r -- healthy; return; fi
    printf "<%s>" "$@"
    printf "\n"
}
source "$1"
cd /data/gwt/team-telnyx/tel-proxy-frr/main
_hermes_container_cli work-hermes status
' test "$helper_source")"
case "$data_alias" in
  *'<--workdir></Users/marcelof/gwt/team-telnyx/tel-proxy-frr/main><work-hermes><hermes><--in></Users/marcelof/gwt/team-telnyx/tel-proxy-frr/main><status>'*) ;;
  *) printf 'Hermes wrapper did not map /data/gwt to the in-container GWT path: %s\n' "$data_alias" >&2; exit 1 ;;
esac

fallback="$(zsh -fc '
docker() {
    if [[ " $* " == *" inspect "* ]]; then print -r -- healthy; return; fi
    printf "<%s>" "$@"
    printf "\n"
}
source "$1"
cd "$2"
_hermes_container_cli personal-hermes --tui
' test "$helper_source" "$test_dir")"
case "$fallback" in
  *'<--workdir></workspace><personal-hermes><hermes><--in></workspace><--tui>'*) ;;
  *) printf 'Hermes wrapper did not fall back to /workspace: %s\n' "$fallback" >&2; exit 1 ;;
esac

override="$(zsh -fc '
docker() {
    if [[ " $* " == *" inspect "* ]]; then print -r -- healthy; return; fi
    printf "<%s>" "$@"
    printf "\n"
}
source "$1"
_hermes_container_cli work-hermes --in /custom --tui
' test "$helper_source")"
case "$override" in
  *'<work-hermes><hermes><--in></custom><--tui>'*) ;;
  *) printf 'Hermes wrapper did not preserve an explicit --in override: %s\n' "$override" >&2; exit 1 ;;
esac

set +e
invalid="$(zsh -fc 'source "$1"; _hermes_container_cli arbitrary-container --tui' test "$helper_source" 2>&1)"
invalid_status=$?
set -e
[ "$invalid_status" -eq 2 ]
case "$invalid" in
  *'unsupported Hermes container: arbitrary-container'*) ;;
  *) printf 'Hermes wrapper allowlist failure was unclear: %s\n' "$invalid" >&2; exit 1 ;;
esac

set +e
unhealthy="$(zsh -fc '
docker() { print -r -- starting; }
source "$1"
_hermes_container_cli work-hermes --tui
' test "$helper_source" 2>&1)"
unhealthy_status=$?
set -e
[ "$unhealthy_status" -ne 0 ]
case "$unhealthy" in
  *'Hermes container is not healthy: work-hermes (starting)'*) ;;
  *) printf 'Hermes wrapper health failure was unclear: %s\n' "$unhealthy" >&2; exit 1 ;;
esac

cat >"$stub_bin/docker" <<'EOF'
#!/bin/sh
case " $* " in
  *' inspect '*) printf 'healthy\n' ;;
  *) printf '%s\n' "$*" >"$DOCKER_CAPTURE" ;;
esac
EOF
chmod +x "$stub_bin/docker"

# shellcheck disable=SC2016 # expanded by the nested zsh, not this test shell
DOCKER_CAPTURE="$test_dir/docker-tty.args" \
PATH="$stub_bin:$PATH" \
script -q /dev/null zsh -fc 'source "$1"; cd "$2"; _hermes_container_cli constanca-hermes --tui' \
  test "$helper_source" "$repo_root" >/dev/null

tty_args="$(cat "$test_dir/docker-tty.args")"
case "$tty_args" in
  *'exec -i -t --workdir /Users/marcelof/gwt/marcelofpfelix/dotfiles/main constanca-hermes hermes --in /Users/marcelof/gwt/marcelofpfelix/dotfiles/main --tui'*) ;;
  *) printf 'Hermes wrapper did not allocate a pseudo-TTY correctly: %s\n' "$tty_args" >&2; exit 1 ;;
esac

printf 'Hermes container CLI tests: ok\n'
