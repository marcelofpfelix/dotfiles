# Android Termux Dotfiles

Termux profile for a small Termius-like terminal setup: persistent tmux session,
SSH bookmarks, mobile-friendly extra keys, and a compact shell prompt.

## Install

Copy or sync this `android/` directory to Termux, then run:

```sh
cd ~/storage/shared/Sync/dotfiles/android
sh ./install.sh
```

If the files are checked out directly in Termux, run the same command from that
checkout. The installer creates symlinks into `$HOME` and refuses to replace
existing non-symlink files unless `--force` is passed.

## Packages

Install the baseline tools with:

```sh
xargs pkg install -y < packages.txt
```

Recommended Termux companion apps from F-Droid:

- Termux:API
- Termux:Styling
- Termux:Widget

## SSH Bookmarks

Start from the example file:

```sh
mkdir -p ~/.ssh
cp ssh/config.example ~/.ssh/config
chmod 700 ~/.ssh
chmod 600 ~/.ssh/config
```

Keep private keys out of Syncthing unless the synced folder is encrypted and
limited to trusted devices. Syncing `~/.ssh/config` is fine; sync private keys
only when you have a clear threat model.

Run the picker with:

```sh
sshp
```

## Session Restore

The shell auto-attaches to `tmux` session `main` for interactive Termux shells.
Install tmux plugin manager inside Termux to enable resurrect/continuum:

```sh
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
```

Then open tmux and press prefix + `I`.
