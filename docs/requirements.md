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

`desktop/.zshrc_desktop` loads zsh plugins from `ZSH_PLUGINS`, defaulting to
`GIT_REPOS_ROOT` or `$HOME/git`.

Required repos:

- `$HOME/git/romkatv/zsh-defer`
- `$HOME/git/aloxaf/fzf-tab`
- `$HOME/git/zsh-users/zsh-autosuggestions`
- `$HOME/git/zsh-users/zsh-history-substring-search`
- `$HOME/git/zsh-users/zsh-syntax-highlighting`

Example install:

```sh
gsync --read --repo "romkatv/zsh-defer branch=master"
gsync --read --repo "aloxaf/fzf-tab branch=master"
gsync --read --repo "zsh-users/zsh-autosuggestions branch=master"
gsync --read --repo "zsh-users/zsh-history-substring-search branch=master"
gsync --read --repo "zsh-users/zsh-syntax-highlighting branch=master"
```

## Optional Desktop Tools

Some aliases and scripts use these when present:

- `docker`
- `tmux`
- `gum`
- `tshark`
- `gitleaks`
- `jq`
- `act`
- `pre-commit`
- `ansible-playbook`
- `gopass`
- `timew`
- `tock`
- `gpaste-client` or `copyq`
- `notify-send` or `terminal-notifier`

## AI Heavy-User Stack

Core binaries expected on the main workstation:

- `codex`
- `claude`
- `opencode`
- `openclaw`
- `bd`
- `task-master`
- `serena`
- `uv` and `uvx`
- `rtk`
- `rg`
- `fd`
- `ast-grep`
- `jq`
- `tmux`
- `gh`
- `docker`

On-demand binaries and services:

- `babysitter` from `npm install -g @a5c-ai/babysitter-sdk`
- Babysitter Claude plugin from `claude plugin marketplace add a5c-ai/babysitter`
  and `claude plugin install --scope user babysitter@a5c.ai`
- Codex-Workflows from `codex plugin marketplace add
  robzilla1738/Codex-Workflows` and `codex plugin add
  codex-workflows@codex-workflows`
- FFF MCP/binary for repeated fuzzy/frecency-heavy search
- Sourcebot for org-scale multi-repo search
- LiteLLM, Langfuse, and Helicone for shared API routing and observability
- Hindsight local daemon with `uvx hindsight-embed`, after explicit memory-pilot
  approval

Run `ai-stack-doctor` to check what is installed and which on-demand pieces are
ready to enable.
