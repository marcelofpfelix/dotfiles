# Herdr Script Status

Runs executable scripts and reports their output as Herdr sidebar metadata
tokens. It is the Herdr-native equivalent of small tmux `#(...)` status
commands.

Scripts live in:

```sh
$(herdr plugin config-dir local.script-status)/workspace.d
```

Each executable file becomes a token named after the file. The default scripts
mirror the non-agent custom parts of `desktop/.tmux.conf`:

- `workspace.d/gpg` reports `$gpg` from `check-gpg`
- `workspace.d/docker` reports `$docker` from `check-docker`
- `workspace.d/vpn` reports `$vpn` from `vpn`
- `workspace.d/claw` reports `$claw` from `check-claw`
- `workspace.d/cpu` reports `$cpu` from `check-cpu`
- `workspace.d/mem` reports `$mem` from `check-mem`
- `workspace.d/clock` reports `$clock`

Show the tokens in `~/.config/herdr/config.toml`:

```toml
[ui.sidebar.spaces]
rows = [
  ["state_icon", "workspace"],
  ["branch", "git_status"],
  ["$gpg", "$docker", "$vpn", "$claw"],
  ["$cpu", "$mem", "$clock"],
]
```

Reload Herdr:

```sh
herdr server reload-config
```

Restart the loop:

```sh
herdr plugin action invoke restart --plugin local.script-status
```
