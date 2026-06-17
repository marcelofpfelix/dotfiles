# Requirements

This repo assumes a user shell environment with the tools and plugin repos below.

## Core Tools

Required for the desktop zsh setup:

- `zsh`
- `git`
- `fzf`
- `eza`
- `kubectl`
- `direnv`
- `uvx`
- `zoxide`
- `starship`
- `tv`
- `atuin`
- `nvim`
- `bat`

On macOS, these are expected to be available from Homebrew when possible.

## Zsh Plugin Repos

`desktop/.zshrc_desktop` loads zsh plugins from `ZSH_PLUGINS`, currently
defaulting to `/opt/git`.

Required repos:

- `/opt/git/romkatv/zsh-defer`
- `/opt/git/aloxaf/fzf-tab`
- `/opt/git/zsh-users/zsh-autosuggestions`
- `/opt/git/zsh-users/zsh-history-substring-search`
- `/opt/git/zsh-users/zsh-syntax-highlighting`

Example install:

```sh
sudo mkdir -p /opt/git/romkatv /opt/git/aloxaf /opt/git/zsh-users
sudo git clone https://github.com/romkatv/zsh-defer /opt/git/romkatv/zsh-defer
sudo git clone https://github.com/aloxaf/fzf-tab /opt/git/aloxaf/fzf-tab
sudo git clone https://github.com/zsh-users/zsh-autosuggestions /opt/git/zsh-users/zsh-autosuggestions
sudo git clone https://github.com/zsh-users/zsh-history-substring-search /opt/git/zsh-users/zsh-history-substring-search
sudo git clone https://github.com/zsh-users/zsh-syntax-highlighting /opt/git/zsh-users/zsh-syntax-highlighting
```

## Optional Desktop Tools

Some aliases and scripts use these when present:

- `docker`
- `tmux`
- `gum`
- `gitleaks`
- `jq`
- `act`
- `pre-commit`
- `ansible-playbook`
- `gopass`
- `gpaste-client` or `copyq`
- `notify-send` or `terminal-notifier`

