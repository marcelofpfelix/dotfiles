# macOS Setup Notes

These notes are intentionally generic. Keep personal tokens, usernames, and
machine-specific values in private inventory or a private notes repository.

## Requirements

- Create the target user before running host setup.
- Enable remote access when managing the host over SSH.
- Install Xcode command line tools so Python and fact gathering work correctly.

## Shell

Homebrew shell setup:

```sh
echo 'eval "$(/opt/homebrew/bin/brew shellenv zsh)"' >> ~/.zprofile
eval "$(/opt/homebrew/bin/brew shellenv zsh)"
```


## Local GitHub Actions

Install `act` to run GitHub Actions workflows on the local Docker/Colima daemon before pushing:

```sh
brew install act
act --version
```

For repos that use Colima on this host, prefer the real socket path instead of the `~/.colima` symlink when `act` needs to mount the Docker socket:

```sh
DOCKER_HOST=unix:///Volumes/NVMe/docker/colima/default/docker.sock \
  act push -W .github/workflows/ci.yml -j check \
  -P ubuntu-latest=catthehacker/ubuntu:act-latest \
  --container-architecture linux/arm64 \
  --container-daemon-socket /Volumes/NVMe/docker/colima/default/docker.sock
```

The symlinked path can fail with `mkdir /Users/marcelof/.colima: file exists` during container startup. `act` may also warn that GitHub cache restore/save failed; that is acceptable when the job itself succeeds.

`basecamp/gh-signoff` is complementary, not a replacement for `act`: use `act` to execute the workflow locally, then optionally use `gh signoff` to publish a GitHub commit status for a PR after local checks pass. Requiring signoff changes GitHub branch protection, so keep it as an explicit repo policy decision.

## System

Prevent sleep on managed desktop hosts:

```sh
sudo pmset -a displaysleep 0 sleep 0 disksleep 0 networkoversleep 1
```

## Packages

Useful package groups to model in Ansible:

- Shell: `tmux`, `zoxide`, `starship`, `atuin`, `fzf`, `eza`, `direnv`,
  `television`, `tmuxup`
- CLI: `gh`, `uv`, `coreutils`, `gum`, `gopass`, `iproute2mac`, `ansible`,
  `beads`, `task`, `taskwarrior-tui`, `timewarrior`, `tock`, `wireshark`,
  `herdr`, `hunk`, `oath-toolkit`, `sipexer`, `pi`, `hermes`
- Containers: `colima`, `kubectl`, `docker-buildx`
- Editors: `nvim`
- Sync: `syncthing`
- Security: `pinentry-mac`

Additional package sources to evaluate:

- Homebrew taps: `hashicorp/tap`, `sielicki/dystemctl`, `modem-dev/tap`
- Homebrew packages from taps: `hashicorp/tap/vault`, `modem-dev/tap/hunk`
- Homebrew casks: `font-fira-code-nerd-font`
- Tentative casks: `codex`; npm may remain the working install path
- Node tools: `clawdbot`, `claude-code`, `clawdhub`, `@telnyx/api-cli`
- Agent CLIs:
  - `pi` via `npm install -g --ignore-scripts @earendil-works/pi-coding-agent`.
    The npm `latest` metadata reported `0.80.7`, but the installed package and
    `pi --version` reported `0.80.3`.
  - `hermes` via `pipx install hermes-agent`, currently `Hermes Agent v0.15.2`.
    Prefer this PyPI/pipx install over the unofficial npm bridge
    `hermes-agent`, which runs a Python install from npm `postinstall`.
- Go tools: `github.com/prometheus/alertmanager/cmd/amtool@latest`
- Git tools: `romkatv/zsh-defer` under `/opt/git/romkatv/zsh-defer`
- GitHub release tools: `sipexer` from `miconda/sipexer` because it is not in
  Homebrew core; install the Darwin arm64 release into `~/bin/sipexer`.

Runtime setup notes:

- Install Node from the repository `.nvmrc` and run `nvm use`.
- Time tracking uses `timewarrior` plus `tock`; their runtime configuration is
  tracked in the dotfiles repo.
- Split shell profile snippets that differ between Linux and Darwin.
- Ensure `/opt/homebrew/bin` is available before managed shell tools run.
