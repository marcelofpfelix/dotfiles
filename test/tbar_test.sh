#!/bin/sh
set -eu

test_dir="$(mktemp -d)"
trap 'rm -rf "$test_dir"' EXIT HUP INT TERM

stub_bin="$test_dir/bin"
mkdir -p "$stub_bin"

cat >"$stub_bin/board" <<'EOF'
#!/bin/sh
printf '%s\n' "$*"
EOF
chmod +x "$stub_bin/board"

repo_root="$(CDPATH='' cd -- "$(dirname "$0")/.." && pwd)"
tbar="$repo_root/desktop/bin/tbar"
tmux_output="$(PATH="$stub_bin:$PATH" "$tbar")"
[ "$tmux_output" = 'render --format tmux --surface tmux-top' ] || {
  printf 'default output did not use the Board tmux renderer: %s\n' "$tmux_output" >&2
  exit 1
}

herdr_output="$(PATH="$stub_bin:$PATH" "$tbar" --format herdr)"
[ "$herdr_output" = 'render --format terminal --surface tmux-top --color never' ] || {
  printf 'Herdr output did not use the Board no-color terminal renderer: %s\n' "$herdr_output" >&2
  exit 1
}

plain_output="$(PATH="$stub_bin:$PATH" "$tbar" --format plain)"
[ "$plain_output" = 'render --format plain --surface tmux-top' ] || {
  printf 'plain output did not use the Board plain renderer: %s\n' "$plain_output" >&2
  exit 1
}

custom_output="$(PATH="$stub_bin:$PATH" TBAR_SURFACE=custom "$tbar")"
[ "$custom_output" = 'render --format tmux --surface custom' ] || {
  printf 'custom surface was ignored: %s\n' "$custom_output" >&2
  exit 1
}

set +e
unknown_output="$(PATH="$stub_bin:$PATH" "$tbar" --format unknown 2>&1)"
unknown_status=$?
set -e

[ "$unknown_status" -eq 2 ] || {
  printf 'unknown format exited %s, expected 2\n' "$unknown_status" >&2
  exit 1
}
case "$unknown_output" in
  *'unsupported format: unknown'*) ;;
  *) printf 'unknown format error is unclear: %s\n' "$unknown_output" >&2; exit 1 ;;
esac

for config in \
  "$repo_root/default/.config/herdr/config.toml" \
  "$repo_root/desktop/.config/herdr/config.toml"
do
  grep -F 'board render --format terminal --surface tmux-top --color never' "$config" >/dev/null || {
    printf 'Herdr does not use the Board no-color terminal renderer: %s\n' "$config" >&2
    exit 1
  }
done

grep -F 'command = ["env", "BAR_COLOR_FORMAT=plain", "check-mem"]' \
  "$repo_root/desktop/.config/board/board.toml" >/dev/null || {
  printf 'macOS memory fallback is not scheduled through Board\n' >&2
  exit 1
}

printf 'tbar format tests: ok\n'
