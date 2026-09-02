#!/bin/sh
set -eu

repo_root=$(CDPATH='' cd -- "$(dirname -- "$0")/.." && pwd)
tmp_dir=$(mktemp -d)
trap 'rm -rf "$tmp_dir"' EXIT

cp "$repo_root/desktop/bin/mise-tool-shim" "$tmp_dir/mise-tool-shim"
chmod +x "$tmp_dir/mise-tool-shim"
ln -s mise-tool-shim "$tmp_dir/npm"

cat >"$tmp_dir/mise" <<'EOF'
#!/bin/sh
printf '%s\n' "$@"
EOF
chmod +x "$tmp_dir/mise"

actual=$(MISE_BIN="$tmp_dir/mise" "$tmp_dir/npm" install example)
expected='exec
--
npm
install
example'

test "$actual" = "$expected"
