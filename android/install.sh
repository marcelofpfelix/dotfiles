#!/data/data/com.termux/files/usr/bin/sh
set -eu

force=0
if [ "${1:-}" = "--force" ]; then
  force=1
fi

src_dir="$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)"

link_file() {
  src="$1"
  dst="$2"
  mkdir -p "$(dirname -- "$dst")"

  if [ -e "$dst" ] || [ -L "$dst" ]; then
    if [ -L "$dst" ] || [ "$force" -eq 1 ]; then
      rm -f "$dst"
    else
      printf 'skip %s: exists; rerun with --force to replace\n' "$dst" >&2
      return 0
    fi
  fi

  ln -s "$src" "$dst"
  printf 'link %s -> %s\n' "$dst" "$src"
}

mkdir -p "$HOME/bin" "$HOME/.termux" "$HOME/.ssh"

link_file "$src_dir/.zshrc_termux" "$HOME/.zshrc"
link_file "$src_dir/.tmux.conf" "$HOME/.tmux.conf"
link_file "$src_dir/.termux/termux.properties" "$HOME/.termux/termux.properties"
link_file "$src_dir/.termux/colors.properties" "$HOME/.termux/colors.properties"
link_file "$src_dir/bin/sshp" "$HOME/bin/sshp"
link_file "$src_dir/bin/tmux-main" "$HOME/bin/tmux-main"

chmod 700 "$HOME/.ssh"
chmod 755 "$src_dir/bin/sshp" "$src_dir/bin/tmux-main"

if command -v termux-reload-settings >/dev/null 2>&1; then
  termux-reload-settings
fi

printf 'done\n'
